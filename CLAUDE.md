# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ZMarkupParser is a pure-Swift library that converts HTML strings into `NSAttributedString` with customizable tag → style mappings. It targets iOS 12+ and macOS 10.14+ (per `Package.swift`; the podspec sets macOS 12.0). The only external runtime dependency is [`ZNSTextAttachment`](https://github.com/ZhgChgLi/ZNSTextAttachment), used for `<img>` rendering.

## Build & Test Commands

The project ships with both Swift Package Manager (`Package.swift`) and CocoaPods (`scripts/ZMarkupParser.podspec`). CI uses `xcodebuild` against the workspace, not `swift test` — the library is normally exercised through the workspace because the demo target lives there.

```bash
# What CI runs (see .github/workflows/ci.yml)
xcodebuild test -workspace ZMarkupParser.xcworkspace -testPlan UnitTest \
  -scheme ZMarkupParser -destination 'platform=macOS' build test | xcpretty

xcodebuild test -workspace ZMarkupParser.xcworkspace -testPlan UnitTest \
  -scheme ZMarkupParser -enableCodeCoverage YES \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0.1' build test | xcpretty

# Snapshot tests (separate workflow; will auto-commit regenerated snapshots in CI)
xcodebuild test -workspace ZMarkupParser.xcworkspace -testPlan ZMarkupParser \
  -scheme ZMarkupParser -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0.1' build test | xcpretty

# Run a single test
xcodebuild test -workspace ZMarkupParser.xcworkspace -scheme ZMarkupParser \
  -destination 'platform=macOS' \
  -only-testing:ZMarkupParserTests/ZHTMLParserTests/testRender
```

Test plans:

- `UnitTest.xctestplan` → `ZMarkupParserTests` only. This is what PR/main CI runs.
- `FullTest.xctestplan` (referenced as test plan name `ZMarkupParser`) → adds `ZMarkupParserSnapshotTests`. Only run via the manually-triggered `ci-snapshots.yml` workflow because it auto-commits regenerated snapshots back to the branch.
- `Tests/Performance.xctestplan` / `ZMarkupParserPerformanceTests` → benchmark suite, not run in regular CI.

The Swift Package can also be built directly (`swift build`, `swift test`) if you only need to touch the library target — but iOS-only APIs (`UIKit` extensions in `ZHTMLParser+UIExtension.swift`) won't compile that way.

## High-Level Architecture

The pipeline is a chain of `ParserProcessor`s (see `Core/Processor/ParserProcessor.swift` — every processor declares `From`/`To` associated types and a single `process(from:)` method). `ZHTMLParser.render(_:)` wires them in this order:

1. **`HTMLStringToParsedResultProcessor`** (`HTML/Processor/`) — Regex-tokenizes the input `NSAttributedString` into `[HTMLParsedResult]` (`.start`, `.close`, `.selfClosing`, `.rawString`). The two source-of-truth regex patterns live as `static let` on this type.
2. **`HTMLParsedResultFormatterProcessor`** — Only runs when step 1 reports `needFormatter`. Walks the token stream to autocorrect mixed/isolated tags (e.g. `<a>x<b>y</a>z</b>` → balanced tree) and downgrade unknown isolated tags into raw strings.
3. **`HTMLParsedResultToHTMLElementWithRootMarkupProcessor`** — Converts the flat token list into an AST of `Markup` nodes (rooted at `RootMarkup`) plus a parallel `[HTMLElementMarkupComponent]` for attribute lookup. The mapping from `HTMLTagName` → concrete `Markup` subclass is implemented by `HTMLTagNameToHTMLMarkupVisitor` (a `HTMLTagNameVisitor`).
4. **`HTMLElementWithMarkupToMarkupStyleProcessor`** — Resolves the final `MarkupStyle` for each node by combining: the tag's default `customStyle` from the builder, parsed `style="…"` attributes (via `HTMLTagAttributeToMarkupStyleVisitor` + the registered `HTMLTagStyleAttribute`s), `class=` lookups (`HTMLTagClassAttribute`), and `id=` lookups (`HTMLTagIdAttribute`). The `MarkupStylePolicy` controls whether HTML style attributes win over the tag's custom style.
5. **`MarkupRenderProcessor`** — Instantiates `MarkupNSAttributedStringVisitor` and walks the AST to produce the final `NSAttributedString`. `MarkupStripperProcessor` is the parallel visitor used by `parser.stripper(_:)`.

`HTMLSelector` (`HTML/Processor/HTMLSelector.swift`) exposes the AST after step 3 for jQuery-like querying; `parser.render(selector)` re-enters the pipeline at step 4.

### Two parallel Visitor hierarchies

This is the most important convention to internalize before adding tags or markup:

