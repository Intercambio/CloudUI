//
//  SettingsDataSource.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class SettingsDataSource: NSObject, FormDataSource {
    
    let interactor: SettingsInteractor
    let accountIdentifier: String
    private var values: [String: Any]?
    
    private let proxy: FTObserverProxy
    public init(interactor: SettingsInteractor, accountIdentifier: String) {
        self.interactor = interactor
        self.accountIdentifier = accountIdentifier
        proxy = FTObserverProxy()
        super.init()
        proxy.object = self
        
        values = interactor.values(forAccountWith: accountIdentifier)
    }
    
    // Options
    
    var supportedKeys: [String] {
        return [SettingsKey.Label, SettingsKey.BaseURL, SettingsKey.Username, "remove", "password"]
    }
    
    private func indexPath(for option: String) -> IndexPath? {
        if option == SettingsKey.Label {
            return IndexPath(item: 0, section: 0)
        } else if option == SettingsKey.BaseURL {
            return IndexPath(item: 0, section: 1)
        } else if option == SettingsKey.Username {
            return IndexPath(item: 1, section: 1)
        } else if option == "remove" {
            return IndexPath(item: 0, section: 3)
        } else if option == "password" {
            return IndexPath(item: 0, section: 2)
        } else {
            return nil
        }
    }
    
    private func option(for indexPath: IndexPath) -> String? {
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0: return SettingsKey.Label
            default: return nil
            }
        case 1:
            switch indexPath.item {
            case 0: return SettingsKey.BaseURL
            case 1: return SettingsKey.Username
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
        
        var updatedValues = self.values ?? [:]
        updatedValues[key] = value
        
        do {
            if key == SettingsKey.Label {
                self.values = try interactor.update(accountWith: accountIdentifier, using: updatedValues)
            } else if key == "password" {
                guard
                    let password = value as? String
                else { return }
                try interactor.setPassword(password, forAccountWith: accountIdentifier)
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
            try interactor.remove(accountWith: accountIdentifier)
            values = nil
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
        case SettingsKey.Label: return labelItem()
        case SettingsKey.BaseURL: return baseURLItem()
        case SettingsKey.Username: return usernameItem()
        case "remove": return removeActionItem()
        case "password": return passwordItem()
        default: return nil
        }
    }
    
    private func labelItem() -> FormTextItem {
        let item = FormTextItemData(identifier: SettingsKey.Label)
        item.editable = true
        if let url = values?[SettingsKey.BaseURL] as? URL {
            item.placeholder = url.host
        }
        if let label = values?[SettingsKey.Label] as? String {
            item.text = label
        }
        return item
    }
    
    private func baseURLItem() -> FormURLItem {
        let item = FormURLItemData(identifier: SettingsKey.BaseURL)
        item.editable = false
        item.placeholder = "Base URL"
        if let url = values?[SettingsKey.BaseURL] as? URL {
            item.placeholder = url.host
        }
        return item
    }
    
    private func usernameItem() -> FormTextItem {
        let item = FormTextItemData(identifier: SettingsKey.Username)
        item.editable = true
        item.placeholder = "Username"
        if let username = values?[SettingsKey.Username] as? String {
            item.text = username
        }
        return item
    }
    
    private func removeActionItem() -> FormButtonItem {
        let item = FormButtonItemData(identifier: "remove", action: #selector(removeAccount))
        item.title = "Remove Account"
        item.enabled = true
        item.destructive = true
        item.destructionMessage = "Are you sure, that you want to remove this account from the device?"
        return item
    }
    
    private func passwordItem() -> FormPasswordItem {
        let item = FormPasswordItemData(identifier: "password")
        item.editable = true
        item.hasPassword = interactor.password(forAccountWith: accountIdentifier) != nil
        item.placeholder = item.hasPassword ? "Enter new Password" : "Enter Password"
        return item
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
