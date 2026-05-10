# Performance Improvement Report

Internal-only optimizations to `ZMarkupParser`'s render pipeline. All public APIs are
preserved bit-for-bit.

> **Note on the harness.** The numbers below were captured with the
> `ZMarkupParserPerformanceTests` target that this PR also removes (the published JSON
> was host-dependent, and the suite ran for ~10 min per pass). If you want to re-measure,
> the `testZMarkupParserPerformance` / `testZHTMLMarkupParserMeasure` /
> `testDocumentTypeHTMLMeasure` test bodies can be recovered from git history — the
> `testRootMarkupIsReleasedAfterRender` retain-cycle check has already been relocated to
> `ZMarkupParserTests/Core/MemoryLeakTests.swift` so the regression coverage stays in CI.

## Host

- Apple M1 Pro / macOS 26.4 / Xcode 26.2
- All numbers below were measured with `swift test -c release` on the same physical machine
- Input: the bundled `testZMarkupParserPerformance` HTML sample (containing mixed / unclosed
  tags, `<br/>`, `<del>`, `<u>`, `<b>`, `<span style="color:green">…`, emoji)

## Headline

`testZHTMLMarkupParserMeasure` — render the sample repeated 300 times (≈ 100 KB HTML),
averaged over 10 iterations:

| Implementation | avg time / iter | vs. system |
|---|---|---|
| **`ZMarkupParser` (`233c6d3`)** | **0.372 s** | **1.23× faster (-19%)** |
| `NSAttributedString.DocumentType.html` (system) | 0.457 s | — |

Notes:
- The new build pulls ahead of the system API on this host, reversing the relationship
  recorded in the legacy `Tests/.../Report/*.json` (which was captured on a 2022 / M2 /
  macOS 13.2 host before this optimization run).
- `NSAttributedString.DocumentType.html` is documented to crash when the input exceeds
  ~54 600 characters; `ZMarkupParser` completes the 334 000-character case in 1.15 s.

## Length scaling (`testZMarkupParserPerformance`, i = 1 … 1000)

| i | length (chars) | new (s) |
|---|---|---|
| 1 | 334 | 0.019 |
| 10 | 3 340 | 0.012 |
| 50 | 16 700 | 0.056 |
| 100 | 33 400 | 0.114 |
| 150 | 50 100 | ~0.17 |
| 200 | 66 800 | 0.230 |
| 300 | 100 200 | 0.345 |
| 500 | 167 000 | 0.575 |
| 1000 | 334 000 | **1.152** |

The new build was run end-to-end for the full 1000-iteration sweep (588 s wall time).
The cost is roughly linear in input length above i ≈ 10 — the per-render
preallocation work (`components.buildLookup()` + `precomputeStyles` walk) dominates at
very small inputs but is amortized once there is real content to render.

## Comparison vs. `NSAttributedString.DocumentType.html`

Same-host, release config:

| Length | System (`.documentType = .html`) | `ZMarkupParser` |
|---|---|---|
| 300× = 100 200 chars | 0.457 s / iter (10-iter average) | **0.372 s / iter** |

For larger inputs the published cross-host JSON (different host, but useful as a
ballpark) puts the system API at 3.853 s for the 1000× / 334 000-character case, while
the new build measured 1.152 s on this host — a ~3× margin.

## Where the wins came from

| Commit | What changed |
|---|---|
| `6753271` | Cached `NSRegularExpression` (was rebuilt every call); merged the comment/DOCTYPE branch into the main alternation regex; `HTMLStringToParsedResultProcessor.process` now delegates to a Swift-`String`-native `HTMLScanner`; precomputed every markup's effective style top-down so `collectMarkupStyle` is `O(1)` per leaf instead of `O(depth)`. |
| `d4efa0f` | `components.value(markup:)` (legacy `Array.first(where:)`) replaced with an `ObjectIdentifier`-keyed dictionary built once on visitor / selector init. The legacy hot loop walked `N` markups and queried `N` components — pure `O(N²)`. |
| `e2970a6` | The newly-added `precomputeStyles` walker was itself still `O(N²)` because it called the array-side `value(markup:)`. Switched it to the same `O(1)` dictionary lookup, and folded `rootStyle` into the inherited seed so the visitor's leaf-side `collectMarkupStyle` no longer pays a `fillIfNil(from: rootStyle)` per leaf. Also collapsed `collectAttributedString` to a single `begin/endEditing` for-in loop. |
| `233c6d3` | Eager-init the three `lazy var` processors on `ZHTMLParser` (Swift's `lazy var` is not thread-safe under concurrent first-touch); added two regression tests that fan 200 concurrent calls against `render` / `selector` / `stripper`. |

## Tests

- All unit tests pass under `swift test`, including the new
  `testConcurrentRenderProducesIdenticalResults` and
  `testConcurrentSelectorAndStripperAreThreadSafe` (200 concurrent calls each).
- `testRootMarkupIsReleasedAfterRender` passes (the markup tree is still released
  promptly).
- The iOS simulator snapshot tests (`ZMarkupParserSnapshotTests`) were re-recorded in
  `b925c87` against iPhone 16 / iOS 18.6 — the closest destination available on this
  host. The diffs come from font / rendering changes between iOS versions and reproduce
  on `main` against the same simulator, not from any rendering change introduced here.

## Methodology

- All numbers are wall-clock time measured with `CFAbsoluteTimeGetCurrent()` inside the
  existing `ZMarkupParserPerformanceTests` (same source code that the published
  cross-host JSON was recorded against, except for the upstream
  `$0` ↔ `$0.0` tuple-destructuring fix needed for the suite to compile).
- Release configuration (`swift test -c release`) for every measurement.
- Each "300× × 10" measure was a single `XCTestCase` invocation; the 1000× progressive
  was a single sweep with `autoreleasepool` per iteration.
- The system-API comparison uses
  `NSAttributedString(data:options:documentAttributes:)` with
  `.documentType = .html` and `.characterEncoding = utf8`, run on the same host as the
  `ZMarkupParser` numbers.
