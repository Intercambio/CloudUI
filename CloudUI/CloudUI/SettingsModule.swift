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
    var dataSource: FTDataSource? { get set }
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
    
    var dataSource: FTDataSource? {
        didSet {
            view?.dataSource = dataSource
        }
    }
}

class SettingsDataSource: NSObject, FTDataSource {
    
    let cloudService: CloudService
    let account: CloudService.Account
    public init(cloudService: CloudService, account: CloudService.Account) {
        self.cloudService = cloudService
        self.account = account
        super.init()
    }
    
    // MARK: - FTDataSource
    
    public func numberOfSections() -> UInt {
        return 1
    }
    
    public func numberOfItems(inSection section: UInt) -> UInt {
        return 0
    }
    
    public func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    public func item(at indexPath: IndexPath!) -> Any! {
        return nil
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
}
