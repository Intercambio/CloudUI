//
//  SettingsModule.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain
import CloudStore

public class SettingsModule: UserInterfaceModule {
    
    let cloudService: CloudService
    public init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    
    public func makeViewController() -> UIViewController {
        let presenter = SettingsPresenter(cloudService: cloudService)
        return SettingsViewController(presenter: presenter)
    }
}

protocol SettingsView: class {
    var dataSource: FormDataSource? { get set }
}

class SettingsViewController: FormViewController, SettingsView {
    let presenter: SettingsPresenter
    init(presenter: SettingsPresenter) {
        self.presenter = presenter
        super.init(style: .grouped)
        self.presenter.view = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }
}

extension SettingsViewController: SettingsUserInterface {
    public func presentSettings(for account: CloudService.Account, animated: Bool) {
        presenter.account = account
    }
}

class SettingsPresenter {
    let cloudService: CloudService
    init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    weak var view: SettingsView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    var account: CloudService.Account? {
        didSet {
            guard
                let account = self.account
                else {
                dataSource = nil
                return
            }
            dataSource = SettingsDataSource(cloudService: cloudService, account: account)
        }
    }
    var dataSource: FormDataSource? {
        didSet {
            view?.dataSource = dataSource
        }
    }
}

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
        return ["label", "baseurl", "username", "remove"]
    }
    
    private func indexPath(for option: String) -> IndexPath? {
        if option == "label" {
            return IndexPath(item: 0, section: 0)
        } else if option == "baseurl" {
            return IndexPath(item: 0, section: 1)
        } else if option == "username" {
            return IndexPath(item: 1, section: 1)
        } else if option == "remove" {
            return IndexPath(item: 0, section: 2)
        } else {
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
        return 3
    }
    
    public func numberOfItems(inSection section: UInt) -> UInt {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 1
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
            item.instructions = "Removing the account will also delete all resoruces from this device. This will not delete the account on the server."
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
