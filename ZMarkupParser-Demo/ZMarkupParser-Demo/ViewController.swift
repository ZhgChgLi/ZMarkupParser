//
//  ViewController.swift
//  ZMarkupParser-Demo
//
//  Created by ZhgChgLi on 2023/2/19.
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}

