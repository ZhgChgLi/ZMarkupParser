import Foundation

protocol ZMarkupParser {
    func render(_ string: String) -> NSAttributedString
    func render(_ attributedString: NSAttributedString) -> NSAttributedString
    func stripper(_ string: String) -> String
    func stripper(_ attributedString: NSAttributedString) -> NSAttributedString
}

