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
    let interactor: ResourceDetailsInteractor
    public init(interactor: ResourceDetailsInteractor) {
        self.interactor = interactor
    }
    public func makeViewController() -> UIViewController {
        let presenter = ResourceDetailsPresenter(interactor: interactor)
        let viewController = ResourceDetailsViewController(presenter: presenter)
        return viewController
    }
}

public protocol ResourceDetailsInteractor: class {
    func resource(with resourceID: ResourceID) throws -> Resource?
    func downloadResource(with resourceID: ResourceID) -> Void
    func deleteFileForResource(with resourceID: ResourceID) throws -> Void
    func progressForResource(with resourceID: ResourceID) -> Progress?
}

extension CloudService: ResourceDetailsInteractor {
}

extension ResourceDetailsViewController: ResourceUserInterface {
    private(set) var resource: Resource? {
        set { presenter.resource = newValue }
        get { return presenter.resource }
    }
    func present(_ resource: Resource, animated _: Bool) {
        self.resource = resource
    }
}
