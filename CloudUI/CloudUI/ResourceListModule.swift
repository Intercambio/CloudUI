//
//  ResourceListModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudService

public protocol ResourceListRouter: class {
    func present(_ resource: Resource) -> Void
}

public class ResourceListModule: UserInterfaceModule {
    
    public weak var router: ResourceListRouter?
    
    public let cloudService: CloudService
    public init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    
    public func makeViewController() -> UIViewController {
        let viewControler = ResourceListViewController()
        let presenter = ResourceListPresenter(cloudService: cloudService)
        presenter.view = viewControler
        presenter.router = router
        viewControler.presenter = presenter
        return viewControler
    }
}

extension ResourceListViewController: ResourceUserInterface {
    
    public var resource: Resource? {
        return presenter?.resource
    }
    
    func present(_ resource: Resource, animated _: Bool) {
        presenter?.resource = resource
    }
}
