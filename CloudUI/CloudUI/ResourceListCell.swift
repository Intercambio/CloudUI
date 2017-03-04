//
//  ResourceListCell.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ResourceListCell: UITableViewCell {
    
    var model: ResourceListViewModel? {
        didSet {
            switch model?.accessoryType ?? .none {
            case .none:
                accessoryView = nil
                accessoryType = .disclosureIndicator
            case .update:
                downloadAccessoryView.type = .update
                accessoryView = downloadAccessoryView
                accessoryType = .none
            case .download:
                downloadAccessoryView.type = .download
                accessoryView = downloadAccessoryView
                accessoryType = .none
            }
            progress = model?.progress
            updateTextLabels()
        }
    }
    
    private dynamic var progress: Progress? {
        didSet {
            downloadAccessoryView.progress = progress
        }
    }
    
    private let downloadAccessoryView: DownloadButton
    private var context = "ResourceListCell.Context"
    
    override init(style _: UITableViewCellStyle, reuseIdentifier: String?) {
        downloadAccessoryView = DownloadButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        detailTextLabel?.textColor = UIColor.lightGray
        
        downloadAccessoryView.addTarget(self, action: #selector(download), for: .touchUpInside)
        
        addObserver(
            self,
            forKeyPath: "progress.localizedAdditionalDescription",
            options: [],
            context: &context
        )
    }
    
    deinit {
        removeObserver(self, forKeyPath: "progress.localizedAdditionalDescription")
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func download() {
        performAction(#selector(download), sender: self)
    }
    
    @objc private func updateTextLabels() {
        textLabel?.text = model?.title
        detailTextLabel?.text = subtitle()
    }
    
    private func subtitle() -> String? {
        if let progress = self.progress,
            progress.localizedAdditionalDescription.isEmpty == false {
            return progress.localizedAdditionalDescription
        } else {
            return model?.subtitle
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard
            context == &self.context
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        DispatchQueue.main.async {
            self.updateTextLabels()
        }
    }
}
