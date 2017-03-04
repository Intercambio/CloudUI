//
//  SettingsPresenter.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation

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
    var accountIdentifier: String? {
        didSet {
            guard
                let accountIdentifier = self.accountIdentifier
                else {
                    dataSource = nil
                    return
            }
            dataSource = SettingsDataSource(interactor: interactor, accountIdentifier: accountIdentifier)
        }
    }
    var dataSource: FormDataSource? {
        didSet {
            view?.dataSource = dataSource
        }
    }
}
