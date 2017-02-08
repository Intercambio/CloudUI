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

extension SettingsViewController: SettingsUserInterface {
    public func presentSettings(for account: CloudService.Account, animated: Bool) {
        presenter.account = account
    }
}
