//
//  AccountListPresenter.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import CloudStore

class AccountListPresenter {
    
    var router: AccountListRouter?
    
    weak var view: AccountListView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    private let dataSource: AccountListDataSource
    
    let cloudService: CloudService
    
    init(cloudService: CloudService) {
        self.cloudService = cloudService
        dataSource = AccountListDataSource(cloudService: cloudService)
    }
    
    // MARK: - Actions
    
    func didSelect(itemAt indexPath: IndexPath) {
        guard
            let account = dataSource.account(at: indexPath)
            else { return }
        
        router?.present(resourceAt: [], of: account)
    }
    
    func addAccount() {
        router?.presentNewAccount()
    }
}
