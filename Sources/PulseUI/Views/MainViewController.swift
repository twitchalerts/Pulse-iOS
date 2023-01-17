// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

#if os(iOS)

import Foundation
import UIKit
import Pulse
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public final class MainViewController: UIViewController {
    private let viewModel: ConsoleViewModel

    public static var isAutomaticAppearanceOverrideRemovalEnabled = true

    public init(store: LoggerStore = .shared, onDismiss: (() -> Void)? = nil) {
        self.viewModel = ConsoleViewModel(store: store)
        self.viewModel.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)

        if MainViewController.isAutomaticAppearanceOverrideRemovalEnabled {
            removeAppearanceOverrides()
        }
        let console = ConsoleView(viewModel: viewModel)
        let vc = UIHostingController(rootView: NavigationView { console })
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private var isAppearanceCleanupNeeded = true

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private func removeAppearanceOverrides() {
    guard isAppearanceCleanupNeeded else { return }
    isAppearanceCleanupNeeded = false

    let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [MainViewController.self])
    appearance.tintColor = nil
    appearance.barTintColor = nil
    appearance.titleTextAttributes = nil
    appearance.isTranslucent = true
}

#endif
