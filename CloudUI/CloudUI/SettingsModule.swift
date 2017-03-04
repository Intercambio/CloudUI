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
    public func presentSettings(forAccountWith accountID: AccountID, animated: Bool) {
        presenter.accountIdentifier = accountID
    }
}

public let SettingsLabelKey = "im.intercambio.documents.account.label"
public let SettingsBaseURLKey = "im.intercambio.documents.account.base-url"
public let SettingsUsernameKey = "im.intercambio.documents.account.username"

public protocol SettingsInteractor: class {
    func values(forAccountWith identifier: AccountID) -> [String:Any]?
    func password(forAccountWith identifier: AccountID) -> String?
    func update(accountWith identifier: AccountID, using values: [String:Any]) throws -> [String:Any]?
    func setPassword(_ password: String?, forAccountWith identifier: AccountID) throws -> Void
    func remove(accountWith identifier: AccountID) throws -> Void
}
