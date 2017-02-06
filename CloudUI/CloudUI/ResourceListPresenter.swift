//
//  ResourceListPresenter.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CloudStore

class ResourceListPresenter {
    
    var router: ResourceListRouter?
    
    weak var view: ResourceListView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    var resource: Resource? {
        didSet {
            guard
                let resource = self.resource
                else {
                    dataSource = nil
                    return
            }
            
            let resourceManager = service.resourceManager(for: resource.account)
            dataSource = ResourceListDataSource(resourceManager: resourceManager, resource: resource)
        }
    }
    
    private var dataSource: ResourceListDataSource? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    // MARK: - Actions
    
    func didSelect(itemAt indexPath: IndexPath) {
        guard
            let resource = dataSource?.resource(at: indexPath)
            else { return }
        router?.present(resource)
    }
    
}
