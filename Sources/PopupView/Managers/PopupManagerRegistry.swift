//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 6/22/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI


private struct ActivePopupManagerKey: EnvironmentKey {
    static let defaultValue: String = PopupManager.ROOT_ID
}

public extension EnvironmentValues {
    var activePopupManagerId: String {
        get { self[ActivePopupManagerKey.self] }
        set { self[ActivePopupManagerKey.self] = newValue }
    }
}
public extension View {
    
    func createAndSetPopupManager(_ id: String? = nil) -> some View {
        let resolvedId = id ?? UUID().uuidString
        PopupManagerRegistry.shared.register(id: resolvedId, makeActive: true)
        return self
            .environment(\.activePopupManagerId, resolvedId)
    }
    
}


/// `PopupManagerRegistry` is a class that manages multiple instances of `PopupManager`.
/// It contains an array of `PopupManager` instances and an index to the active manager.
/// The registry always includes a root `PopupManager` which can't be unregistered.
public class PopupManagerRegistry {
    
    /// Thread-safe array of `PopupManager` instances.
    @ThreadSafe private(set) public var managers: [PopupManager]
    
    /// Index of the currently active `PopupManager` in the `managers` array.
    private var activePopupManagerIndex: Int
    
    /// Singleton instance of `PopupManagerRegistry`.
    static var shared: PopupManagerRegistry = .init()

    /// Initializes the `PopupManagerRegistry` with a root `PopupManager`.
    public init() {
        let rootPopupManager = PopupManager(id: PopupManager.ROOT_ID)
        self.managers = [rootPopupManager]
        self.activePopupManagerIndex = 0
    }
    
    /// The currently active `PopupManager`.
    /// It can't be `nil` as there is always at least one manager (the root manager) in the `managers` array.
    public var activePopupManager: PopupManager {
        get {
            return managers[activePopupManagerIndex]
        }
    }
    
    /// Creates a new `PopupManager` with the given `id` and adds it to the `managers` array.
    ///
    /// - Parameter id: The identifier for the new `PopupManager`.
    /// - Parameter makeActive: If `true`, the new `PopupManager` will be set as the active manager.
    
    public func register(id: String, makeActive: Bool) {
        let newManager = PopupManager(id: id)
        managers.append(newManager)
        if makeActive {
            activePopupManagerIndex = managers.count - 1
        }
    }
    
    /// Unregisters a `PopupManager` with the given `id` from the `managers` array.
    /// If the root manager or a non-existing manager is requested to unregister, this operation does nothing.
    ///
    /// - Parameter id: The identifier of the `PopupManager` to unregister.
    public func unregister(id: String) {
        if id != PopupManager.ROOT_ID { // Prevents unregistration of the root manager
            managers.removeAll { $0.id == id }
            if !managers.indices.contains(activePopupManagerIndex) {
                activePopupManagerIndex = 0 // Reset active manager to root if it was removed
            }
        }
    }
    
    /// Sets the active `PopupManager` to the manager with the given `id`.
    /// If no manager exists with the given `id`, this operation does nothing.
    ///
    /// - Parameter id: The identifier of the `PopupManager` to make active.
    public func setActive(id: String) {
        if let index = managers.firstIndex(where: { $0.id == id }) {
            activePopupManagerIndex = index
        }
    }
    
    /// Removes the last `PopupManager` from the `managers` array and makes the previous manager active.
    /// If only the root manager is left, this operation does nothing.
    public func popLast() {
        if managers.count > 1 {
            managers.removeLast()
            activePopupManagerIndex = managers.count - 1
        }
    }
    
    
    /// Returns the `PopupManager` with the specified ID.
    ///
    /// This method returns `nil` if no `PopupManager` with the specified ID is found.
    ///
    /// - Parameter id: The ID of the `PopupManager` to retrieve.
    /// - Returns: The `PopupManager` with the specified ID, or `nil` if no such `PopupManager` is found.
    public func manager(for id: String) -> PopupManager? {
        return managers.first { $0.id == id }
    }
    
    
}


// MARK: - Presenting and Dismissing
public extension Popup {
    /// Displays the popup. Stacks previous one
    @discardableResult
    func showAndStack(managerId: String) -> Bool {
        guard let manager = PopupManagerRegistry.shared.manager(for: managerId) else { return false }
        manager.show(AnyPopup<Config>(self), withStacking: true)
        return true
    }

    /// Displays the popup. Closes previous one
    @discardableResult
    func showAndReplace(managerId: String) -> Bool {
        guard let manager = PopupManagerRegistry.shared.manager(for: managerId) else { return false }
        manager.show(AnyPopup<Config>(self), withStacking: false)
        return true
    }
}

public extension Popup {
    /// Dismisses the last popup on the stack
    @discardableResult
    func dismiss(managerId: String) -> Bool {
        guard let manager = PopupManagerRegistry.shared.manager(for: managerId) else { return false }
        manager.dismiss()
        return true
    }

    /// Dismisses all popups of the selected type on the stack
    @discardableResult
    func dismiss<P: Popup>(_ popup: P.Type, managerId: String) -> Bool {
        guard let manager = PopupManagerRegistry.shared.manager(for: managerId) else { return false }
        manager.dismiss(popup)
        return true
    }

    /// Dismisses all popups on the stack
    @discardableResult
    func dismissAll(managerId: String) -> Bool {
        guard let manager = PopupManagerRegistry.shared.manager(for: managerId) else { return false }
        manager.dismissAll()
        return true
    }
    
    /// Dismiss self
    @discardableResult
    func dismissSelf(managerId: String) -> Bool {
        guard let manager = PopupManagerRegistry.shared.manager(for: managerId) else { return false }
        manager.dismiss(id: self.id)
        return true
    }
}
