//
//  AccountListModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudStore

public protocol AccountListRouter: class {
    func present(resourceAt path: [String], of account: Account) -> Void
    func presentNewAccount() -> Void
}

public class AccountListModule: UserInterfaceModule {
    
    public weak var router: AccountListRouter?
    public let accountManager: AccountManager
    public init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    public func makeViewController() -> UIViewController {
        let viewControler = AccountListViewController()
        let presenter = AccountListPresenter(accountManager: accountManager)
        presenter.view = viewControler
        presenter.router = router
        viewControler.presenter = presenter
        return viewControler
    }
    
}
