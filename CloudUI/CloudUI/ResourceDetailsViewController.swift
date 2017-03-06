//
//  ResourceDetailsViewController.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 05.03.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class ResourceDetailsViewController: FormViewController, ResourceDetailsView {
    
    var actionType: ResourceDetailsActionType = .none {
        didSet { updateDownloadButton() }
    }
    var actionProgress: Progress? {
        didSet { updateDownloadButton() }
    }
    
    let presenter: ResourceDetailsPresenter
    init(presenter: ResourceDetailsPresenter) {
        self.presenter = presenter
        super.init(style: .grouped)
        self.presenter.view = self
    }
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDownloadButton()
    }
    private func updateDownloadButton() {
        switch actionType {
        case .none:
            navigationItem.rightBarButtonItem = nil
        case .update:
            let downloadButton = DownloadButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            downloadButton.progress = actionProgress
            downloadButton.type = .update
            downloadButton.addTarget(self, action: #selector(download), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: downloadButton)
        case .download:
            let downloadButton = DownloadButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            downloadButton.progress = actionProgress
            downloadButton.type = .download
            downloadButton.addTarget(self, action: #selector(download), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: downloadButton)
        }
    }
    @objc private func download() {
        presenter.download()
    }
}
