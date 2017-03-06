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

extension Notification.Name {
    public static let ResourceDetailsInteractorDidChange = Notification.Name(rawValue: "ResourceDetailsInteractorDidChange")
}

public let ResourceDetailsInteractorDeletedResourcesKey = "ResourceDetailsInteractorDeletedResourcesKey"
public let ResourceDetailsInteractorInsertedOrUpdatedResourcesKey = "ResourceDetailsInteractorInsertedOrUpdatedResourcesKey"

public protocol ResourceDetailsInteractor: class {
    func resource(with resourceID: ResourceID) throws -> Resource?
    func downloadResource(with resourceID: ResourceID) -> Void
    func deleteFileForResource(with resourceID: ResourceID) throws -> Void
    func progressForResource(with resourceID: ResourceID) -> Progress?
}

extension ResourceDetailsViewController: ResourceUserInterface {
    
    private(set) var resource: Resource? {
        get {
            guard
                let resourceID = presenter.resourceID
            else { return nil }
            do {
                return try presenter.interactor.resource(with: resourceID)
            } catch {
                return nil
            }
        }
        set { presenter.resourceID = newValue?.resourceID }
    }
    
    func present(_ resource: Resource, animated _: Bool) {
        self.resource = resource
    }
}
