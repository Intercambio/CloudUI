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
    func present(_ resource: Resource) -> Void
    func presentNewAccount() -> Void
    func presentSettings(for account: Account) -> Void
}

public class AccountListModule: UserInterfaceModule {
    
    public weak var router: AccountListRouter?
    public let interactor: AccountListInteractor
    public init(interactor: AccountListInteractor) {
        self.interactor = interactor
    }
    
    public func makeViewController() -> UIViewController {
        let presenter = AccountListPresenter(interactor: interactor)
        presenter.router = router
        let viewControler = AccountListViewController(presenter: presenter)
        return viewControler
    }
}

extension Notification.Name {
    public static let AccountListInteractorDidChange = Notification.Name(rawValue: "AccountListInteractorDidChange")
}

public protocol AccountListInteractor: class {
    func allAccounts() throws -> [Account]
    func resource(with resourceID: ResourceID) throws -> Resource?
}
