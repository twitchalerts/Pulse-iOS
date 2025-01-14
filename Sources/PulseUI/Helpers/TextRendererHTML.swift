// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class TextRendererHTML {
    private let html: String
    private let options: TextRenderer.Options
    private let helper: TextHelper

    init(html: String, options: TextRenderer.Options = .init()) {
        self.html = html
        self.options = options
        self.helper = TextHelper()
    }

    func render() -> NSAttributedString {
        let string = NSMutableAttributedString(string: html)
        string.addAttributes(helper.attributes(role: .body2, style: .monospaced))
        guard options.color != .monochrome else {
            return string
        }
        func makeRange(from substring: Substring) -> NSRange {
            NSRange(substring.startIndex..<substring.endIndex, in: html)
        }
        guard let tagRegex = try? RegExp("<[^>]*>"),
              let attributesRegex = try? RegExp(#"(\w*?)=(\"\w.*?\")"#) else{
            assertionFailure("Invalid regex") // Should never happen
            return string
        }
        for match in tagRegex.matches(in: html) {
            let range = makeRange(from: match.fullMatch)
            string.addAttribute(.foregroundColor, value: Palette.pink, range: range)
            for match in attributesRegex.matches(in: html, range: range) {
                if match.groups.count == 2 {
                    string.addAttribute(.foregroundColor, value: UXColor.systemOrange, range: makeRange(from: match.groups[0]))
                    string.addAttribute(.foregroundColor, value: Palette.red, range: makeRange(from: match.groups[1]))
                }
            }
        }
        return string
    }
}
