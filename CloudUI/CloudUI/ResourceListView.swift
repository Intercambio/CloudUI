//
//  ResourceListView.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

enum ResourceListcAcessoryType {
    case none
    case download
    case update
}

protocol ResourceListViewModel : class {
    var title: String? { get }
    var subtitle: String? { get }
    var accessoryType: ResourceListcAcessoryType { get }
    var progress: Progress? { get }
}

protocol ResourceDataSource: FTMutableDataSource {
    var title: String? { get }
    var footer: String? { get }
    var isUpdating: Bool { get }
    
    func performAction(_ action: Selector, forItemAt indexPath: IndexPath) -> Void
}

protocol ResourceListView : class {
    var dataSource: ResourceDataSource? { get set }
}
