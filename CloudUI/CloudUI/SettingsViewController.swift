//
//  SettingsViewController.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

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
        tableView.keyboardDismissMode = .interactive
    }
}
