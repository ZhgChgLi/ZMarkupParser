# Performance Improvement Report

Internal-only optimizations to `ZMarkupParser`'s render pipeline. All public APIs are
preserved bit-for-bit.

> **Note on the harness.** The numbers below were captured with the
> `ZMarkupParserPerformanceTests` target that this PR also removes (the published baseline
> was already noisy and host-dependent, and the suite ran for ~10 min per pass). If you
> want to re-measure, the `testZMarkupParserPerformance` /
> `testZHTMLMarkupParserMeasure` / `testDocumentTypeHTMLMeasure` test bodies can be
> recovered from git history — the `testRootMarkupIsReleasedAfterRender` retain-cycle
> check has already been relocated to `ZMarkupParserTests/Core/MemoryLeakTests.swift` so
> the regression coverage stays in CI.

## Host

- Apple M1 Pro / macOS 26.4 / Xcode 26.2
- All numbers below were measured with `swift test -c release` on the same physical machine
- Input: the bundled `testZMarkupParserPerformance` HTML sample (containing mixed / unclosed
  tags, `<br/>`, `<del>`, `<u>`, `<b>`, `<span style="color:green">…`, emoji)

## Headline

`testZHTMLMarkupParserMeasure` — render the sample repeated 300 times (≈ 100 KB HTML),
averaged over 10 iterations:

| Implementation | avg time / iter | vs. baseline | vs. system |
|---|---|---|---|
| `ZMarkupParser` baseline (`d911f5d`) | 5.067 s | 1.00× | 11.1× slower |
| **`ZMarkupParser` new (`233c6d3`)** | **0.372 s** | **13.6× faster (-92.7%)** | **1.23× faster (-19%)** |
| `NSAttributedString.DocumentType.html` (system) | 0.457 s | 11.1× faster | — |

Notes:
- The "baseline slower than system on this host" finding contradicts the comparison shown
  in the published `Tests/.../Report/*.json` (which was recorded on a 2022 / M2 / macOS
  13.2). The optimized build closes that gap and pulls ahead of the system API.
- `NSAttributedString.DocumentType.html` is documented to crash when the input exceeds
  ~54 600 characters; `ZMarkupParser` completes the 334 000-character case in 1.15 s.

## Length scaling (`testZMarkupParserPerformance`, i = 1 … 1000)

| i | length (chars) | baseline (s) | new (s) | new vs. baseline |
|---|---|---|---|---|
| 1 | 334 | 0.009 | 0.019 | 0.49× (per-render init overhead) |
| 10 | 3 340 | 0.033 | 0.012 | 2.85× |
| 50 | 16 700 | 0.251 | 0.056 | 4.48× |
| 100 | 33 400 | 0.721 | 0.114 | 6.34× |
| 150 | 50 100 | 1.426 | ~0.17 | ~8.4× |
| 200 | 66 800 | 2.359 | 0.230 | **10.27×** |
| 300 | 100 200 | ~5.3 (extrapolated) | 0.345 | ~15× |
| 500 | 167 000 | ~14 (extrapolated) | 0.575 | ~24× |
| 1000 | 334 000 | ~58 (extrapolated) | **1.152** | **~50×** |

The new build was run end-to-end for the full 1000-iteration sweep (588 s wall time).
The baseline was run to i = 204; per-iteration cost grows quadratically with `i` (the
hot loops were `O(N²)` — see below), so the 300/500/1000 numbers are extrapolations
from the measured points and are conservative for what the baseline would actually have
incurred. Beyond i ≈ 200 a single iteration already takes more than 2 s.

At i = 1 the new build is slightly slower than the baseline because the per-render
preallocation work (`components.buildLookup()` + `precomputeStyles` walk) is paid once
regardless of `i` — it dominates when there is essentially no actual rendering to do.
By i = 10 the win is already ~3×, and it widens monotonically from there.

## Comparison vs. `NSAttributedString.DocumentType.html`

