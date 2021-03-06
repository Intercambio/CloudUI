//
//  FormTextItemData.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation

class FormTextItemData: FormTextItem {
    
    var selectable: Bool = false
    var editable: Bool = true
    var placeholder: String?
    var text: String?
    
    let identifier: String
    init(identifier: String) {
        self.identifier = identifier
    }
}
