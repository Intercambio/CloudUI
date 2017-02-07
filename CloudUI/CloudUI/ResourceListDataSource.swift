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

class ResourceListDataSource: NSObject, FTDataSource {
    
    let cloudService: CloudService
    private(set) var resource: CloudService.Resource? {
        didSet {
            reload()
        }
    }
    
    init(cloudService: CloudService, resource: CloudService.Resource) {
        self.cloudService = cloudService
        self.resource = resource
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
 
    private var resources: [CloudService.Resource] = []
    
    private func reload() {
        do {
            
            defer {
                for observer in _observers.allObjects {
                    observer.dataSourceDidReset?(self)
                }
            }
            
            for observer in _observers.allObjects {
                observer.dataSourceWillReset?(self)
            }
            
            guard
                let resource = self.resource
                else {
                    self.resources = []
                    return
            }
            
            if resource.dirty {
                cloudService.updateResource(at: resource.path, of: resource.account) { (error) in
                    NSLog("Failed to update resources: \(error)")
                }
            }
            
            self.resources = try cloudService.contents(of: resource.account, at: resource.path)

        } catch {
            NSLog("Failed to get resources: \(error)")
        }
    }
    
    func resource(at indexPath: IndexPath) -> CloudService.Resource? {
        if indexPath.section == 0 {
            return resources[indexPath.item]
        } else {
            return nil
        }
    }
    
    // MARK: - FTDataSource
    
    func numberOfSections() -> UInt {
        return 1
    }
    
    func numberOfItems(inSection section: UInt) -> UInt {
        return UInt(resources.count)
    }
    
    func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    func item(at indexPath: IndexPath!) -> Any! {
        if indexPath.section == 0 {
            let resource = resources[indexPath.item]
            return ViewModel(resource: resource)
        } else {
            return nil
        }
    }
    
    private let _observers: NSHashTable = NSHashTable<FTDataSourceObserver>.weakObjects()
    
    func observers() -> [Any]! {
        return _observers.allObjects
    }
    
    func addObserver(_ observer: FTDataSourceObserver!) {
        if _observers.contains(observer) == false {
            _observers.add(observer)
        }
    }
    
    public func removeObserver(_ observer: FTDataSourceObserver!) {
        _observers.remove(observer)
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
    
}
