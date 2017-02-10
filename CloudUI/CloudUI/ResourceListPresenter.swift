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
    
    var resource: CloudService.Resource? {
        didSet {
            guard
                let resource = self.resource
                else {
                    dataSource = nil
                    return
            }
            
            dataSource = ResourceListDataSource(cloudService: cloudService, resource: resource)
        }
    }
    
    private var dataSource: ResourceListDataSource? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    let cloudService: CloudService
    
    init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    
    // MARK: - Actions
    
    func didSelect(itemAt indexPath: IndexPath) {
        guard
            let resource = dataSource?.resource(at: indexPath)
            else { return }
        router?.present(resource)
    }
    
    func update() {
        guard
            let dataSource = self.dataSource
            else { return }
        
        view?.isUpdating = true
        dataSource.update { error in
            self.view?.isUpdating = false
        }
    }
}
