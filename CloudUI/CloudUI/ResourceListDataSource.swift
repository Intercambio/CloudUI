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
    private var account: Account?
    
    let cloudService: CloudService
    init(cloudService: CloudService, resource: Resource) {
        self.cloudService = cloudService
        self.resource = resource
        let sortDescriptior = NSSortDescriptor(key: "self", ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard
                let lhResource = lhs as? Resource,
                let rhResource = rhs as? Resource
                else { return .orderedSame }
            
            let lhName = lhResource.resourceID.name.lowercased()
            let rhName = rhResource.resourceID.name.lowercased()
            
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
            
            cloudService.updateResource(with: resource.resourceID) { error in
                DispatchQueue.main.async {
                    self.proxy.dataSourceWillChange(self.backingStore)
                    self.isUpdating = false
                    self.proxy.dataSourceDidChange(self.backingStore)
                }
            }
        }
    }
    
    private func reload() {
        let account = fetchAccount()
        let resources = self.fetchResources()
        backingStore.performBatchUpdate {
            self.account = account
            self.backingStore.removeAllObjects()
            self.backingStore.addObjects(from: resources)
        }
    }
    
    private func fetchResources() -> [Resource] {
        do {
            if let resource = self.resource {
                return try cloudService.contentOfResource(with: resource.resourceID)
            } else {
                return []
            }
        } catch {
            NSLog("Failed to get contents: \(error)")
            return []
        }
    }
    
    private func fetchAccount() -> Account? {
        do {
            if let resource = self.resource {
                return try cloudService.account(with: resource.resourceID.accountID)
            } else {
                return nil
            }
        } catch {
            NSLog("Failed to get the account: \(error)")
            return nil
        }
    }
    
    func resource(at indexPath: IndexPath) -> Resource? {
        return backingStore.item(at: indexPath) as? Resource
    }
    
    // MARK: - ResourceDataSource
    
    var title: String? {
        guard
            let resource = self.resource,
            let account = self.account
            else { return nil }
        
        if resource.resourceID.isRoot {
            return account.label ?? account.url.host ?? account.url.absoluteString
        } else {
            return resource.resourceID.name
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
    
    func performAction(_ action: Selector, forItemAt indexPath: IndexPath) {
        guard
            let resource = backingStore.item(at: indexPath) as? Resource
            else { return }
        
        switch NSStringFromSelector(action) {
        case "download":
            _ = cloudService.downloadResource(with: resource.resourceID)
        default:
            break
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
            let progress = cloudService.progressForResource(with: item.resourceID)
            return ViewModel(resource: item, progress: progress)
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
        let progress: Progress?
        init(resource: Resource, progress: Progress?) {
            self.resource = resource
            self.progress = progress
        }
        var title: String? {
            return resource.resourceID.name
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
        var showDownloadAccessory: Bool {
            return resource.properties.isCollection == false && resource.fileState == .none
        }
    }
    
    // MARK: - Notification Handling
    
    @objc private func cloudServiceDidChangeResources(_ notification: Notification) {
        DispatchQueue.main.async {
            do {
                var needsReload: Bool = false
                if let resource = self.resource {
                    
                    if let deleted = notification.userInfo?[DeletedResourcesKey] as? [ResourceID] {
                        for deletedResource in deleted {
                            if resource.resourceID == deletedResource {
                                self.resource = nil
                                return
                            } else if deletedResource.isAncestor(of: resource.resourceID) {
                                self.resource = nil
                            } else if deletedResource.isChild(of: resource.resourceID) {
                                needsReload = true
                                break
                            }
                        }
                    }
                    
                    if let insertedOrUpdate = notification.userInfo?[InsertedOrUpdatedResourcesKey] as? [ResourceID] {
                        for updatedResource in insertedOrUpdate {
                            if resource.resourceID == updatedResource {
                                self.resource = try self.cloudService.resource(with: updatedResource)
                                return
                            } else if updatedResource.isAncestor(of: resource.resourceID) || updatedResource.isChild(of: resource.resourceID) {
                                needsReload = true
                                break
                            }
                        }
                    }
                }
                if needsReload {
                    self.reload()
                }
            } catch {
                
            }
        }
    }
}