- **`MarkupVisitor`** (`Core/Markup/MarkupVisitor.swift`) — Operates on the AST. Each `Markup` subclass in `Core/Markup/Markups/` has a corresponding `visit(_ markup: XxxMarkup)` requirement. `MarkupNSAttributedStringVisitor` and `MarkupStripperProcessor` both conform.
- **`HTMLTagNameVisitor`** (`HTML/HTMLTag/HTMLTagNameVisitor.swift`) — Operates on tag-name objects. Each `XXX_HTMLTagName` in `HTML/HTMLTag/HTMLTagNames/` has a `visit(_ tagName: XXX_HTMLTagName)` requirement. Used to dispatch from a parsed tag to the right Markup class and to the right `MarkupStyle` defaults.

A third visitor, `HTMLTagStyleAttributeVisitor`, dispatches `style="…"` declarations (e.g. `color`, `font-size`) defined under `HTML/HTMLTag/HTMLTagStyleAttribute/HTMLTagStyleAttributes/`.

### Why HTMLString is vendored

`Sources/HTMLString/` is a copy of [alexisakers/HTMLString](https://github.com/alexisakers/HTMLString), inlined because CocoaPods cannot transitively declare that dependency. Touch it only when syncing upstream — keep the copyright comment in `HTMLString.swift` intact.

### Builder/parser entry points

`ZHTMLParserBuilder` (`HTML/ZHTMLParserBuilder.swift`) is the only public construction path. `initWithDefault()` registers the canonical tag set from `ZHTMLParserBuilder.htmlTagNames` (declared at the bottom of `HTMLTagNameVisitor.swift`) and the canonical style attribute list. `add(_:withCustomStyle:)` is dedup-by-tag-name, so re-adding a tag replaces it. `set(policy:)` toggles `MarkupStylePolicy` between honoring inline `style="…"` vs. the builder's custom style.

`ZHTMLParser`'s async overloads all funnel through a single private `ZHTMLParser.dispatchQueue` and call back on `DispatchQueue.main` — preserve that contract when extending the API.

## Conventions for Common Tasks

### Adding a new HTML tag

1. Add `Sources/ZMarkupParser/HTML/HTMLTag/HTMLTagNames/XYZ_HTMLTagName.swift` conforming to `HTMLTagName` (modeled on existing `B_HTMLTagName.swift`). It must implement `accept` to dispatch to the matching `HTMLTagNameVisitor` method.
2. Add the matching `func visit(_ tagName: XYZ_HTMLTagName) -> Result` requirement to `HTMLTagNameVisitor` and implement it in every conformer (notably `HTMLTagNameToHTMLMarkupVisitor`, which maps the tag to a `Markup`).
3. Register the tag in `ZHTMLParserBuilder.htmlTagNames` (in `HTMLTagNameVisitor.swift`) so `initWithDefault()` picks it up. `AllMarkupsHasAddToBuilderDefaultListTests` enforces this — the test will fail if you skip it.
4. If the tag needs a brand-new node type, add a `XyzMarkup.swift` under `Core/Markup/Markups/`, then add a `visit(_:)` requirement to `MarkupVisitor` and implement it in `MarkupNSAttributedStringVisitor` and `MarkupStripperProcessor`. Otherwise reuse an existing markup (e.g. most inline tags reuse `InlineMarkup` / `BoldMarkup`).

### Adding a new `style="…"` attribute

Add a class under `HTML/HTMLTag/HTMLTagStyleAttribute/HTMLTagStyleAttributes/` conforming to `HTMLTagStyleAttribute`, extend `HTMLTagStyleAttributeVisitor`, and register it in the default list (mirrors the tag flow above). `AllTagStyleAttributesHasAddToBuilderDefaultListTests` guards registration.

### `forceDecodeHTMLEntities`

`render(_:forceDecodeHTMLEntities:)` defaults to `true` and runs `decodeHTMLEntities` *before* tokenization. If you change parsing behavior, verify both branches — several callers (`UITextView`/`UILabel` `setHtmlString`) thread this flag through.

## Git / Workflow Notes

- `ci.yml` (Build & Test) runs on every PR and on `main`. Use the workspace + `UnitTest` test plan locally to mirror it.
- `ci-snapshots.yml` is `workflow_dispatch` only and force-commits regenerated snapshots back to the branch via `git-auto-commit-action`. Don't trigger it casually on a PR you don't own.
- Snapshot fixtures live under `Tests/ZMarkupParserSnapshotTests/__Snapshots__/`. Regenerate locally by deleting the relevant snapshot and re-running the snapshot test plan.
- Code coverage is uploaded to Codecov from the iOS test step (`./scripts/TestResult.xcresult`).
