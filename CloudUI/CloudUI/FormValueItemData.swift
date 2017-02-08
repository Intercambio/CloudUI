//
//  FormValueItemData.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

class FormValueItemData : FormValueItem {
    
    var selectable: Bool = false
    var editable: Bool = false
    var title: String?
    var value: String?
    var icon: UIImage?
    var hasDetails: Bool = false
    
    let identifier: String
    init(identifier: String) {
        self.identifier = identifier
    }
}
