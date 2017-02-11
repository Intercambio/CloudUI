//
//  SettingsPresenter.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CloudService

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

