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
// Created by: Ryan Mckinney on 5/26/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI

class SafeAreaObserver: ObservableObject {
    @Published var safeAreaInsets: EdgeInsets = EdgeInsets()

    func updateInsets(_ insets: EdgeInsets) {
        self.safeAreaInsets = insets
    }
}

#if os(macOS)
import AppKit

extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentRect(forFrameRect: frame).height
    }
}

#endif
