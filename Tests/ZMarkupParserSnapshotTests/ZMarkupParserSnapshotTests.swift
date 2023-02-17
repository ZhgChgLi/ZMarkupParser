import XCTest
@testable import ZMarkupParser
import SnapshotTesting

final class ZHTMLToNSAttributedStringSnapshotTests: XCTestCase {
    
    private let htmlString = """
        🎄🎄🎄 <Hottest> <b>Christmas gi<u>fts</b> are here</u>! Give you more gift-giving inspiration~<br />
        The <u>final <del>countdown</del></u> on 12/9, NT$100 discount for all purchases over NT$1,000, plus a 12/12 one-day limited free shipping coupon<br />
        <zhgchgli>Top 10 Popular <b><span style="color:green">Christmas</span> Gift</b> Recommendations 👉</zhgchgli><br>
        <ol>
        <li><a href="https://zhgchg.li">Christmas Mini Diffuser Gift Box</a>｜The first choice for exchanging gifts</li>
        <li><a href="https://zhgchg.li">German design hair remover</a>｜<strong>500</strong> yuan practical gift like this</li>
        <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
        </ol>
        <p>Before 12/26, place an order and draw a round-trip ticket for two to Japan!</p>
        你好你好<span style="background-color:red">你好你好</span>你好你好 <br />
        안녕하세요안녕하세<span style="color:red">요안녕하세</span>요안녕하세요안녕하세요안녕하세요 <br />
        <span style="color:red">こんにちは</span>こんにちはこんにちは <br />
        """
    #if canImport(UIKit)
    func testUITextViewSetHTMLString() {
        let parser = makeSUT()
        
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.setHtmlString(htmlString, with: parser)
        textView.layoutIfNeeded()
        assertSnapshot(matching: textView, as: .image)
    }
    #elseif canImport(AppKit)
    func testNSTextViewSetHTMLString() {
        let parser = makeSUT()
        
        let textView = NSTextView()
        textView.frame.size.width = 390
        textView.backgroundColor = .white
        textView.setHtmlString(htmlString, with: parser)
        textView.layout()
        assertSnapshot(matching: textView, as: .image)
    }
    #endif
}

extension ZHTMLToNSAttributedStringSnapshotTests {
    func makeSUT() -> ZHTMLParser {
        let parser = ZHTMLParserBuilder.initWithDefault().add(ExtendTagName("zhgchgli"), withCustomStyle: MarkupStyle(backgroundColor: MarkupStyleColor(name: .aquamarine))).add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold)))).build(MarkupStyle(font: MarkupStyleFont(size: 13), paragraphStyle: MarkupStyleParagraphStyle(lineSpacing: 8)))
        return parser
    }
}
