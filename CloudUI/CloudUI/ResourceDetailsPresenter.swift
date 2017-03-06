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
    init(interactor: ResourceDetailsInteractor) {
        self.interactor = interactor
        super.init()
    }
    
    weak var view: ResourceDetailsView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    var dataSource: ResourceDetailsDataSource? {
        willSet {
            dataSource?.removeObserver(self)
        }
        didSet {
            dataSource?.addObserver(self)
            view?.dataSource = dataSource
            updateDownloadButton()
        }
    }
    
    var resourceID: ResourceID? {
        didSet {
            if let resourceID = self.resourceID {
                dataSource = ResourceDetailsDataSource(interactor: interactor, resourceID: resourceID)
            } else {
                dataSource = nil
            }
        }
    }
    
    func dataSourceDidChange(_: FTDataSource!) {
        updateDownloadButton()
    }
    
    func dataSourceDidReset(_: FTDataSource!) {
        updateDownloadButton()
    }
    
    private func updateDownloadButton() {
        guard
            let resource = dataSource?.resource,
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
            let resource = dataSource?.resource
        else { return }
        interactor.downloadResource(with: resource.resourceID)
    }
}
