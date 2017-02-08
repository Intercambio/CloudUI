//
//  FormButtonItemData.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//


import UIKit

class FormButtonItemData : FormButtonItem {
    
    var selectable: Bool = false
    var editable: Bool = false
    var title: String?
    var enabled: Bool = true
    var destructive: Bool = false
    var destructionMessage: String?
    
    let identifier: String
    var action: Selector
    init(identifier: String, action: Selector) {
        self.identifier = identifier
        self.action = action
    }
}
