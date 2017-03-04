//
//  FormPasswordItemCell.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 09.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

class FormPasswordItemCell: UITableViewCell, UITextFieldDelegate {
    
    static var predicate: NSPredicate {
        return NSPredicate(block: { (item, _) -> Bool in
            return item is FormPasswordItem
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
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.clearsOnBeginEditing = true
        
        addSubview(textField)
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[textField]-|",
            options: [],
            metrics: [:],
            views: ["textField": textField]
        ))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[textField]-|",
            options: [],
            metrics: [:],
            views: ["textField": textField]
        ))
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: FormPasswordItem? {
        didSet {
            textField.placeholder = item?.placeholder
            textField.text = item?.hasPassword == true ? "**********" : nil
        }
    }
    
    // UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_: UITextField) -> Bool {
        return item?.editable ?? false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text,
            text.characters.count > 0 {
            setValue(text, sender: self)
        } else {
            textField.text = item?.hasPassword == true ? "**********" : nil
        }
    }
}
