//
//  SettingsDataSource.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain
import CloudService

class SettingsDataSource: NSObject, FormDataSource {
    
    let cloudService: CloudService
    var account: CloudService.Account
    private let proxy: FTObserverProxy
    public init(cloudService: CloudService, account: CloudService.Account) {
        self.cloudService = cloudService
        self.account = account
        proxy = FTObserverProxy()
        super.init()
        proxy.object = self
    }
    
    // Options
    
    var supportedKeys: [String] {
        return ["label", "baseurl", "username", "remove", "password"]
    }
    
    private func indexPath(for option: String) -> IndexPath? {
        if option == "label" {
            return IndexPath(item: 0, section: 0)
        } else if option == "baseurl" {
            return IndexPath(item: 0, section: 1)
        } else if option == "username" {
            return IndexPath(item: 1, section: 1)
        } else if option == "remove" {
            return IndexPath(item: 0, section: 3)
        } else if option == "password" {
            return IndexPath(item: 0, section: 2)
        } else  {
            return nil
        }
    }
    
    private func option(for indexPath: IndexPath) -> String? {
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0: return "label"
            default: return nil
            }
        case 1:
            switch indexPath.item {
            case 0: return "baseurl"
            case 1: return "username"
            default: return nil
            }
        case 2:
            switch indexPath.row {
            case 0: return "password"
            default: return nil
            }
        case 3:
            switch indexPath.row {
            case 0: return "remove"
            default: return nil
            }
        default:
            return nil
        }
    }
    
    // MARK: - FormDataSource
    
    func setValue(_ value: Any?, forItemAt indexPath: IndexPath) {
        defer {
            proxy.dataSource(self, didChangeItemsAtIndexPaths: [indexPath])
            proxy.dataSourceDidChange(self)
        }
        proxy.dataSourceWillChange(self)
        
        guard
            let key = option(for: indexPath)
            else { return }
        
        do {
            if key == "label" {
                guard
                    let label = value as? String?
                    else { return }
                self.account = try cloudService.update(account, with: label)
            } else if key == "password" {
                guard
                    let password = value as? String
                    else { return }
                cloudService.setPassword(password, for: account)
            }
            
        } catch {
            NSLog("Failed to update account: \(error)")
        }
    }
    
    func performAction(_ action: Selector, forItemAt _: IndexPath) {
        defer {
            proxy.dataSourceDidChange(self)
        }
        proxy.dataSourceWillChange(self)
        
        if action == #selector(removeAccount) {
            removeAccount()
        }
    }
    
    func removeAccount() {
        do {
            try cloudService.remove(account)
        } catch {
            NSLog("Failed to remove account: \(error)")
        }
    }
    
    // MARK: - FTDataSource
    
    public func numberOfSections() -> UInt {
        return 4
    }
    
    public func numberOfItems(inSection section: UInt) -> UInt {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 1
        case 3: return 1
        default: return 0
        }
    }
    
    public func sectionItem(forSection section: UInt) -> Any! {
        switch section {
        case 0:
            let item = FormSectionData()
            item.title = "Description"
            return item
        case 1:
            let item = FormSectionData()
            item.title = "Base URL & Username"
            return item
        case 2:
            let item = FormSectionData()
            item.title = "Password"
            return item
        case 3:
            let item = FormSectionData()
            item.instructions = "Removing the account will also delete all resources from this device. This will not delete the account on the server."
            return item
        default:
            return nil
        }
    }
    
    public func item(at indexPath: IndexPath!) -> Any! {
        guard
            let key = option(for: indexPath)
            else { return nil }
        switch key {
        case "label":
            let item = FormTextItemData(identifier: key)
            item.editable = true
            item.placeholder = account.url.host
            item.text = account.label
            return item
        case "baseurl":
            let item = FormURLItemData(identifier: key)
            item.editable = false
            item.placeholder = "Base URL"
            item.url = account.url
            return item
        case "username":
            let item = FormTextItemData(identifier: key)
            item.editable = false
            item.placeholder = "Username"
            item.text = account.username
            return item
        case "remove":
            let item = FormButtonItemData(identifier: key, action: #selector(removeAccount))
            item.title = "Remove Account"
            item.enabled = true
            item.destructive = true
            item.destructionMessage = "Are you sure, that you want to remove this account from the device?"
            return item
        case "password":
            let item = FormPasswordItemData(identifier: key)
            item.editable = true
            item.hasPassword = cloudService.password(for: account) != nil
            item.placeholder = item.hasPassword ? "Enter new Password" : "Enter Password"
            return item
        default:
            return nil
        }
    }
    
    func observers() -> [Any]! {
        return proxy.observers()
    }
    
    func addObserver(_ observer: FTDataSourceObserver!) {
        proxy.addObserver(observer)
    }
    
    func removeObserver(_ observer: FTDataSourceObserver!) {
        proxy.removeObserver(observer)
    }
}
