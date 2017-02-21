//
//  ResourceListPresenter.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CloudService

class ResourceListPresenter {
    
    var router: ResourceListRouter?
    
    weak var view: ResourceListView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    var resource: Resource? {
        didSet {
            if oldValue != resource {
                if let resource = self.resource {
                    dataSource = ResourceListDataSource(cloudService: cloudService, resource: resource)
                } else {
                    dataSource = nil
                }
            }
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
    
    func updateIfNeeded() {
        dataSource?.update(force: false)
    }
    
    func update() {
        dataSource?.update(force: true)
    }
}
