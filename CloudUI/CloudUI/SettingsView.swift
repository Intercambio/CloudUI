//
//  SettingsView.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol SettingsView: class {
    var dataSource: FormDataSource? { get set }
}