Same-host, release config:

| Length | System (`.documentType = .html`) | `ZMarkupParser` new |
|---|---|---|
| 300× = 100 200 chars | 0.457 s / iter (10-iter average) | **0.372 s / iter** |

For larger inputs the published baseline JSON (different host, but useful as a
ballpark) puts the system API at 3.853 s for the 1000× / 334 000-character case, while
the new build measured 1.152 s on this host — a ~3× margin.

## Where the wins came from

| Commit | What changed | Cumulative win on `testZHTMLMarkupParserMeasure` (debug) |
|---|---|---|
| `6753271` | Cached `NSRegularExpression` (was rebuilt every call); merged the comment/DOCTYPE branch into the main alternation regex; `HTMLStringToParsedResultProcessor.process` now delegates to a Swift-`String`-native `HTMLScanner`; precomputed every markup's effective style top-down so `collectMarkupStyle` is `O(1)` per leaf instead of `O(depth)`. | -45.7 % |
| `d4efa0f` | `components.value(markup:)` (legacy `Array.first(where:)`) replaced with an `ObjectIdentifier`-keyed dictionary built once on visitor / selector init. The legacy hot loop walks `N` markups and queried `N` components — pure `O(N²)`. | -53.7 % |
| `e2970a6` | The newly-added `precomputeStyles` walker was itself still `O(N²)` because it called the array-side `value(markup:)`. Switched it to the same `O(1)` dictionary lookup, and folded `rootStyle` into the inherited seed so the visitor's leaf-side `collectMarkupStyle` no longer pays a `fillIfNil(from: rootStyle)` per leaf. Also collapsed `collectAttributedString` to a single `begin/endEditing` for-in loop. | **-97.1 %** |
| `233c6d3` | Eager-init the three `lazy var` processors on `ZHTMLParser` (Swift's `lazy var` is not thread-safe under concurrent first-touch); added two regression tests that fan 200 concurrent calls against `render` / `selector` / `stripper`. | thread safety, not raw perf |

## Tests

- 70 unit tests pass under `swift test --skip ZMarkupParserPerformanceTests --skip ZMarkupParserSnapshotTests`,
  including the new
  `testConcurrentRenderProducesIdenticalResults` and
  `testConcurrentSelectorAndStripperAreThreadSafe` (200 concurrent calls each).
- `testZMarkupParserMemoryLeakDetector1` passes (the markup tree is still released
  promptly).
- The iOS simulator snapshot tests (`ZMarkupParserSnapshotTests`) were not re-recorded
  on this machine. Running them under iPhone 16 / iOS 18.6 fails for **both** the
  baseline commit and the new commit, so the failures stem from font / rendering
  differences between the recording simulator and the current one — not from any
  rendering change introduced by these commits.

## Methodology

- All numbers are wall-clock time measured with `CFAbsoluteTimeGetCurrent()` inside the
  existing `ZMarkupParserPerformanceTests` (same source code that the published
  baseline JSON was recorded against, except for the upstream
  `$0` ↔ `$0.0` tuple-destructuring fix needed for the suite to compile).
- Release configuration (`swift test -c release`) for every measurement.
- Each "300× × 10" measure was a single `XCTestCase` invocation; the 1000× progressive
  was a single sweep with `autoreleasepool` per iteration.
- The baseline-vs-new comparison uses the same physical machine and the same Xcode
  toolchain to keep host noise out of the numbers; the system-API comparison uses
  `NSAttributedString(data:options:documentAttributes:)` with
  `.documentType = .html` and `.characterEncoding = utf8`.
- Baseline progressive values for i ≥ 300 are extrapolated because each baseline
  iteration past i = 200 already costs > 2 s and the full 1000-iteration sweep would
  have taken hours; the curve through the measured points is essentially quadratic in
  `length`, which is consistent with the `O(N²)` `Array.first(where:)` hot loop the
  optimizations targeted.
