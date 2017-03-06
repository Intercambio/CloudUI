//
//  ResourceDetailsPresenter.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 05.03.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudService
import Fountain

class ResourceDetailsPresenter: NSObject, FTDataSourceObserver {
    let interactor: ResourceDetailsInteractor
    let dataSource: ResourceDetailsDataSource
    init(interactor: ResourceDetailsInteractor) {
        self.interactor = interactor
        self.dataSource = ResourceDetailsDataSource(interactor: interactor, resource: nil)
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
    func dataSourceDidChange(_: FTDataSource!) {
        updateDownloadButton()
    }
    func dataSourceDidReset(_: FTDataSource!) {
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
            view?.actionProgress = interactor.progressForResource(with: resource.resourceID)
        case .outdated:
            view?.actionType = .update
            view?.actionProgress = interactor.progressForResource(with: resource.resourceID)
        case .valid:
            view?.actionType = .none
            view?.actionProgress = nil
        }
    }
    func download() {
        guard
            let resource = self.resource
        else { return }
        interactor.downloadResource(with: resource.resourceID)
    }
}
