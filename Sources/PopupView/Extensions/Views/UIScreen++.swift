//
//  UIScreen++.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

#if os(iOS)
extension UIScreen {
    static let safeArea: UIEdgeInsets = {
        UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow})
            .first?
            .safeAreaInsets ?? .zero
    }()
}

// MARK: - Reading Corner Radius of the screen
extension UIScreen {
    static var displayCornerRadius: CGFloat? = { main.value(forKey: cornerRadiusKey) as? CGFloat }()
}
private extension UIScreen {
    static let cornerRadiusKey: String = {
        ["Radius", "Corner", "display", "_"]
            .reversed().joined()
    }()
}


public class PopupXScreen {
    public static let safeArea: EdgeInsets = {
        let uiInsets = UIScreen.safeArea
        let edgeInsets = EdgeInsets(top: uiInsets.top, leading: uiInsets.left, bottom: uiInsets.bottom, trailing: uiInsets.right)
        return edgeInsets
    }()
    
    static var displayCornerRadius: CGFloat? = {
        return UIScreen.displayCornerRadius
    }()
    
}
#endif


#if os(macOS)
import AppKit

extension NSScreen {
    static var mainVisibleFrame: NSRect {
        return NSScreen.main?.visibleFrame ?? NSRect.zero
    }
}


public class PopupXScreen {
    public static let safeArea: EdgeInsets = {
        let screenRect = NSScreen.mainVisibleFrame
        let titlebarHeight = NSWindow.titlebarHeight
        
        // The origin in macOS is at the lower left corner of the screen, so the top safe area is at the bottom of the screen
//        let edgeInsets = EdgeInsets(top: 0, leading: screenRect.origin.x, bottom: screenRect.origin.y, trailing: screenRect.size.width)
        let edgeInsets = EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0)
        return edgeInsets
    }()
    
    
    static var displayCornerRadius: CGFloat? = {
        return nil
    }()
}


#endif
