//
//  CloudServiceResourceListInteractor.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 06.03.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CloudService

extension CloudService: ResourceListInteractor {
}

private let ResourceListInteractorObserver: NSObjectProtocol = {
    let center = NotificationCenter.default
    return center.addObserver(
        forName: Notification.Name.CloudServiceDidChangeResources,
        object: nil,
        queue: nil
    ) { notification in
        var userInfo: [AnyHashable: Any] = [:]
        userInfo[ResourceListInteractorDeletedResourcesKey] = notification.userInfo?[DeletedResourcesKey]
        userInfo[ResourceListInteractorInsertedOrUpdatedResourcesKey] = notification.userInfo?[InsertedOrUpdatedResourcesKey]
        center.post(
            name: Notification.Name.ResourceListInteractorDidChange,
            object: notification.object,
            userInfo: userInfo
        )
    }
}()
