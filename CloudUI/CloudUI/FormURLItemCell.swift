//
//  FormURLItemCell.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//


import UIKit

class FormURLItemCell: UITableViewCell, UITextFieldDelegate {
    
    static var predicate: NSPredicate {
        return NSPredicate(block: { (item, options) -> Bool in
            return item is FormURLItem
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
        textField.keyboardType = .URL
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
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
    
    var item: FormURLItem? {
        didSet {
            textField.placeholder = item?.placeholder
            textField.text = item?.url?.absoluteString
        }
    }
    
    // UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text,
            let url = URL(string: text) {
            setValue(url, sender: self)
        } else {
            setValue(nil, sender: self)
        }
    }
}
