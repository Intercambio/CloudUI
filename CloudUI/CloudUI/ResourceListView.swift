//
//  ResourceListView.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

protocol ResourceListViewModel : class {
    var title: String? { get }
    var subtitle: String? { get }
}

protocol ResourceDataSource: FTDataSource {
    var title: String? { get }
    var updated: Date? { get }
}

protocol ResourceListView : class {
    var dataSource: ResourceDataSource? { get set }
    var isUpdating: Bool { get set }
}
