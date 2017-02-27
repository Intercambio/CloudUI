//
//  ResourceDetailsModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 25.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudService

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

protocol ResourceDetailsView: class {
    var dataSource: FormDataSource? { get set }
}

class ResourceDetailsPresenter {
    let cloudService: CloudService
    init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    weak var view: ResourceDetailsView? {
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
            dataSource = ResourceDetailsDataSource(cloudService: cloudService, resource: resource)
        }
    }
    var dataSource: FormDataSource? {
        didSet {
            view?.dataSource = dataSource
        }
    }
}

class ResourceDetailsViewController: FormViewController, ResourceDetailsView {
    let presenter: ResourceDetailsPresenter
    init(presenter: ResourceDetailsPresenter) {
        self.presenter = presenter
        super.init(style: .grouped)
        self.presenter.view = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
