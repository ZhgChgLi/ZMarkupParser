//
//  MarkupNSAttributedStringVisitorTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/16.
//

import XCTest
@testable import ZMarkupParser
import SnapshotTesting
import ZNSTextAttachment

final class ZHTMLToNSAttributedStringSnapshotTests: XCTestCase {
    private let record: Bool = true
    
    private let htmlString = """
        🎄🎄🎄 <Hottest> <b>Christmas gi<u>fts</b> are here</u>! <span style="font-family: 'Times New Roman', Times, serif; font-weight: bold; font-size: 16px;">Give</span> you more gift-giving inspiration~<br />
         The <u>final <del>countdown</del></u> on 12/9, NT$100 discount for all purchases over NT$1,000, plus a 12/12 one-day limited free shipping coupon<br />
         <abbr>Top 10 Popular <b><span style="color:green;">Christmas</span> Gift</b> Recommendations 👉</abbr><br>
         <ol>
         <li><a href="https://zhgchg.li">Christmas Mini Diffuser Gift Box</a>｜The first choice for exchanging gifts</li>
         <li><a href="https://zhgchg.li">German design hair remover</a>｜<strong>500</strong> yuan practical gift like this</li>
         <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
         </ol>
         <ul>
             <li style="text-decoration:underline;">Test1</li>
             <li>Test2Test2<i>Test2</i>Test2</li>
         </ul>
         <hr/>
         <table>
           <tr>
             <th>Company</th>
             <th>Contact</th>
             <th>Country</th>
           </tr>
           <tr>
             <td>Alfreds Futterkiste</td>
             <td>Maria Anders</td>
             <td>Germany</td>
           </tr>
           <tr>
             <td>Centro comercial Moctezuma</td>
             <td>Francisco Chang</td>
             <td>Mexico</td>
           </tr>
         </table>
         <hr/>
         <h1>H1zzzaabb</h1>
         <h2>H2</h2>
         <h3>H3</h3>
         <h4>H4</h4>
         <h5>H5</h5>
         <h6>H6</h6>
         <p>Before <span style="color:green;background-color:blue;font-size:18px;font-weight:bold;line-height:10;word-spacing:8px">12/26</span>, place an order and <s>draw</s> a round-trip ticket <em>for</em> two to Japan!</p>
         你好你好<span style="background-color:red">你好你好</span>你好你好 <br />
         안녕<code>하세요</code>안녕하세<span style="color:red">요안녕하세</span>요안녕하세요안녕하세요안녕하세요 <br />
         <span style="color:red">こんにちは</span>こんにちはこんにちは <br />
         <blockquote>
         blocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktextblocktext
         blocktext2
         </blockquote>
         <pre><code>
         precode
         precode2
         </code></pre>
         <div style="text-align: right;">
            ZMarkupParser is a pure-Swift library that helps you convert HTML strings into NSAttributedString with customized styles and tags.ZMarkupParser is a pure-Swift library that helps you convert HTML strings into NSAttributedString with customized styles and tags.ZMarkupParser is a pure-Swift library that helps you convert HTML strings into NSAttributedString with customized styles and tags.ZMarkupParser is a pure-Swift library that helps you convert HTML strings into NSAttributedString with customized styles and tags.ZMarkupParser is a pure-Swift library that helps you convert HTML strings into NSAttributedString with customized styles and tags.
         </div>
         &lt;font color="#008000;"&gt;Test&nbsp;XXX&lt;/font&gt;
        """
    
