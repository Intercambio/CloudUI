//
//  UICollectionViewCellAction.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

@objc protocol UICollectionViewDelegateAction: UICollectionViewDelegate {
    
    @objc optional func collectionView(_ collectionView: UICollectionView, handle controlEvents: UIControlEvents, forItemAt indexPath: IndexPath, sender: Any?) -> Void
    
}

extension UICollectionView {
    
    open func performAction(_ action: Selector, for cell: UICollectionViewCell, sender: Any?) {
        guard
            let delegate = self.delegate,
            let indexPath = indexPath(for: cell)
        else { return }
        delegate.collectionView?(self, performAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    open func handle(_ controlEvents: UIControlEvents, for cell: UICollectionViewCell, sender: Any?) {
        guard
            let delegate = self.delegate as? UICollectionViewDelegateAction,
            let indexPath = indexPath(for: cell)
        else { return }
        delegate.collectionView?(self, handle: controlEvents, forItemAt: indexPath, sender: sender)
    }
    
}

extension UICollectionViewCell {
    
    open func performAction(_ action: Selector, sender: Any?) {
        guard
            let target = target(forAction: #selector(UICollectionView.performAction(_: for:sender:)), withSender: sender) as? UICollectionView
        else { return }
        target.performAction(action, for: self, sender: sender)
    }
    
    open func handle(_ controlEvents: UIControlEvents, sender: Any?) {
        guard
            let target = target(forAction: #selector(UICollectionView.handle(_: for:sender:)), withSender: self) as? UICollectionView
        else { return }
        target.handle(controlEvents, for: self, sender: sender)
    }
    
}
