//
//  ScreenManager.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI
import Combine

#if os(iOS)
class ScreenManager: ObservableObject {
    @Published private(set) var screenSize: CGSize = UIScreen.size
    private var subscription: [AnyCancellable] = []

    init() { subscribeToScreenOrientationChangeEvents() }
}

private extension ScreenManager {
    func subscribeToScreenOrientationChangeEvents() {
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in self.screenSize = UIScreen.size }
            .store(in: &subscription)
    }
}


// MARK: - Helpers
fileprivate extension UIScreen {
    static var size: CGSize { main.bounds.size }
}
#endif

#if os(macOS)
import AppKit

class ScreenManager: ObservableObject {
    @Published private(set) var screenSize: CGSize = NSWindow.activeWindowSize
    private var subscription: AnyCancellable?
    
    init() {
        subscribeToWindowSizeChangeEvents()
    }
}

private extension ScreenManager {
    func subscribeToWindowSizeChangeEvents() {
        guard let activeWindow = NSApplication.shared.keyWindow else {
            return
        }
        subscription = NotificationCenter.default
            .publisher(for: NSWindow.didResizeNotification, object: activeWindow)
            .receive(on: DispatchQueue.main)
            .sink { _ in self.screenSize = NSWindow.activeWindowSize }
    }
}

// MARK: - Helpers
extension NSWindow {
    static var activeWindowSize: CGSize {
        return NSApplication.shared.keyWindow?.frame.size ?? CGSize.zero
    }
    
    static var activeFrame: NSRect {
        NSApplication.shared.keyWindow?.frame ?? .zero
    }
    
    static var titlebarHeight: CGFloat {
        let titlebarHeight = NSApplication.shared.keyWindow?.titlebarHeight ?? 0
        return titlebarHeight
    }
}


#endif
