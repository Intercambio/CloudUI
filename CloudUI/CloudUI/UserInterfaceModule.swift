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

public protocol ResourceUserInterface {
    var resource: CloudService.Resource? { get }
    func present(_ resource: CloudService.Resource, animated: Bool) -> Void
}

public protocol PasswordUserInterface {
    func requestPassword(for account: CloudService.Account, completion: @escaping (String?) -> Void) -> Void
}

public protocol SettingsUserInterface {
    func presentSettings(for account: CloudService.Account, animated: Bool) -> Void
}
