//
//  ResourceBrowserModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudStore

public class ResourceBrowserModule: NSObject, UserInterfaceModule {
    
    public var accountListModule: UserInterfaceModule?
    public var resourceListModule: UserInterfaceModule?
    public var resourceModule: UserInterfaceModule?
    
    public override init() {
    }
    
    public func makeViewController() -> UIViewController {
        guard
            let accountListViewController = accountListModule?.makeViewController()
            else {
                return UIViewController()
        }
        
        let navigationController = ResourceBrowserNavigationController(rootViewController: accountListViewController)
        navigationController.delegate = self
        return navigationController
    }
}

protocol ResourceBrowserNavigationControllerDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, viewControllerFor resource: CloudService.Resource) -> UIViewController?
}

extension ResourceBrowserModule: ResourceBrowserNavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, viewControllerFor resource: CloudService.Resource) -> UIViewController? {
        var viewController: UIViewController? = nil
        if resource.isCollection == true {
            viewController = resourceListModule?.makeViewController()
        } else {
            viewController = resourceModule?.makeViewController()
        }
        if let resourcePresenter = viewController as? ResourceUserInterface {
            resourcePresenter.present(resource, animated: false)
        }
        return viewController
    }
}

extension ResourceBrowserNavigationController: ResourceUserInterface {
    
    public var resource: CloudService.Resource? {
        guard
            let resourcePresenter = topViewController as? ResourceUserInterface
            else {
                return nil
        }
        return resourcePresenter.resource
    }
    
    public func present(_ resource: CloudService.Resource, animated: Bool) {
        guard
            let delegate = self.delegate as? ResourceBrowserNavigationControllerDelegate,
            let viewController = delegate.navigationController(self, viewControllerFor: resource)
            else {
                return
        }
        pushViewController(viewController, animated: animated)
    }
}

class ResourceBrowserNavigationController: UINavigationController {
    override func separateSecondaryViewController(for splitViewController: UISplitViewController) -> UIViewController? {
        guard
            let resourcePresenter = topViewController as? ResourceUserInterface,
            resourcePresenter.resource?.isCollection == false
            else { return nil }
        
        let viewController = topViewController
        popViewController(animated: false)
        return viewController
    }
}
