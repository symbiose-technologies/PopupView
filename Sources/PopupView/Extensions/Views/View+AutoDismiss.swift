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
// Created by: Ryan Mckinney on 6/21/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI

public enum PopupViewAutoDismissal: Equatable, Hashable {
    case afterSeconds(TimeInterval)
    case disabled
}

public typealias AutoDismissAction = () -> Void


public extension View {
    /// Add auto dismiss feature to container View
    ///
    ///
    ///
    /// - Parameters:
    ///   - type: PopupViewAutoDismissal( the type of auto dismiss )
    ///   - dismissAction: dismiss closure, include dismiss current view action and the disappearAction in the container configuration and container view configuration
    /// - Returns: A view that attaches a dismissed task
    @ViewBuilder
    func autoDismisses(_ type: PopupViewAutoDismissal, dismissAction: @escaping AutoDismissAction) -> some View {
        if case .afterSeconds(let timeInterval) = type {
            self
                .task {
                    try? await Task.sleep(seconds: timeInterval)
                    if !Task.isCancelled {
                        await MainActor.run {
                            dismissAction()
                        }
                    }
                }
        } else {
            self
        }
    }
}
