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
    
    private var dataSource: ResourceListDataSource? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    var resourceID: ResourceID? {
        didSet {
            if oldValue != resourceID {
                if let resourceID = self.resourceID {
                    dataSource = ResourceListDataSource(interactor: interactor, resourceID: resourceID)
                } else {
                    dataSource = nil
                }
            }
        }
    }
    
    let interactor: ResourceListInteractor
    
    init(interactor: ResourceListInteractor) {
        self.interactor = interactor
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
