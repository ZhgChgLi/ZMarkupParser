import XCTest
@testable import ZMarkupParser
import SnapshotTesting

final class ZHTMLToNSAttributedStringSnapshotTests: XCTestCase {
    
    private let testPerformance: Bool = false
    
    private let htmlString = """
        🎄🎄🎄 <Hottest> <b>Christmas gi<u>fts</b> are here</u>! Give you more gift-giving inspiration~<br />
        The <u>final <del>countdown</del></u> on 12/9, NT$100 discount for all purchases over NT$1,000, plus a 12/12 one-day limited free shipping coupon<br />
        <zhgchgli>Top 10 Popular <b><span style="color:green">Christmas</span> Gift</b> Recommendations 👉</zhgchgli><br>
        <ol>
        <li><a href="https://zhgchg.li">Christmas Mini Diffuser Gift Box</a>｜The first choice for exchanging gifts</li>
        <li><a href="https://zhgchg.li">German design hair remover</a>｜<strong>500</strong> yuan practical gift like this</li>
        <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
        </ol>
        <hr/>
        <p>Before 12/26, place an order and draw a round-trip ticket for two to Japan!</p>
        你好你好<span style="background-color:red">你好你好</span>你好你好 <br />
        안녕하세요안녕하세<span style="color:red">요안녕하세</span>요안녕하세요안녕하세요안녕하세요 <br />
        <span style="color:red">こんにちは</span>こんにちはこんにちは <br />
        """
    
    var attributedHTMLString: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: htmlString)
        #if canImport(UIKit)
        attributedString.addAttributes([.foregroundColor: UIColor.orange], range: NSString(string: attributedString.string).range(of: "round-trip"))
        #elseif canImport(AppKit)
        attributedString.addAttributes([.foregroundColor: NSColor.orange], range: NSString(string: attributedString.string).range(of: "round-trip"))
        #endif
        return attributedString
    }
    
    func testPerformanceReport() {
        if !testPerformance {
            return
        }
        
        let parser = makeSUT()
        for i in 1...1000 {
            let longString = String(repeating: htmlString, count: i)
            var startTime = CFAbsoluteTimeGetCurrent()
            let _ = parser.render(longString)
            let r1 = CFAbsoluteTimeGetCurrent() - startTime
            
            startTime = CFAbsoluteTimeGetCurrent()
            let data = longString.data(using: String.Encoding.utf8)!
            let attributedOptions:[NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType :NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            let _ = try! NSAttributedString(data: data, options: attributedOptions, documentAttributes: nil)
            let r2 = CFAbsoluteTimeGetCurrent() - startTime
            
            print(longString.count, r1, r2 ,(r1 < r2) ? ("✅") : ("❌"))
        }
    }

    func testMeasureZHTMLMarkupParser() {
        if !testPerformance {
            return
        }
        
        let parser = makeSUT()
        measure {
            let _ = parser.render(String(repeating: htmlString, count: 300))
        }
    }
    
    func testMeasureNativeDocumentTypeHTML() {
        if !testPerformance {
            return
        }
        
        measure {
            let data = String(repeating: htmlString, count: 300).data(using: String.Encoding.utf8)!
            let attributedOptions:[NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType :NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            let _ = try! NSAttributedString(data: data, options: attributedOptions, documentAttributes: nil)
        }
    }
    
    #if canImport(UIKit)
    func testUITextViewSetHTMLString() {
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.setHtmlString(attributedHTMLString, with: parser)
        textView.layoutIfNeeded()
        assertSnapshot(matching: textView, as: .image)
    }
    
    func testUITextViewSetHTMLStringAsync() {
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        let expectation = self.expectation(description: "testUITextViewSetHTMLStringAsync")
        textView.setHtmlString(attributedHTMLString, with: parser) { _ in
            textView.layoutIfNeeded()
            assertSnapshot(matching: textView, as: .image)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    #elseif canImport(AppKit)
    func testNSTextViewSetHTMLString() {
        let parser = makeSUT()
        
        let textView = NSTextView()
        textView.frame.size.width = 390
        textView.backgroundColor = .white
        textView.setHtmlString(attributedHTMLString, with: parser)
        textView.layout()
        assertSnapshot(matching: textView, as: .image)
    }
    
    func testNSTextViewSetHTMLStringAsync() {
        let parser = makeSUT()
        let textView = NSTextView()
        textView.frame.size.width = 390
        textView.backgroundColor = .white
        let expectation = self.expectation(description: "testUITextViewSetHTMLStringAsync")
        textView.setHtmlString(attributedHTMLString, with: parser) { _ in
            textView.layout()
            assertSnapshot(matching: textView, as: .image)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    #endif
}

extension ZHTMLToNSAttributedStringSnapshotTests {
    func makeSUT() -> ZHTMLParser {
        let parser = ZHTMLParserBuilder.initWithDefault().add(ExtendTagName("zhgchgli"), withCustomStyle: MarkupStyle(backgroundColor: MarkupStyleColor(name: .aquamarine))).add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold)))).set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13), paragraphStyle: MarkupStyleParagraphStyle(lineSpacing: 8))).build()
        return parser
    }
}
