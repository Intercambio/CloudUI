//
//  FormTextItemCell.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//


import UIKit

class FormTextItemCell: UITableViewCell, UITextFieldDelegate {

    static var predicate: NSPredicate {
        return NSPredicate(block: { (item, options) -> Bool in
            return item is FormTextItem
        })
    }
    
    let textField: UITextField
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textField = UITextField()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .default
        
        addSubview(textField)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[textField]-|",
                                                      options: [],
                                                      metrics: [:],
                                                      views: ["textField":textField]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textField]-|",
                                                      options: [],
                                                      metrics: [:],
                                                      views: ["textField":textField]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: FormTextItem? {
        didSet {
            textField.placeholder = item?.placeholder
            textField.text = item?.text
        }
    }
    
    // UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return item?.editable ?? false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            setValue(text.characters.count > 0 ? text : nil, sender: self)
        } else {
            setValue(nil, sender: self)
        }
    }
}
