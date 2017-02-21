//
//  UserInterfaceModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 23.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CloudService

public protocol UserInterfaceModule {
    func makeViewController() -> UIViewController
}

public protocol ResourceUserInterface {
    var resource: Resource? { get }
    func present(_ resource: Resource, animated: Bool) -> Void
}

public protocol PasswordUserInterface {
    func requestPassword(for account: Account, completion: @escaping (String?) -> Void) -> Void
}

public protocol SettingsUserInterface {
    var account: Account? { get }
    func presentSettings(for account: Account, animated: Bool) -> Void
}
