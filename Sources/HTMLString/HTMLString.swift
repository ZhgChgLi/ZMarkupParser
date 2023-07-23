import Foundation

// MARK: Escaping

// ref: https://github.com/alexisakers/HTMLString/tree/main
// Due to Cocoapods dependency issues, it is not possible to declare dependencies directly in the Pod Spec.
// Therefore, the source code has been directly included in the project, and all copyright and intellectual property rights belong to the original author at https://github.com/alexisakers/HTMLString.

extension String {

    ///
    /// Returns a copy of the current `String` where every character incompatible with HTML Unicode
    /// encoding (UTF-16 or UTF-8) is replaced by a decimal HTML entity.
    ///
    /// ### Examples
    ///
    /// | String | Result | Format |
    /// |--------|--------|--------|
    /// | `&` | `&#38;` | Decimal entity (part of the Unicode special characters) |
    /// | `Σ` | `Σ` | Not escaped (Unicode compliant) |
    /// | `🇺🇸` | `🇺🇸` | Not escaped (Unicode compliant) |
    /// | `a` | `a` | Not escaped (alphanumerical) |
    ///

    public func addingUnicodeEntities() -> String {
        var result = ""

        for character in self {
            if HTMLStringMappings.unsafeUnicodeCharacters.contains(character) {
                // One of the required escapes for security reasons
                result.append(contentsOf: "&#\(character.asciiValue!);")
            } else {
                // Not a required escape, no need to replace the character
                result.append(character)
            }
        }

        return result
    }

    ///
    /// Returns a copy of the current `String` where every character incompatible with HTML ASCII
    /// encoding is replaced by a decimal HTML entity.
    ///
    /// ### Examples
    ///
    /// | String | Result | Format |
    /// |--------|--------|--------|
    /// | `&` | `&#38;` | Decimal entity |
    /// | `Σ` | `&#931;` | Decimal entity |
    /// | `🇺🇸` | `&#127482;&#127480;` | Combined decimal entities (extented grapheme cluster) |
    /// | `a` | `a` | Not escaped (alphanumerical) |
    ///
    /// ### Performance
    ///
    /// If your webpage is unicode encoded (UTF-16 or UTF-8) use `addingUnicodeEntities` instead,
    /// as it is faster and produces a less bloated and more readable HTML.
    ///

    public func addingASCIIEntities() -> String {
        var result = ""

        for character in self {
            if let asciiiValue = character.asciiValue {
                if HTMLStringMappings.unsafeUnicodeCharacters.contains(character) {
                    // One of the required escapes for security reasons
                    result.append(contentsOf: "&#\(asciiiValue);")
                } else {
                    // Not a required escape, no need to replace the character
                    result.append(character)
                }
            } else {
                // Not an ASCII Character, we need to escape.
                let escape = character.unicodeScalars.reduce(into: "") { $0 += "&#\($1.value);" }
                result.append(contentsOf: escape)
            }
        }

        return result
    }
}

// MARK: - Unescaping

extension String {

    ///
    /// Replaces every HTML entity in the receiver with the matching Unicode character.
    ///
    /// ### Examples
    ///
    /// | String | Result | Format |
    /// |--------|--------|--------|
    /// | `&amp;` | `&` | Keyword entity |
    /// | `&#931;` | `Σ` | Decimal entity |
    /// | `&#x10d;` | `č` | Hexadecimal entity |
    /// | `&#127482;&#127480;` | `🇺🇸` | Combined decimal entities (extented grapheme cluster) |
    /// | `a` | `a` | Not an entity |
    /// | `&` | `&` | Not an entity |
    ///

    public func removingHTMLEntities() -> String {
        var result = ""
        var currentIndex = startIndex

        while let delimiterIndex = self[currentIndex...].firstIndex(of: "&") {
            // Avoid unnecessary operations
            var semicolonIndex = self.index(after: delimiterIndex)

            // Parse the last sequence (ex: Fish & chips &amp; sauce -> "&amp;" instead of "& chips &amp;")
            var lastDelimiterIndex = delimiterIndex

            while semicolonIndex != endIndex, self[semicolonIndex] != ";" {
                if self[semicolonIndex] == "&" {
                    lastDelimiterIndex = semicolonIndex
                }

                semicolonIndex = self.index(after: semicolonIndex)
            }

            // Fast path if semicolon doesn't exists in current range
            if semicolonIndex == endIndex {
                result.append(contentsOf: self[currentIndex..<semicolonIndex])
                return result
            }

            let escapableRange = index(after: lastDelimiterIndex) ..< semicolonIndex
            let escapableContent = self[escapableRange]

            result.append(contentsOf: self[currentIndex..<lastDelimiterIndex])

            let cursorPosition: Index
            if let unescapedNumber = escapableContent.unescapeAsNumber() {
                result.append(contentsOf: unescapedNumber)
                cursorPosition = self.index(semicolonIndex, offsetBy: 1)
            } else if let unescapedCharacter = HTMLStringMappings.unescapingTable[String(escapableContent)] {
                result.append(contentsOf: unescapedCharacter)
                cursorPosition = self.index(semicolonIndex, offsetBy: 1)
            } else {
                result.append(self[lastDelimiterIndex])
                cursorPosition = self.index(after: lastDelimiterIndex)
            }

            currentIndex = cursorPosition
        }

        result.append(contentsOf: self[currentIndex...])

        return result
    }
}

// MARK: - Helpers

extension StringProtocol {

    /// Unescapes the receives as a number if possible.
    fileprivate func unescapeAsNumber() -> String? {
        guard hasPrefix("#") else { return nil }

        let unescapableContent = self.dropFirst()
        let isHexadecimal = unescapableContent.hasPrefix("x") || hasPrefix("X")
        let radix = isHexadecimal ? 16 : 10

        guard let numberStartIndex = unescapableContent.index(unescapableContent.startIndex, offsetBy: isHexadecimal ? 1 : 0, limitedBy: unescapableContent.endIndex) else {
            return nil
        }

        let numberString = unescapableContent[numberStartIndex ..< endIndex]

        guard let codePoint = UInt32(numberString, radix: radix), let scalar = UnicodeScalar(codePoint) else {
            return nil
        }

        return String(scalar)
    }
}
