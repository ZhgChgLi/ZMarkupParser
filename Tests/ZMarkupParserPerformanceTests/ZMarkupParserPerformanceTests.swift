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
    
    func testZMarkupParserMemoryLeakDetector() {
        let parsedResult = HTMLStringToParsedResultProcessor().process(from: NSAttributedString(string: htmlString))
        let markup = HTMLParsedResultToRootMarkupProcessor(rootStyle: nil, htmlTags: ZHTMLParserBuilder.htmlTagNames.map({ HTMLTag(tagName: $0) }), styleAttributes: ZHTMLParserBuilder.styleAttributes).process(from: parsedResult.items)
        
        addTeardownBlock { [weak markup] in
            XCTAssertNil(markup, "`markup` should have been deallocated. Potential memory leak!")
        }
    }
    
    func testZMarkupParserPerformance() {
        let parser = makeSUT()
        var result:[Any] = []
        for i in 1...300 {
            autoreleasepool {
                let longString = String(repeating: htmlString, count: i)
                let startTime = CFAbsoluteTimeGetCurrent()
                let _ = parser.render(longString)
                let time = CFAbsoluteTimeGetCurrent() - startTime
                let memory = (Memory.memoryFootprint() ?? 0) / 1024 / 1024 // MB
                result.append(["id": i, "length": longString.count, "time": time, "memory": memory])
                print(i, longString.count, time, memory)
            }
        }
        
        makeResultReport(result)
    }
    
    func testDocumentTypeHTMLPerformance() {
        var result:[Any] = []
        for i in 1...300 {
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
                let memory = (Memory.memoryFootprint() ?? 0) / 1024 / 1024 // MB
                result.append(["id": i, "length": longString.count, "time": time, "memory": memory])
                print(i, longString.count, time, memory)
            }
        }
        
        makeResultReport(result)
    }

    func testZHTMLMarkupParserMeasure() {
        let times: Double = 10
        
        let parser = makeSUT()
        var totalTime: Double = 0
        let startMemory = (Memory.memoryFootprint() ?? 0) / 1024 / 1024 // MB
        for _ in 1...Int(times) {
            autoreleasepool {
                let startTime = CFAbsoluteTimeGetCurrent()
                let _ = parser.render(String(repeating: htmlString, count: 300))
                let time = CFAbsoluteTimeGetCurrent() - startTime
                totalTime += time
            }
        }
        
        let memory = (Memory.memoryFootprint() ?? 0) / 1024 / 1024 // MB
        let avg = totalTime/times
        print(avg, startMemory, memory)
        makeResultReport(["Times":times, "avg": avg, "startMemory": startMemory, "EndMemory": memory])
    }
    
    func testDocumentTypeHTMLMeasure() {
        let times: Double = 10
        
        var totalTime: Double = 0
        let startMemory = (Memory.memoryFootprint() ?? 0) / 1024 / 1024 // MB
        
        for _ in 1...Int(times) {
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
        
        let memory = (Memory.memoryFootprint() ?? 0) / 1024 / 1024 // MB
        let avg = totalTime/times
        print(avg, startMemory, memory)
        
        makeResultReport(["Times":times, "avg": avg, "startMemory": startMemory, "EndMemory": memory])
    }
}

extension ZMarkupParserPerformanceTests {
    func makeSUT() -> ZHTMLParser {
        let parser = ZHTMLParserBuilder.initWithDefault().add(ExtendTagName("zhgchgli"), withCustomStyle: MarkupStyle(backgroundColor: MarkupStyleColor(name: .aquamarine))).add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold)))).set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13), paragraphStyle: MarkupStyleParagraphStyle(lineSpacing: 8))).build()
        return parser
    }
}
