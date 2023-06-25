//
//  PopupView.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

struct PopupView: View {
    @StateObject private var stack: PopupManager
    @StateObject private var keyboardObserver: KeyboardManager = .init()

    let managerId: String

    
    init(managerId: String = PopupManager.ROOT_ID) {
        self.managerId = managerId
        self._stack = .init(wrappedValue: PopupManagerRegistry.shared.manager(for: managerId) ?? PopupManager.shared)
    }

    
    
    #if os(iOS)
    @StateObject private var screenObserver: ScreenManager = .init()
    var screenSize: CGSize {
        let size = screenObserver.screenSize
//        print("Screen Size: \(size)")
        return size
    }
    
    var body: some View {
        createPopupStackView()
            .background(
                createOverlay()
            )
    }
    
    #endif
    
    #if os(macOS)
    @State var geometrySize: CGSize = .zero
    var screenSize: CGSize {
        let size = geometrySize
//        print("Screen Size: \(size)")
        return size

    }
    
    var body: some View {
        GeometryReader { geo in
            
            ZStack {
                createOverlay()
                    .ignoresSafeArea()
                createPopupStackView()
            }
            .ignoresSafeArea()
                .onAppear {
                    geometrySize = geo.size
//                    print("onAppear geometrySize: \(geometrySize)")
                }
                .onChange(of: geo.size, perform: { newValue in
//                    print("onChange geometrySize: \(newValue)")
                    geometrySize = newValue
                })
        }
        .ignoresSafeArea()

    }
    
    
    #endif
    
    
    
    
}

private extension PopupView {
    func createPopupStackView() -> some View {
        ZStack {
            createTopPopupStackView()
            createCentrePopupStackView()
            createBottomPopupStackView()
        }
    }
    #if os(iOS)
    func createOverlay() -> some View {
        overlayColour
            .frame(size: screenSize)
            .ignoresSafeArea()
            .visible(if: !stack.isEmpty)
            .animation(overlayAnimation, value: stack.isEmpty)
    }
    #endif
    
    #if os(macOS)
    func createOverlay() -> some View {
        overlayColour
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .opacity(stack.isEmpty ? 0 : 1)
            .animation(overlayAnimation, value: stack.isEmpty)
    }
    #endif
}

private extension PopupView {
    func createTopPopupStackView() -> some View {
        PopupTopStackView(items: stack.top, screenSize: screenSize)
    }
    func createCentrePopupStackView() -> some View {
        PopupCentreStackView(items: stack.centre, screenSize: screenSize)
    }
    func createBottomPopupStackView() -> some View {
        PopupBottomStackView(items: stack.bottom,
                             keyboardHeight: keyboardObserver.keyboardHeight,
                             screenSize: screenSize)
    }
}

private extension PopupView {
    var overlayColour: Color { .black.opacity(0.44) }
    
    var overlayAnimation: Animation { .easeInOut }
}
