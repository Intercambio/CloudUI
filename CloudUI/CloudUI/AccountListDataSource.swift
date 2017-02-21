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
    
    let cloudService: CloudService
    init(cloudService: CloudService) {
        self.cloudService = cloudService
        let center = NotificationCenter.default
        super.init()
        center.addObserver(self,
                           selector: #selector(cloudServiceDidChangeAccounts(_:)),
                           name: Notification.Name.CloudServiceDidChangeAccounts,
                           object: cloudService)
        reload()
    }
    
    deinit {
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    // MARK: Notification Handling
    
    @objc private func cloudServiceDidChangeAccounts(_ notification: Notification) {
        DispatchQueue.main.async {
            self.reload()
        }
    }
    
    private var accounts: [Account] = []
    
    private func reload() {
        let accounts = cloudService.accounts
        for observer in _observers.allObjects {
            observer.dataSourceWillReset?(self)
        }
        self.accounts = accounts
        for observer in _observers.allObjects {
            observer.dataSourceDidReset?(self)
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
    
    public func numberOfItems(inSection section: UInt) -> UInt {
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
