//
//  AccountListDataSource.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import CloudService

class AccountListDataSource: NSObject, FTDataSource {
    
    let interactor: AccountListInteractor
    init(interactor: AccountListInteractor) {
        self.interactor = interactor
        let center = NotificationCenter.default
        super.init()
        center.addObserver(
            self,
            selector: #selector(interactorDidChange(_:)),
            name: Notification.Name.AccountListInteractorDidChange,
            object: interactor
        )
        reload()
    }
    
    deinit {
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    // MARK: Notification Handling
    
    @objc private func interactorDidChange(_: Notification) {
        DispatchQueue.main.async {
            self.reload()
        }
    }
    
    private var accounts: [Account] = []
    
    private func reload() {
        do {
            let accounts = try interactor.allAccounts()
            for observer in _observers.allObjects {
                observer.dataSourceWillReset?(self)
            }
            self.accounts = accounts
            for observer in _observers.allObjects {
                observer.dataSourceDidReset?(self)
            }
        } catch {
            NSLog("Failed to fetch accounts: \(error)")
        }
    }
    
    func account(at indexPath: IndexPath) -> Account? {
        if indexPath.section == 0 {
            return accounts[indexPath.item]
        } else {
            return nil
        }
    }
    
    // MARK: - FTDataSource
    
    public func numberOfSections() -> UInt {
        return 1
    }
    
    public func numberOfItems(inSection _: UInt) -> UInt {
        return UInt(accounts.count)
    }
    
    public func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    public func item(at indexPath: IndexPath!) -> Any! {
        if indexPath.section == 0 {
            let account = accounts[indexPath.item]
            return ViewModel(account: account)
        } else {
            return nil
        }
    }
    
    private let _observers: NSHashTable = NSHashTable<FTDataSourceObserver>.weakObjects()
    
    public func observers() -> [Any]! {
        return _observers.allObjects
    }
    
    public func addObserver(_ observer: FTDataSourceObserver!) {
        if _observers.contains(observer) == false {
            _observers.add(observer)
        }
    }
    
    public func removeObserver(_ observer: FTDataSourceObserver!) {
        _observers.remove(observer)
    }
    
    class ViewModel: AccountListViewModel {
        
        var title: String? {
            return account.label ?? account.url.host ?? account.url.absoluteString
        }
        
        var subtitle: String? {
            return nil
        }
        
        let account: Account
        
        init(account: Account) {
            self.account = account
        }
    }
}
