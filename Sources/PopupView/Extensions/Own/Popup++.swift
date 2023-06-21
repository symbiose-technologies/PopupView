//
//  Popup++.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

public protocol TopPopup: Popup { associatedtype Config = TopPopupConfig }
public protocol CentrePopup: Popup { associatedtype Config = CentrePopupConfig }
public protocol BottomPopup: Popup { associatedtype Config = BottomPopupConfig }

struct AnyPopup<Config: Configurable>: Popup, Hashable {
    let id: String

    private let _body: AnyView
    private let _configBuilder: (Config) -> Config

    var onDismissCb: (() -> Void)?
    
    init(_ popup: some Popup) {
        self.id = popup.id
        self.onDismissCb = popup.onDismissCb
        self._body = AnyView(popup)
        self._configBuilder = popup.configurePopup as! (Config) -> Config
    }
    
    
}
extension AnyPopup {
    static func == (lhs: AnyPopup<Config>, rhs: AnyPopup<Config>) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
extension AnyPopup {
    func createContent() -> some View { _body }
    func configurePopup(popup: Config) -> Config { _configBuilder(popup) }
}

extension AnyPopup where Config == TopPopupConfig {
    func getConfig() -> TopPopupConfig {
        self.configurePopup(popup: .init())
    }
}

extension AnyPopup where Config == BottomPopupConfig {
    func getConfig() -> BottomPopupConfig {
        self.configurePopup(popup: .init())
    }
    
}

extension AnyPopup where Config == CentrePopupConfig {
    func getConfig() -> CentrePopupConfig {
        self.configurePopup(popup: .init())
    }
    
}

