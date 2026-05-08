//
//  ZMarkupParserPerformanceTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/16.
//

import XCTest
@testable import ZMarkupParser

final class ZMarkupParserPerformanceTests: XCTestCase {
    
    // has mixed tag & un close tag
    private let htmlString = """
        🎄🎄🎄 <Hottest> <b>Christmas gi<u>fts</b> are here</u>! Give you more gift-giving inspiration~<br />
        The <u>final <del>countdown</del></u> on 12/9, NT$100 discount for all purchases over NT$1,000, plus a 12/12 one-day limited free shipping coupon<br>
        Top 10 Popular <b><span style="color:green">Christmas</span> Gift</b> Recommendations
        """
    
    private var memory: Float {
        return ((Memory.memoryFootprint() ?? 0) / 1024 / 1024) // GB
    }
    
    func testZMarkupParserMemoryLeakDetector1() {
        let parsedResult = HTMLStringToParsedResultProcessor().process(from: NSAttributedString(string: htmlString))
        let markup = HTMLParsedResultToHTMLElementWithRootMarkupProcessor(htmlTags: ZHTMLParserBuilder.htmlTagNames.map({ HTMLTag(tagName: $0.0) })).process(from: parsedResult.items).markup
        
        addTeardownBlock { [weak markup] in
            XCTAssertNil(markup, "`markup` should have been deallocated. Potential memory leak!")
        }
    }
    
    func testZMarkupParserPerformance() {
        executionTimeAllowance = TimeInterval(60 * 100)
        let parser = makeSUT()
        var result:[Any] = []
        for i in 1...1000 {
            autoreleasepool {
                let longString = String(repeating: htmlString, count: i)
                let startTime = CFAbsoluteTimeGetCurrent()
                let _ = parser.render(longString)
                let time = CFAbsoluteTimeGetCurrent() - startTime
                result.append(["id": i, "length": longString.count, "time": time])
                print(i, longString.count, time)
            }
        }
        
        makeResultReport(result)
    }
    
    func testDocumentTypeHTMLPerformance() {
        executionTimeAllowance = TimeInterval(60 * 100)
        var result:[Any] = []
        for i in 1...1000 {
            autoreleasepool {
                let longString = String(repeating: htmlString, count: i)
                let startTime = CFAbsoluteTimeGetCurrent()
                let data = longString.data(using: String.Encoding.utf8)!
                let attributedOptions:[NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType :NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]
                let _ = try! NSAttributedString(data: data, options: attributedOptions, documentAttributes: nil)
                let time = CFAbsoluteTimeGetCurrent() - startTime
                result.append(["id": i, "length": longString.count, "time": time])
                print(i, longString.count, time)
            }
        }
        
        makeResultReport(result)
    }

    func testZHTMLMarkupParserMeasure() {
        let times: Int = 10
        
        let parser = makeSUT()
        var totalTime: Double = 0
        for _ in 1...times {
            autoreleasepool {
                let startTime = CFAbsoluteTimeGetCurrent()
                let _ = parser.render(String(repeating: htmlString, count: 300))
                let time = CFAbsoluteTimeGetCurrent() - startTime
                totalTime += time
            }
        }
        
        
        let avgTime = totalTime/Double(times)
        print(times, avgTime)
        makeResultReport(["Times":times, "avgTime": avgTime])
    }
    
    func testDocumentTypeHTMLMeasure() {
        let times: Int = 10

        var totalTime: Double = 0
        for _ in 1...times {
            autoreleasepool {
                let startTime = CFAbsoluteTimeGetCurrent()
                let data = String(repeating: htmlString, count: 300).data(using: String.Encoding.utf8)!
                let attributedOptions:[NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType :NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]
                let _ = try! NSAttributedString(data: data, options: attributedOptions, documentAttributes: nil)
                let time = CFAbsoluteTimeGetCurrent() - startTime
                totalTime += time
            }
        }

        let avgTime = totalTime/Double(times)
        print(times, avgTime)
        makeResultReport(["Times":times, "avgTime": avgTime])
    }

    // MARK: - Large-size sweep
    //
    // Each of these runs the same workload as the *Measure tests above
    // but at multiple input sizes. They emit a single JSON file whose
    // shape the benchmark workflow knows how to read:
    //
    //   [{ "count": Int, "length": Int, "avgTime": Double }, ...]
    //
    // `length == -1` is the sentinel for "skipped at this size" — used
    // by the DocumentType.html sweep to avoid the documented crash on
    // very large inputs.

    private static let sweepSizes: [Int] = [300, 1000]
    private static let sweepRuns: Int = 3
    private static let documentTypeMaxLength: Int = 500_000

    func testZHTMLMarkupParserSweep() {
        executionTimeAllowance = TimeInterval(60 * 60)
        let parser = makeSUT()
        var results: [[String: Any]] = []

        for count in Self.sweepSizes {
            let input = String(repeating: htmlString, count: count)
            let length = input.utf8.count
            var total: Double = 0
            for _ in 0..<Self.sweepRuns {
                autoreleasepool {
                    let start = CFAbsoluteTimeGetCurrent()
                    _ = parser.render(input)
                    total += CFAbsoluteTimeGetCurrent() - start
                }
            }
            results.append([
                "count": count,
                "length": length,
                "avgTime": total / Double(Self.sweepRuns)
            ])
        }

        makeResultReport(results)
    }

    func testDocumentTypeHTMLSweep() {
        executionTimeAllowance = TimeInterval(60 * 60)
        var results: [[String: Any]] = []

        for count in Self.sweepSizes {
            let input = String(repeating: htmlString, count: count)
            let length = input.utf8.count

            // Skip sizes known to risk a crash inside CoreFoundation's
            // HTML reader. -1 marks the entry as not-run so the workflow
            // can render an "n/a" cell.
            guard length <= Self.documentTypeMaxLength else {
                results.append([
                    "count": count,
                    "length": length,
                    "avgTime": -1.0
                ])
                continue
            }

            var total: Double = 0
            for _ in 0..<Self.sweepRuns {
                autoreleasepool {
                    let data = input.data(using: .utf8)!
                    let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ]
                    let start = CFAbsoluteTimeGetCurrent()
                    _ = try? NSAttributedString(data: data, options: opts, documentAttributes: nil)
                    total += CFAbsoluteTimeGetCurrent() - start
                }
            }
            results.append([
                "count": count,
                "length": length,
                "avgTime": total / Double(Self.sweepRuns)
            ])
        }

        makeResultReport(results)
    }
}

extension ZMarkupParserPerformanceTests {
    func makeSUT() -> ZHTMLParser {
        let parser = ZHTMLParserBuilder.initWithDefault().add(ExtendTagName("zhgchgli"), withCustomStyle: MarkupStyle(backgroundColor: MarkupStyleColor(name: .aquamarine))).add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold)))).set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13), paragraphStyle: MarkupStyleParagraphStyle(lineSpacing: 8))).build()
        return parser
    }
}
