//
//  FormButtonItemCell.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

class FormButtonItemCell: UITableViewCell {
    
    static var predicate: NSPredicate {
        return NSPredicate(block: { (item, _) -> Bool in
            return item is FormButtonItem
        })
    }
    
    let button: UIButton
    
    override init(style _: UITableViewCellStyle, reuseIdentifier: String?) {
        button = UIButton(type: .system)
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        
        addSubview(button)
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[button]-|",
            options: [],
            metrics: [:],
            views: ["button": button]
        ))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[button]-|",
            options: [],
            metrics: [:],
            views: ["button": button]
        ))
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: FormButtonItem? {
        didSet {
            button.setTitle(item?.title, for: .normal)
            button.isEnabled = item?.enabled ?? false
            if item?.destructive ?? false {
                button.tintColor = UIColor.red
            } else {
                button.tintColor = nil
            }
        }
    }
    
    @objc private func handleAction() {
        
        if let item = self.item {
            if item.destructive == false {
                performAction(item.action, sender: self)
            } else {
                
                let doAction = UIAlertAction(title: item.title, style: .destructive) { _ in
                    self.performAction(item.action, sender: self)
                }
                
                let cancelAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
                
                let alert = UIAlertController(title: nil, message: item.destructionMessage, preferredStyle: .alert)
                
                alert.addAction(doAction)
                alert.addAction(cancelAction)
                
                if let viewControler = window?.rootViewController?.presentedViewController {
                    viewControler.present(alert, animated: true, completion: nil)
                } else if let viewControler = window?.rootViewController {
                    viewControler.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
