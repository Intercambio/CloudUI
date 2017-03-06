//
//  ResourceDetailsView.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 05.03.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation

enum ResourceDetailsActionType {
    case none
    case download
    case update
}

protocol ResourceDetailsView: class {
    var dataSource: FormDataSource? { get set }
    var actionType: ResourceDetailsActionType { get set }
    var actionProgress: Progress? { get set }
}
