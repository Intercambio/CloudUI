//
//  AccountListPresenter.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import CloudService

class AccountListPresenter {
    
    var router: AccountListRouter?
    
    weak var view: AccountListView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    private let dataSource: AccountListDataSource
    
    let interactor: AccountListInteractor
    
    init(interactor: AccountListInteractor) {
        self.interactor = interactor
        dataSource = AccountListDataSource(interactor: interactor)
    }
    
    // MARK: - Actions
    
    func didSelect(itemAt indexPath: IndexPath) {
        do {
            guard
                let account = dataSource.account(at: indexPath)
            else { return }
            
            let resourceID = ResourceID(accountID: account.identifier, path: Path())
            
            if let resource = try interactor.resource(with: resourceID) {
                router?.present(resource)
            }
        } catch {
            NSLog("Failed to get resource \(error)")
        }
    }
    
    func didTapAccessoryButton(forItemAt indexPath: IndexPath) {
        guard
            let account = dataSource.account(at: indexPath)
        else { return }
        
        router?.presentSettings(for: account)
    }
    
    func addAccount() {
        router?.presentNewAccount()
    }
}
