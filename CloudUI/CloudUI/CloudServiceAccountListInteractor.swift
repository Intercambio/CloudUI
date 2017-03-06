//
//  CloudServiceAccountListInteractor.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 06.03.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CloudService

extension CloudService: AccountListInteractor {
}

private let AccountListInteractorObserver: NSObjectProtocol = {
    let center = NotificationCenter.default
    return center.addObserver(
        forName: Notification.Name.CloudServiceDidChangeAccounts,
        object: nil,
        queue: nil
    ) { notification in
        center.post(
            name: Notification.Name.AccountListInteractorDidChange,
            object: notification.object,
            userInfo: nil
        )
    }
}()
