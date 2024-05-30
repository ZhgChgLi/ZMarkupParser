//
//  ViewController.swift
//  ZMarkupParser-Demo
//
//  Created by https://zhgchg.li on 2023/2/19.
//

import UIKit
import ZMarkupParser

class ViewController: UIViewController {

    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var outputTextView: UITextView!
    
    private lazy var parser = ZHTMLParserBuilder.initWithDefault().build()
    
    @IBAction func renderBtnDidTapped(_ sender: Any) {
        let startTime = CFAbsoluteTimeGetCurrent()
        outputTextView.setHtmlString(inputTextView.text, with: parser)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        tipsLabel.text = "Time elapsed for ZHTMLParserBuilder.render\n\(String(format: "%.4f", timeElapsed)) s."
        view.endEditing(false)
    }
    
    @IBAction func pasteAndRenderBtnDidTapped(_ sender: Any) {
        inputTextView.text = UIPasteboard.general.string
        renderBtnDidTapped(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.text = """
         Powered by <span style="font-family: 'Times New Roman', Times, serif;">ZhgChgLi</span>. <br/>  <img src="https://user-images.githubusercontent.com/33706588/219608966-20e0c017-d05c-433a-9a52-091bc0cfd403.jpg"/>  🎄🎄🎄 <Hottest> <b>Christmas gi<u>fts</b> are here</u>! Give you more gift-giving inspiration~<br />
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
        
        // Do any additional setup after loading the view.
    }
}
