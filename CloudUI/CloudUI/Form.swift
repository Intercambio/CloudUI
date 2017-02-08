//
//  Form.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

protocol FormItem {
    var identifier: String { get }
    var selectable: Bool { get }
    var editable: Bool { get }
}

protocol FormValueItem : FormItem {
    var title: String? { get }
    var value: String? { get }
    var icon: UIImage? { get }
    var hasDetails: Bool { get }
}

protocol FormTextItem : FormItem {
    var placeholder: String? { get }
    var text: String? { get }
}

protocol FormURLItem : FormItem {
    var placeholder: String? { get }
    var url: URL? { get }
}

protocol FormButtonItem : FormItem {
    var title: String? { get }
    var action: Selector { get }
    var enabled: Bool { get }
    var destructive: Bool { get }
    var destructionMessage: String? { get }
}

protocol FormSection {
    var title: String? { get }
    var instructions: String? { get }
}
