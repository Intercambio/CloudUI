//
//  ResourceListDataSource.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import CloudStore

class ResourceListDataSource: NSObject, ResourceDataSource {
    
    private let backingStore: FTMutableSet
    private(set) var resource: CloudService.Resource? {
        didSet {
            reload()
        }
    }
    
    let cloudService: CloudService
    init(cloudService: CloudService, resource: CloudService.Resource) {
        self.cloudService = cloudService
        self.resource = resource
        let sortDescriptior = NSSortDescriptor(key: "self", ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard
                let lhResource = lhs as? CloudService.Resource,
                let rhResource = rhs as? CloudService.Resource,
                let lhName = lhResource.path.last,
                let rhName = rhResource.path.last
                else { return .orderedSame }
            if lhName < rhName {
                return .orderedAscending
            } else if lhName > rhName {
                return .orderedDescending
            } else {
                return .orderedSame
            }
        }
        self.backingStore = FTMutableSet(sortDescriptors: [sortDescriptior])
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cloudServiceDidChangeResources(_:)),
                                               name: Notification.Name.CloudServiceDidChangeResources,
                                               object: cloudService)
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private(set) var isUpdating: Bool = false
    func update(completion: ((Error?) -> Void)?) {
        guard
            let resource = self.resource
            else {
                completion?(nil)
                return
        }
        
        if isUpdating {
            completion?(nil)
        } else {
            isUpdating = true
            cloudService.updateResource(at: resource.path, of: resource.account) { error in
                DispatchQueue.main.async {
                    self.isUpdating = false
                    completion?(error)
                }
            }
        }
    }
    
    private func reload() {
        let resources = self.fetchResources()
        backingStore.performBatchUpdate {
            self.backingStore.removeAllObjects()
            self.backingStore.addObjects(from: resources)
        }
    }
    
    private func fetchResources() -> [CloudService.Resource] {
        do {
            if let resource = self.resource {
                return try cloudService.contents(of: resource.account, at: resource.path)
            } else {
                return []
            }
        } catch {
            NSLog("Failed to get contents: \(error)")
            return []
        }
    }
    
    func resource(at indexPath: IndexPath) -> CloudService.Resource? {
        return backingStore.item(at: indexPath) as? CloudService.Resource
    }
    
    // MARK: - ResourceDataSource
    
    var title: String? {
        guard
            let resource = self.resource
            else { return nil }
        
        if resource.path.count == 0 {
            return resource.account.label ?? resource.account.url.host ?? resource.account.url.absoluteString
        } else {
            return resource.path.last
        }
    }
    
    var footer: String? {
        if isUpdating {
            return "Updating ..."
        } else if let updated = resource?.updated {
            let formatter = DateFormatter()
            formatter.doesRelativeDateFormatting = true
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            return "Last Update\n\(formatter.string(from: updated))"
        } else {
            return nil
        }
    }
    
    // MARK: - FTDataSource
    
    func numberOfSections() -> UInt {
        return backingStore.numberOfSections()
    }
    
    func numberOfItems(inSection section: UInt) -> UInt {
        return backingStore.numberOfItems(inSection: section)
    }
    
    func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    func item(at indexPath: IndexPath!) -> Any! {
        if let item = backingStore.item(at: indexPath) as? CloudService.Resource {
            return ViewModel(resource: item)
        } else {
            return nil
        }
    }

    func observers() -> [Any]! {
        return backingStore.observers()
    }
    
    func addObserver(_ observer: FTDataSourceObserver!) {
        backingStore.addObserver(observer)
    }
    
    public func removeObserver(_ observer: FTDataSourceObserver!) {
        backingStore.removeObserver(observer)
    }
    
    class ViewModel: ResourceListViewModel {
        
        var title: String? {
            return resource.path.last
        }
        
        var subtitle: String? {
            return resource.path.joined(separator: "/")
        }
        
        let resource: CloudService.Resource
        
        init(resource: CloudService.Resource) {
            self.resource = resource
        }
    }
    
    // MARK: - Notification Handling
    
    @objc private func cloudServiceDidChangeResources(_ notification: Notification) {
        DispatchQueue.main.async {
            
            var needsReload: Bool = false
            
            if let resource = self.resource {
                if let insertedOrUpdate = notification.userInfo?[InsertedOrUpdatedResourcesKey] as? [CloudService.Resource] {
                    for updatedResource in insertedOrUpdate {
                        if resource == updatedResource {
                            self.resource = updatedResource
                            return
                        } else if resource.account == updatedResource.account && resource.path.starts(with: updatedResource.path) {
                            needsReload = true
                        }
                    }
                }
                if let deleted = notification.userInfo?[DeletedResourcesKey] as? [CloudService.Resource] {
                    for deletedResource in deleted {
                        if resource == deletedResource {
                            self.resource = nil
                            return
                        } else if resource.account == deletedResource.account && resource.path.starts(with: deletedResource.path) {
                            self.resource = nil
                            return
                        }
                    }
                }
            }
            
            if needsReload {
                self.reload()
            }
        }
    }
}
