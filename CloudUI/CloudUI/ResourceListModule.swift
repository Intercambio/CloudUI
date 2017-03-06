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
    
    public let interactor: ResourceListInteractor
    public init(interactor: ResourceListInteractor) {
        self.interactor = interactor
    }
    
    public func makeViewController() -> UIViewController {
        let presenter = ResourceListPresenter(interactor: interactor)
        let viewControler = ResourceListViewController(presenter: presenter)
        presenter.router = router
        return viewControler
    }
}

extension Notification.Name {
    public static let ResourceListInteractorDidChange = Notification.Name(rawValue: "ResourceListInteractorDidChange")
}

public let ResourceListInteractorDeletedResourcesKey = "ResourceListInteractorDeletedResourcesKey"
public let ResourceListInteractorInsertedOrUpdatedResourcesKey = "ResourceListInteractorInsertedOrUpdatedResourcesKey"

public protocol ResourceListInteractor: class {
    func resource(with resourceID: ResourceID) throws -> Resource?
    func contentOfResource(with resourceID: ResourceID) throws -> [Resource]
    func account(with identifier: AccountID) throws -> Account?
    func updateResource(with resourceID: ResourceID, completion: ((Error?) -> Void)?)
    func downloadResource(with resourceID: ResourceID) -> Void
    func deleteFileForResource(with resourceID: ResourceID) throws
    func progressForResource(with resourceID: ResourceID) -> Progress?
}

extension ResourceListViewController: ResourceUserInterface {
    
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
