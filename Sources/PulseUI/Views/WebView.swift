// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI

#if os(iOS)
import WebKit
import UIKit

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct WebView: UIViewRepresentable {
    let data: Data
    let contentType: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: .init())
        webView.load(data, mimeType: contentType, characterEncodingName: "UTF8", baseURL: FileManager.default.temporaryDirectory)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Do nothing
    }
}
#endif

#if os(macOS)
import WebKit
import AppKit

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct WebView: NSViewRepresentable {
    let data: Data
    let contentType: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: .init())
        webView.load(data, mimeType: contentType, characterEncodingName: "UTF8", baseURL: FileManager.default.temporaryDirectory)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Do nothing
    }
}
#endif
