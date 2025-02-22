// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Combine

#if os(iOS) || os(macOS)
extension Color {
    static var separator: Color { Color(UXColor.separator) }
    static var indigo: Color { Color(UXColor.systemIndigo) }
    static var secondaryFill: Color { Color(UXColor.secondarySystemFill) }
}
#endif

#if os(watchOS) || os(tvOS)
extension Color {
    static var indigo: Color { .purple }
    static var separator: Color { Color.secondary.opacity(0.3) }
    static var secondaryFill: Color { Color.secondary.opacity(0.3) }
}
#endif

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension View {
    func invisible() -> some View {
        self.hidden().accessibilityHidden(true)
    }
}

extension ContentSizeCategory {
    var scale: CGFloat {
        switch self {
        case .extraSmall: return 0.7
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.0
        case .extraLarge: return 1.0
        case .extraExtraLarge: return 1.2
        case .extraExtraExtraLarge: return 1.3
        case .accessibilityMedium: return 1.4
        case .accessibilityLarge: return 1.6
        case .accessibilityExtraLarge: return 1.9
        case .accessibilityExtraExtraLarge: return 2.1
        case .accessibilityExtraExtraExtraLarge: return 2.4
        @unknown default: return 1.0
        }
    }
}

#if os(iOS)

enum Keyboard {
    static var isHidden: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in false },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in true }
        )
        .eraseToAnyPublisher()
    }
}

#endif

// MARK: - Backport


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct Backport<Content: View> {
    let content: Content
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Backport {
    @ViewBuilder
    func contextMenu<M: View, P: View>(@ViewBuilder menuItems: () -> M, @ViewBuilder preview: () -> P) -> some View {
#if !os(watchOS)
        if #available(iOS 16, tvOS 16, macOS 13, *) {
            self.content.contextMenu(menuItems: menuItems, preview: preview)
        } else {
            self.content.contextMenu(menuItems: menuItems)
        }
#else
        self.content
#endif
    }

    @ViewBuilder
    func presentationDetents(_ detents: Set<PresentationDetent>) -> some View {
#if os(iOS)
        if #available(iOS 16, *) {
            let detents = detents.map { (detent)-> SwiftUI.PresentationDetent in
                switch detent {
                case .large: return .large
                case .medium: return .medium
                }
            }
            self.content.presentationDetents(Set(detents))
        } else {
            self.content
        }
#else
        self.content
#endif
    }

    @ViewBuilder
    func monospacedDigit() -> some View {
        if #available(iOS 15, tvOS 15, *) {
            self.content.monospacedDigit()
        } else {
            self.content
        }
    }

    enum PresentationDetent {
        case large
        case medium
    }
}

extension Button {
    @ViewBuilder
    static func destructive(action: @escaping () -> Void, label: () -> Label) -> some View {
        if #available(iOS 15.0, tvOS 15, *) {
            Button(role: .destructive, action: action, label: label)
        } else {
            Button(action: action, label: label)
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension View {
    func inlineNavigationTitle(_ title: String) -> some View {
        self.navigationTitle(title)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
    }
}
