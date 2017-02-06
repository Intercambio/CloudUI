//
//  AccountListView.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

protocol AccountListViewModel : class {
    var title: String? { get }
    var subtitle: String? { get }
}

protocol AccountListView : class {
    var dataSource: FTDataSource? { get set }
}
