//
//  FormPasswordItemData.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 09.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation

class FormPasswordItemData : FormPasswordItem {
    
    var selectable: Bool = false
    var editable: Bool = true
    var placeholder: String?
    var hasPassword: Bool = false
    
    let identifier: String
    init(identifier: String) {
        self.identifier = identifier
    }
}
