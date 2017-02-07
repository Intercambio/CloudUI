//
//  UserInterfaceModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CloudStore

public protocol UserInterfaceModule {
    func makeViewController() -> UIViewController
}

public protocol ResourcePresenter {
    var resource: Resource? { get }
    func present(_ resource: Resource, animated: Bool) -> Void
}

public protocol PasswordPrompt {
    func requestPassword(for account: Account, completion: @escaping (String?) -> Void) -> Void
}

