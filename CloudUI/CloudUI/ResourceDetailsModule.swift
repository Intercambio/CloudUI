//
//  ResourceDetailsModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 25.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudService
import Fountain

public class ResourceDetailsModule: UserInterfaceModule {
    let cloudService: CloudService
    public init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    public func makeViewController() -> UIViewController {
        let presenter = ResourceDetailsPresenter(cloudService: cloudService)
        let viewController = ResourceDetailsViewController(presenter: presenter)
        return viewController
    }
}

enum ResourceDetailsActionType {
    case none
    case download
    case update
}

protocol ResourceDetailsView: class {
    var dataSource: FormDataSource? { get set }
    var actionType: ResourceDetailsActionType { get set }
    var actionProgress: Progress? { get set }
}

class ResourceDetailsPresenter: NSObject, FTDataSourceObserver {
    let cloudService: CloudService
    let dataSource: ResourceDetailsDataSource
    init(cloudService: CloudService) {
        self.cloudService = cloudService
        self.dataSource = ResourceDetailsDataSource(cloudService: cloudService, resource: nil)
        super.init()
        dataSource.addObserver(self)
        updateDownloadButton()
    }
    deinit {
        dataSource.removeObserver(self)
    }
    weak var view: ResourceDetailsView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    var resource: Resource? {
        get { return dataSource.resource }
        set { dataSource.resource = newValue }
    }
    func dataSourceDidChange(_ dataSource: FTDataSource!) {
        updateDownloadButton()
    }
    func dataSourceDidReset(_ dataSource: FTDataSource!) {
        updateDownloadButton()
    }
    private func updateDownloadButton() {
        guard
            let resource = self.resource,
            resource.properties.isCollection == false
            else {
                view?.actionType = .none
                view?.actionProgress = nil
                return
        }
        
        switch resource.fileState {
        case .none:
            view?.actionType = .download
            view?.actionProgress = cloudService.progressForResource(with: resource.resourceID)
        case .outdated:
            view?.actionType = .update
            view?.actionProgress = cloudService.progressForResource(with: resource.resourceID)
        case .valid:
            view?.actionType = .none
            view?.actionProgress = nil
        }
    }
    func download() {
        guard
            let resource = self.resource
            else { return }
        cloudService.downloadResource(with: resource.resourceID)
    }
}

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
    required init?(coder aDecoder: NSCoder) {
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

extension ResourceDetailsViewController: ResourceUserInterface {
    
    private(set) var resource: Resource? {
        set { presenter.resource = newValue }
        get { return presenter.resource }
    }
    
    func present(_ resource: Resource, animated: Bool) {
        self.resource = resource
    }
}
