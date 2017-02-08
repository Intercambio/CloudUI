//
//  UITableViewCellAction.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

@objc protocol UITableViewDelegateCellAction: UITableViewDelegate {
    
    @objc optional func tableView(_ tableView: UITableView, setValue value: Any?, forRowAt indexPath: IndexPath) -> Void
    
}

extension UITableView {
    
    open func performAction(_ action: Selector, for cell: UITableViewCell, sender: Any?) {
        guard
            let delegate = self.delegate,
            let indexPath = indexPath(for: cell)
        else { return }
        delegate.tableView?(self, performAction: action, forRowAt: indexPath, withSender: sender)
    }
    
    open func setValue(_ value: Any?, for cell: UITableViewCell, sender: Any?) {
        guard
            let delegate = self.delegate as? UITableViewDelegateCellAction,
            let indexPath = indexPath(for: cell)
        else { return }
        delegate.tableView?(self, setValue: value, forRowAt: indexPath)
    }
    
}

extension UITableViewCell {
    
    open func performAction(_ action: Selector, sender: Any?) {
        guard
            let target = target(forAction: #selector(UITableView.performAction(_: for:sender:)), withSender: sender) as? UITableView
        else { return }
        target.performAction(action, for: self, sender: sender)
    }
    
    open func setValue(_ value: Any?, sender: Any?) {
        guard
            let target = target(forAction: #selector(UITableView.setValue(_: for:sender:)), withSender: self) as? UITableView
        else { return }
        target.setValue(value, for: self, sender: sender)
    }
    
}
