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
        🎄🎄🎄 <Hottest> <b>Christmas gi<u>fts</b> are here</u>! Give you more gift-giving inspiration~<br />
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
        <p>Before <span style="color:green;background-color:blue;font-size:18px;font-weight:bold;line-height:10;word-spacing:8px">12/26</span>, place an order and draw a round-trip ticket for two to Japan!</p>
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
    
    #if canImport(UIKit)
    private var asynTextView: UITextView?
    
    func testShouldKeppNSAttributedString() {
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.setHtmlString(attributedHTMLString, with: parser)
        textView.layoutIfNeeded()
        assertSnapshot(matching: textView, as: .image, record: self.record)
    }
    
    func testAsyncImageNSAttributedString() {
        let attributedString = NSMutableAttributedString(attributedString: attributedHTMLString)
        attributedString.append(NSAttributedString(string: #"<br/><img src="https://user-images.githubusercontent.com/33706588/219608966-20e0c017-d05c-433a-9a52-091bc0cfd403.jpg"/>"#))
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.setHtmlString(attributedString, with: parser)
        
        asynTextView = textView
        let _ = self.expectation(description: "testAsyncImageNSAttributedString")
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUITextViewSetHTMLString() {
        let parser = makeSUT()
        let textView = UITextView()
        textView.frame.size.width = 390
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.setHtmlString(htmlString, with: parser)
        textView.layoutIfNeeded()
        assertSnapshot(matching: textView, as: .image, record: self.record)
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
            assertSnapshot(matching: textView, as: .image, record: self.record)
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
        assertSnapshot(matching: label, as: .image, record: self.record)
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
            assertSnapshot(matching: label, as: .image, record: self.record)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    #elseif canImport(AppKit)
    func testNSTextViewSetHTMLString() {
        let parser = makeSUT()
        
        let textView = NSTextView()
        textView.frame.size.width = 390
        textView.frame.size.height = 500
        textView.backgroundColor = .white
        textView.setHtmlString(attributedHTMLString, with: parser)
        textView.layout()
        assertSnapshot(matching: textView, as: .image, record: self.record)
    }
    
    func testNSTextViewSetHTMLStringAsync() {
        let parser = makeSUT()
        let textView = NSTextView()
        textView.frame.size.width = 390
        textView.frame.size.height = 500
        textView.backgroundColor = .white
        let expectation = self.expectation(description: "testNSTextViewSetHTMLStringAsync")
        textView.setHtmlString(attributedHTMLString, with: parser) { _ in
            textView.layout()
            assertSnapshot(matching: textView, as: .image, record: self.record)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testNSTextFieldSetHTMLString() {
        let parser = makeSUT()
        
        let textField = NSTextField()
        textField.frame.size.width = 390
        textField.frame.size.height = 500
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.setHtmlString(attributedHTMLString, with: parser)
        textField.layout()
        assertSnapshot(matching: textField, as: .image, record: self.record)
    }
    
    func testNSTextFieldSetHTMLStringAsync() {
        let parser = makeSUT()
        let textField = NSTextField()
        textField.frame.size.width = 390
        textField.frame.size.height = 500
        textField.backgroundColor = .white
        textField.textColor = .black
        let expectation = self.expectation(description: "testNSTextFieldSetHTMLStringAsync")
        textField.setHtmlString(attributedHTMLString, with: parser) { _ in
            textField.layout()
            assertSnapshot(matching: textField, as: .image, record: self.record)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    #endif
}

extension ZHTMLToNSAttributedStringSnapshotTests {
    func makeSUT() -> ZHTMLParser {
        let parser = ZHTMLParserBuilder.initWithDefault().add(ExtendTagName(.abbr), withCustomStyle: MarkupStyle(backgroundColor: MarkupStyleColor(name: .aquamarine))).add(IMG_HTMLTagName(handler: self)).add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold)))).add(ExtendHTMLTagStyleAttribute(styleName: "text-decoration", render: { value in
            var newStyle = MarkupStyle()
            if value == "underline" {
                newStyle.underlineStyle = .single
            }
            return newStyle
        })).set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13), paragraphStyle: MarkupStyleParagraphStyle(lineSpacing: 8))).build()
        return parser
    }
}

extension ZHTMLToNSAttributedStringSnapshotTests: ZNSTextAttachmentDataSource, ZNSTextAttachmentDelegate {
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data) -> Void) {
        let urlSessionDataTask = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            completion(data)
        }
        urlSessionDataTask.resume()
    }
    
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment) {
        #if canImport(UIKit)
            guard let textView = self.asynTextView else { return }
            textView.layoutIfNeeded()
            assertSnapshot(matching: textView, as: .image, record: self.record)
            self.expectation(description: "testAsyncImageNSAttributedString").fulfill()
        #elseif canImport(AppKit)
        
        #endif
    }
}

