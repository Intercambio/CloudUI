//
//  AccountListModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudService

public protocol AccountListRouter: class {
    func present(resourceAt path: [String], of account: Account) -> Void
    func presentNewAccount() -> Void
    func presentSettings(for account: Account) -> Void
}

public class AccountListModule: UserInterfaceModule {
    
    public weak var router: AccountListRouter?
    public let cloudService: CloudService
    public init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    
    public func makeViewController() -> UIViewController {
        let viewControler = AccountListViewController()
        let presenter = AccountListPresenter(cloudService: cloudService)
        presenter.view = viewControler
        presenter.router = router
        viewControler.presenter = presenter
        return viewControler
    }
    
}
