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
                    <ol>
                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million
                            <ol style="list-style-type:decimal">
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                                    <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li><li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li><li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li><li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li><li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li><li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            <li><a href="https://zhgchg.li">Drink cup</a>｜Fund-raising and praise exceeded 10 million</li>
                            </ol>
                            </li>
                    </ol>
        """
        renderBtnDidTapped(inputTextView)
        // Do any additional setup after loading the view.
    }
}

