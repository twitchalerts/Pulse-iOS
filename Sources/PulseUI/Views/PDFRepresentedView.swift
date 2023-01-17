// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI

#if os(iOS)
import PDFKit

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct PDFKitRepresentedView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        return pdfView
    }

    func updateUIView(_ view: PDFView, context: Context) {
        // Do nothing
    }
}
#elseif os(macOS)
import PDFKit

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct PDFKitRepresentedView: NSViewRepresentable {
    let document: PDFDocument

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateNSView(_ view: PDFView, context: Context) {
        // Do nothing
    }
}
#endif
