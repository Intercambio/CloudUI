//
//  ResourceListDataSource.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import CloudService

class ResourceListDataSource: NSObject, ResourceDataSource {
    
    private let backingStore: FTMutableSet
    private let proxy: FTObserverProxy
    private(set) var resource: Resource? {
        didSet {
            reload()
        }
    }
    
    let cloudService: CloudService
    init(cloudService: CloudService, resource: Resource) {
        self.cloudService = cloudService
        self.resource = resource
        let sortDescriptior = NSSortDescriptor(key: "self", ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard
                let lhResource = lhs as? Resource,
                let rhResource = rhs as? Resource,
                let lhName = lhResource.path.components.last?.lowercased(),
                let rhName = rhResource.path.components.last?.lowercased()
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
        self.proxy = FTObserverProxy()
        super.init()
        proxy.object = self
        backingStore.addObserver(proxy)
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
    func update(force: Bool = false) {
        guard
            let resource = self.resource,
            (resource.dirty == true || force == true)
            else {
                return
        }
        
        if isUpdating == false {
            
            proxy.dataSourceWillChange(backingStore)
            isUpdating = true
            proxy.dataSourceDidChange(backingStore)
            
            cloudService.updateResource(at: resource.path, of: resource.account) { error in
                DispatchQueue.main.async {
                    self.proxy.dataSourceWillChange(self.backingStore)
                    self.isUpdating = false
                    self.proxy.dataSourceDidChange(self.backingStore)
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
    
    private func fetchResources() -> [Resource] {
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
    
    func resource(at indexPath: IndexPath) -> Resource? {
        return backingStore.item(at: indexPath) as? Resource
    }
    
    // MARK: - ResourceDataSource
    
    var title: String? {
        guard
            let resource = self.resource
            else { return nil }
        
        if resource.path.length == 0 {
            return resource.account.label ?? resource.account.url.host ?? resource.account.url.absoluteString
        } else {
            return resource.path.components.last
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
        if let item = backingStore.item(at: indexPath) as? Resource {
            return ViewModel(resource: item)
        } else {
            return nil
        }
    }
    
    func observers() -> [Any]! {
        return proxy.observers()
    }
    
    func addObserver(_ observer: FTDataSourceObserver!) {
        proxy.addObserver(observer)
    }
    
    public func removeObserver(_ observer: FTDataSourceObserver!) {
        proxy.removeObserver(observer)
    }
    
    class ViewModel: ResourceListViewModel {
        let resource: Resource
        init(resource: Resource) {
            self.resource = resource
        }
        var title: String? {
            return resource.path.components.last
        }
        var subtitle: String? {
            guard
                let contentType = resource.properties.contentType,
                let contentLength = resource.properties.contentLength
                else { return nil }
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return "\(contentType), \(formatter.string(fromByteCount: Int64(contentLength)))"
        }
    }
    
    // MARK: - Notification Handling
    
    @objc private func cloudServiceDidChangeResources(_ notification: Notification) {
        DispatchQueue.main.async {
            var needsReload: Bool = false
            if let resource = self.resource {
                if let deleted = notification.userInfo?[DeletedResourcesKey] as? [Resource] {
                    for deletedResource in deleted {
                        if resource == deletedResource {
                            self.resource = nil
                            return
                        } else if resource.account == deletedResource.account {
                            if deletedResource.path.isAncestor(of: resource.path) {
                                self.resource = nil
                            } else if deletedResource.path.isChild(of: resource.path) {
                                needsReload = true
                                break
                            }
                        }
                    }
                }
                if let insertedOrUpdate = notification.userInfo?[InsertedOrUpdatedResourcesKey] as? [Resource] {
                    for updatedResource in insertedOrUpdate {
                        if resource == updatedResource {
                            self.resource = updatedResource
                            return
                        } else if resource.account == updatedResource.account
                            && (updatedResource.path.isAncestor(of: resource.path) || updatedResource.path.isChild(of: resource.path)) {
                            needsReload = true
                            break
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
