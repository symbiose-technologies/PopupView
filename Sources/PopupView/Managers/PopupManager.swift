//
//  PopupManager.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

public extension PopupManager {

    /// Dismisses last popup on the stack
    static func dismiss() { shared.views.perform(.removeLast) }

    /// Dismisses all popups with provided ID on the stack
    static func dismiss(id: String) { shared.views.perform(.remove(id: id)) }

    /// Dismisses all popups of provided type on the stack.
    /// ** WARNING: ** Method won't work if ID of the popup is custom
    static func dismiss<P: Popup>(_ popup: P.Type) { shared.views.perform(.remove(id: .init(describing: popup))) }

    /// Dismisses all the popups on the stack.
    static func dismissAll() { shared.views.perform(.removeAll) }
}


// MARK: - Internal
public class PopupManager: ObservableObject {
    @Published private var views: [any Popup] = []
    fileprivate var operationRecentlyPerformed: Bool = false

    static let shared: PopupManager = .init()
    private init() {}
}

extension PopupManager {
    static func show(_ popup: some Popup, withStacking shouldStack: Bool) { DispatchQueue.main.async { withAnimation(nil) { shared.views.perform(shouldStack ? .insertAndStack(popup) : .insertAndReplace(popup)) }}}
}

extension PopupManager {
    var top: [AnyPopup<TopPopupConfig>] { views.compactMap { $0 as? AnyPopup<TopPopupConfig> } }
    var centre: [AnyPopup<CentrePopupConfig>] { views.compactMap { $0 as? AnyPopup<CentrePopupConfig> } }
    var bottom: [AnyPopup<BottomPopupConfig>] { views.compactMap { $0 as? AnyPopup<BottomPopupConfig> } }
    var isEmpty: Bool { views.isEmpty }
}


// MARK: - Helpers
fileprivate extension [any Popup] {
    enum Operation {
        case insertAndReplace(any Popup), insertAndStack(any Popup)
        case removeLast, remove(id: String), removeAll
    }
}
fileprivate extension [any Popup] {
    mutating func perform(_ operation: Operation) {
        guard !PopupManager.shared.operationRecentlyPerformed else { return }

        blockOtherOperations()
        hideKeyboard()
        performOperation(operation)
        liftBlockade()
    }
}
private extension [any Popup] {
    func blockOtherOperations() {
        PopupManager.shared.operationRecentlyPerformed = true
    }
    func hideKeyboard() {
        #if os(iOS)
        UIApplication.shared.hideKeyboard()
        #endif
    }
    mutating func performOperation(_ operation: Operation) {
        switch operation {
        case .insertAndReplace(let popup):
            let replaced = replaceLastReturning(popup, if: canBeInserted(popup))
            replaced?.onDismissal()
        case .insertAndStack(let popup):
            append(popup, if: canBeInserted(popup))
        case .removeLast:
            let last = self.last
            removeLast()
            last?.onDismissal()
        case .remove(let id):
            let matching = self.filter { $0.id == id }
            removeAll(where: { $0.id == id })
            matching.forEach { $0.onDismissal() }
        case .removeAll:
            let all = self
            removeAll()
            all.forEach { $0.onDismissal() }
        }
    }
    func liftBlockade() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.44) { PopupManager.shared.operationRecentlyPerformed = false }
    }
}
private extension [any Popup] {
    func canBeInserted(_ popup: some Popup) -> Bool { !contains(where: { $0.id == popup.id }) }
}

#if os(iOS)
fileprivate extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
