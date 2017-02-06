//
//  ResourceListModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudStore

public protocol ResourceListRouter: class {
    func present(_ resource: Resource) -> Void
}

public class ResourceListModule: UserInterfaceModule {
    
    public weak var router: ResourceListRouter?
    
    public let service: Service
    public init(service: Service) {
        self.service = service
    }
    
    public func makeViewController() -> UIViewController {
        let viewControler = ResourceListViewController()
        let presenter = ResourceListPresenter(service: service)
        presenter.view = viewControler
        presenter.router = router
        viewControler.presenter = presenter
        return viewControler
    }
}

extension ResourceListViewController: ResourcePresenter {
    
    public var resource: Resource? {
        return presenter?.resource
    }
    
    func present(_ resource: Resource, animated: Bool) {
        presenter?.resource = resource
    }
}
