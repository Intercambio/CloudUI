//
//  ResourcePreviewModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 25.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudStore

public class ResourcePreviewModule: UserInterfaceModule {

    let cloudService: CloudService
    public init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    
    public func makeViewController() -> UIViewController {
        let presenter = ResourcePreviewPresenter(cloudService: cloudService)
        let viewController = ResourcePreviewViewController(presenter: presenter)
        return viewController
    }
}

protocol ResourcePreviewView: class {
    var resourceURL: URL? { get set }
}

class ResourcePreviewPresenter {
    let cloudService: CloudService
    init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    weak var view: ResourcePreviewView? {
        didSet {
            view?.resourceURL = resource?.remoteURL
        }
    }
    var resource: CloudService.Resource? {
        didSet {
            view?.resourceURL = resource?.remoteURL
        }
    }
    func handle(challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        guard
            let resource = self.resource,
            challenge.protectionSpace.host == resource.account.url.host
            else {
                completionHandler(.rejectProtectionSpace, nil)
                return
        }
        
        if let password = cloudService.password(for: resource.account) {
            let credentials = URLCredential(user: resource.account.username,
                                            password: password,
                                            persistence: .forSession)
            completionHandler(.useCredential, credentials)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

extension ResourcePreviewViewController: ResourceUserInterface {
    public var resource: CloudService.Resource? {
        return presenter.resource
    }
    func present(_ resource: CloudService.Resource, animated: Bool) {
        presenter.resource = resource
    }
}
