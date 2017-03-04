//
//  SettingsModule.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain
import CloudService

public class SettingsModule: UserInterfaceModule {
    let interactor: SettingsInteractor
    public init(interactor: SettingsInteractor) {
        self.interactor = interactor
    }
    public func makeViewController() -> UIViewController {
        let presenter = SettingsPresenter(interactor: interactor)
        return SettingsViewController(presenter: presenter)
    }
}

extension SettingsViewController: SettingsUserInterface {
    public var account: Account? {
        return presenter.account
    }
    public func presentSettings(for account: Account, animated: Bool) {
        presenter.account = account
    }
}

public protocol SettingsInteractor: class {
    func update(_ account: Account, with label: String?) throws -> Void
    func remove(_ account: Account) throws -> Void
    func password(for account: Account) -> String?
    func setPassword(_ password: String?, for account: Account)
}

extension CloudService: SettingsInteractor {
}
