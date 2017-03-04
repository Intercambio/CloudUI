//
//  FormValueItemCell.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

class FormValueItemCell: UITableViewCell {
    
    static var predicate: NSPredicate {
        return NSPredicate(block: { (item, _) -> Bool in
            return item is FormValueItem
        })
    }
    
    override init(style _: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: FormValueItem? {
        didSet {
            textLabel?.text = item?.title
            detailTextLabel?.text = item?.value
        }
    }
}
