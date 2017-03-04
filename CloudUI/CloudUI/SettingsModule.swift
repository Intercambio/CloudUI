//
//  SettingsModule.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

public class SettingsModule: UserInterfaceModule {
    private let interactor: SettingsInteractor
    public init(interactor: SettingsInteractor) {
        self.interactor = interactor
    }
    public func makeViewController() -> UIViewController {
        let presenter = SettingsPresenter(interactor: interactor)
        return SettingsViewController(presenter: presenter)
    }
}

extension SettingsViewController: SettingsUserInterface {
    public var accountID: AccountID? {
        return presenter.accountIdentifier
    }
    public func presentSettings(forAccountWith accountID: AccountID, animated _: Bool) {
        presenter.accountIdentifier = accountID
    }
}

public typealias SettingsKey = String

extension SettingsKey {
    public static let Label = "im.intercambio.documents.account.label"
    public static let BaseURL = "im.intercambio.documents.account.base-url"
    public static let Username = "im.intercambio.documents.account.username"
}

public protocol SettingsInteractor: class {
    func values(forAccountWith identifier: AccountID) -> [SettingsKey: Any]?
    func password(forAccountWith identifier: AccountID) -> String?
    func update(accountWith identifier: AccountID, using values: [SettingsKey: Any]) throws -> [SettingsKey: Any]?
    func setPassword(_ password: String?, forAccountWith identifier: AccountID) throws -> Void
    func remove(accountWith identifier: AccountID) throws -> Void
}
