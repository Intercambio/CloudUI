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
    let interactor: SettingsInteractor
    init(interactor: SettingsInteractor) {
        self.interactor = interactor
    }
    weak var view: SettingsView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    var account: Account? {
        didSet {
            guard
                let account = self.account
                else {
                    dataSource = nil
                    return
            }
            dataSource = SettingsDataSource(interactor: interactor, account: account)
        }
    }
    var dataSource: FormDataSource? {
        didSet {
            view?.dataSource = dataSource
        }
    }
}
