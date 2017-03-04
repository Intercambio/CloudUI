//
//  MainModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudService

public class MainModule: UserInterfaceModule {
    
    public var resourceBrowserModule: UserInterfaceModule?
    public var resourceDetailsModule: UserInterfaceModule?
    public var settingsModule: UserInterfaceModule?
    
    let cloudService: CloudService
    public init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    
    public func makeViewController() -> UIViewController {
        guard
            let resourceBrowserViewController = resourceBrowserModule?.makeViewController()
            else {
                return UIViewController()
        }

        let splitViewController = MainViewController(cloudService: cloudService)
        splitViewController.delegate = self
        splitViewController.presentsWithGesture = true
        splitViewController.viewControllers = [
            resourceBrowserViewController
        ]
        splitViewController.preferredDisplayMode = .allVisible
        
        return splitViewController
    }
    
}

protocol MainViewControllerDelegate: UISplitViewControllerDelegate {
    func mainViewController(_ mainViewController: MainViewController, detailViewControllerFor resource: Resource) -> UIViewController?
    func mainViewController(_ mainViewController: MainViewController, settingsViewControllerForAccountWith accountID: AccountID) -> UIViewController?
}

class MainViewController: UISplitViewController {
    
    let cloudService: CloudService
    init(cloudService: CloudService) {
        self.cloudService = cloudService
        super.init(nibName: nil, bundle: nil)
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(cloudServiceDidRemoveAccount(_:)),
                           name: Notification.Name.CloudServiceDidRemoveAccount,
                           object: cloudService)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    @objc private func cloudServiceDidRemoveAccount(_ notification: Notification) {
        DispatchQueue.main.async {
            guard
                let accountID = notification.userInfo?[AccountIDKey] as? AccountID
                else { return }
            
            if self.accountID == accountID {
                self.dismissSettings()
            }
        }
    }
}

extension MainModule: MainViewControllerDelegate {
    
    func mainViewController(_ mainViewController: MainViewController, settingsViewControllerForAccountWith accountID: AccountID) -> UIViewController? {
        guard
            let settingsViewController = settingsModule?.makeViewController()
            else { return nil }
        
        if let settingsUserInterface = settingsViewController as? SettingsUserInterface {
            settingsUserInterface.presentSettings(forAccountWith: accountID, animated: false)
        }
        return settingsViewController
    }
    
    func mainViewController(_ mainViewController: MainViewController, detailViewControllerFor resource: Resource) -> UIViewController? {
        var viewController: UIViewController? = nil
        if resource.properties.isCollection == false {
            viewController = resourceDetailsModule?.makeViewController()
        }
        if let resourcePresenter = viewController as? ResourceUserInterface {
            resourcePresenter.present(resource, animated: false)
        }
        return viewController
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if let viewController = primaryViewController.separateSecondaryViewController(for: splitViewController) {
            viewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            let navigationController = UINavigationController(rootViewController: viewController)
            return navigationController
        } else {
            return nil
        }
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard
            let primaryResourcePresenter = primaryViewController as? ResourceUserInterface,
            let secondaryResourcePresenter  = secondaryViewController as? ResourceUserInterface,
            let resource = secondaryResourcePresenter.resource
        else {
            return true
        }
        
        primaryResourcePresenter.present(resource, animated: false)
        return true
    }
}

extension MainViewController: ResourceUserInterface {
    
    public var resource: Resource? {
        guard
            let resourcePresenter = viewControllers.first as? ResourceUserInterface
            else { return nil }
        
        return resourcePresenter.resource
    }
    
    public func present(_ resource: Resource, animated: Bool) {
        guard
            let delegate = self.delegate as? MainViewControllerDelegate,
            let resourcePresenter = viewControllers.first as? ResourceUserInterface
            else { return }
        
        if isCollapsed == false, let detailViewController = delegate.mainViewController(self, detailViewControllerFor: resource) {
            let navigationController = UINavigationController(rootViewController: detailViewController)
            detailViewController.navigationItem.leftBarButtonItem = displayModeButtonItem
            showDetailViewController(navigationController, sender: nil)
        } else {
            resourcePresenter.present(resource, animated: animated)
        }
    }
}

extension MainViewController: PasswordUserInterface {
    
    public func requestPassword(for account: Account, completion: @escaping (String?) -> Void) {
        
        let title = "Login"
        let message = "Password for '\(account.username)' at '\(account.url.absoluteString)'"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Password", comment: "")
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.isSecureTextEntry = true
        }
        
        let loginAction = UIAlertAction(title: NSLocalizedString("Login", comment: ""), style: .default) {
            action in
            let password = alert.textFields?.last?.text
            completion(password)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {
            action in
            
            completion(nil)
        }
        
        alert.addAction(loginAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension MainViewController: SettingsUserInterface {
    
    public var accountID: AccountID? {
        guard
            let navigationController = presentedViewController as? UINavigationController,
            let settingsUserInterface = navigationController.viewControllers.first as? SettingsUserInterface
            else { return nil }
        
        return settingsUserInterface.accountID
    }
    
    public func presentSettings(forAccountWith accountID: AccountID, animated: Bool) {
        guard
            let delegate = self.delegate as? MainViewControllerDelegate,
            let settingsViewController = delegate.mainViewController(self, settingsViewControllerForAccountWith: accountID)
            else { return }
        
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        settingsViewController.navigationItem.leftBarButtonItem = dismissButton
        
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .formSheet
        
        present(navigationController, animated: animated, completion: nil)
    }
    
    func dismissSettings() {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