    var attributedHTMLString: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: htmlString)
        #if canImport(UIKit)
        attributedString.addAttributes([.foregroundColor: UIColor.orange], range: NSString(string: attributedString.string).range(of: "round-trip"))
        attributedString.addAttributes([.foregroundColor: UIColor.purple], range: NSString(string: attributedString.string).range(of: "zzzaabb"))
        #elseif canImport(AppKit)
        attributedString.addAttributes([.foregroundColor: NSColor.orange], range: NSString(string: attributedString.string).range(of: "round-trip"))
        attributedString.addAttributes([.foregroundColor: NSColor.purple], range: NSString(string: attributedString.string).range(of: "zzzaabb"))
        #endif
        return attributedString
    }
    
    #if canImport(UIKit)
    private var testAsyncImageTextView: UITextView?
    private var testAsyncXCTestExpectation: XCTestExpectation?
    
    func testAsyncImageNSAttributedString() {
        let attributedString = NSMutableAttributedString(attributedString: attributedHTMLString)
        attributedString.append(NSAttributedString(string: #"<br/><img src="https://user-images.githubusercontent.com/33706588/219608966-20e0c017-d05c-433a-9a52-091bc0cfd403.jpg"/>"#))
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.setHtmlString(attributedString, with: parser)
        
        testAsyncImageTextView = textView
        
        textView.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, textView.attributedText.string.utf16.count), options: []) { (value, effectiveRange, nil) in
            guard let attachment = value as? ZNSTextAttachment else {
                return
            }
            attachment.register(textView.textStorage)
            attachment.startDownlaod()
        }
        
        
        testAsyncXCTestExpectation = self.expectation(description: "testAsyncImageNSAttributedString")
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testShouldKeppNSAttributedString() {
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.setHtmlString(attributedHTMLString, with: parser)
        textView.layoutIfNeeded()
        assertSnapshot(matching: textView, as: .image(traits: .init(userInterfaceStyle: .light)), record: self.record)
    }
    
    func testUITextViewSetHTMLString() {
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.setHtmlString(htmlString, with: parser)
        textView.layoutIfNeeded()
        assertSnapshot(matching: textView, as: .image(traits: .init(userInterfaceStyle: .light)), record: self.record)
    }
    
    func testUITextViewSetHTMLStringAsync() {
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        let expectation = self.expectation(description: "testUITextViewSetHTMLStringAsync")
        textView.setHtmlString(htmlString, with: parser) { _ in
            textView.layoutIfNeeded()
            assertSnapshot(matching: textView, as: .image(traits: .init(userInterfaceStyle: .light)), record: self.record)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUILabelSetHTMLString() {
        let parser = makeSUT()
        let label = UILabel()
        label.frame.size.width = 390
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.setHtmlString(htmlString, with: parser)
        label.layoutIfNeeded()
        assertSnapshot(matching: label, as: .image(traits: .init(userInterfaceStyle: .light)), record: self.record)
    }
    
    func testUILabelSetHTMLStringAsync() {
        let parser = makeSUT()
        let label = UILabel()
        label.frame.size.width = 390
        label.backgroundColor = .white
        label.numberOfLines = 0
        let expectation = self.expectation(description: "testUILabelSetHTMLStringAsync")
        label.setHtmlString(htmlString, with: parser) { _ in
            label.layoutIfNeeded()
            assertSnapshot(matching: label, as: .image(traits: .init(userInterfaceStyle: .light)), record: self.record)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    #endif
}

extension ZHTMLToNSAttributedStringSnapshotTests {
    func makeSUT() -> ZHTMLParser {
        var h1Style = MarkupStyle.h1
        h1Style.fontCase = .uppercase
        var h2Style = MarkupStyle.h2
        h2Style.fontCase = .lowercase
        let parser = ZHTMLParserBuilder.initWithDefault().add(ExtendTagName(.abbr), withCustomStyle: MarkupStyle(backgroundColor: MarkupStyleColor(name: .aquamarine))).add(IMG_HTMLTagName(handler: self)).add(H1_HTMLTagName(), withCustomStyle: h1Style).add(H2_HTMLTagName(), withCustomStyle: h2Style).add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold)))).add(ExtendHTMLTagStyleAttribute(styleName: "text-decoration", render: { value in
            var newStyle = MarkupStyle()
            if value == "underline" {
                newStyle.underlineStyle = .single
            }
            return newStyle
        })).set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13), paragraphStyle: MarkupStyleParagraphStyle(lineSpacing: 8))).build()
        return parser
    }
}

extension ZHTMLToNSAttributedStringSnapshotTests: ZNSTextAttachmentDelegate, ZNSTextAttachmentDataSource {
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment, to: ZResizableNSTextAttachment) {
        #if canImport(UIKit)
        if let textView = testAsyncImageTextView {
            textView.layoutIfNeeded()
            assertSnapshot(matching: textView, as: .image(traits: .init(userInterfaceStyle: .light)), record: self.record, testName: "testAsyncImageNSAttributedString_uiTextView")
        }
        testAsyncXCTestExpectation?.fulfill()
        #endif
    }
    
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data, ZNSTextAttachmentDownloadedDataMIMEType?) -> Void) {
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            completion(data, response?.mimeType)
        }.resume()
    }
}
