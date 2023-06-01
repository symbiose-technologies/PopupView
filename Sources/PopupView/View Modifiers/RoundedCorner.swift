//
//  RoundedCorner.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

extension View {
    func background(_ colour: Color, radius: CGFloat, corners: UIRectCorner) -> some View { background(RoundedCorner(radius: radius, corners: corners).fill(colour)) }
}

#if os(iOS)
// MARK: - Implementation
fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: .init(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif


#if os(macOS)
internal struct UIRectCorner: OptionSet {
    
    let rawValue: Int
    
    static let topLeft = UIRectCorner(rawValue: 1 << 0)
    static let topRight = UIRectCorner(rawValue: 1 << 1)
    static let bottomRight = UIRectCorner(rawValue: 1 << 2)
    static let bottomLeft = UIRectCorner(rawValue: 1 << 3)
    
    static let allCorners: UIRectCorner = [
        .topLeft,
        .topRight,
        .bottomLeft,
        .bottomRight
    ]
}

private struct RoundedCorner: Shape {
    
    var radius: CGFloat = .zero
    var corners: UIRectCorner = .allCorners
    
    // swiftlint:disable function_body_length
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let point1 = CGPoint(
            x: rect.minX,
            y: self.corners.contains(.topLeft) ? rect.minY + self.radius : rect.minY
        )
        let point2 = CGPoint(
            x: self.corners.contains(.topLeft) ? rect.minX + self.radius : rect.minX,
            y: rect.minY
        )
        let point3 = CGPoint(
            x: self.corners.contains(.topRight) ? rect.maxX - self.radius : rect.maxX,
            y: rect.minY
        )
        let point4 = CGPoint(
            x: rect.maxX,
            y: self.corners.contains(.topRight) ? rect.minY + self.radius : rect.minY
        )
        let point5 = CGPoint(
            x: rect.maxX,
            y: self.corners.contains(.bottomRight) ? rect.maxY - self.radius : rect.maxY
        )
        let point6 = CGPoint(
            x: self.corners.contains(.bottomRight) ? rect.maxX - self.radius : rect.maxX,
            y: rect.maxY
        )
        let point7 = CGPoint(
            x: self.corners.contains(.bottomLeft) ? rect.minX + self.radius : rect.minX,
            y: rect.maxY
        )
        let point8 = CGPoint(
            x: rect.minX,
            y: self.corners.contains(.bottomLeft) ? rect.maxY - self.radius : rect.maxY
        )
        
        path.move(to: point1)
        path.addArc(
            tangent1End: CGPoint(
                x: rect.minX,
                y: rect.minY
            ),
            tangent2End: point2,
            radius: self.radius
        )
        path.addLine(to: point3)
        path.addArc(
            tangent1End: CGPoint(
                x: rect.maxX,
                y: rect.minY
            ),
            tangent2End: point4,
            radius: self.radius
        )
        path.addLine(to: point5)
        path.addArc(
            tangent1End: CGPoint(
                x: rect.maxX,
                y: rect.maxY
            ),
            tangent2End: point6,
            radius: self.radius
        )
        path.addLine(to: point7)
        path.addArc(
            tangent1End: CGPoint(
                x: rect.minX,
                y: rect.maxY
            ),
            tangent2End: point8,
            radius: self.radius
        )
        path.closeSubpath()
        
        return path
    }
    // swiftlint:enable function_body_length
}
#endif
