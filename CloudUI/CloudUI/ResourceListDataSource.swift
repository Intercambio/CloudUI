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
    
    let resourceManager: ResourceManager
    private(set) var resource: Resource? {
        didSet {
            reload()
        }
    }
    
    init(resourceManager: ResourceManager, resource: Resource) {
        self.resourceManager = resourceManager
        self.resource = resource
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resourceManagerDidChange(_:)),
                                               name: Notification.Name.ResourceManagerDidChange,
                                               object: resourceManager)
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func resourceManagerDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            
            var needsReload: Bool = false
            
            if let resource = self.resource {
                if let insertedOrUpdate = notification.userInfo?[InsertedOrUpdatedResourcesKey] as? [Resource] {
                    for updatedResource in insertedOrUpdate {
                        if resource == updatedResource {
                            self.resource = updatedResource
                            return
                        } else if resource.path.starts(with: updatedResource.path) {
                            needsReload = true
                        }
                    }
                }
                if let deleted = notification.userInfo?[DeletedResourcesKey] as? [Resource] {
                    for deletedResource in deleted {
                        if resource == deletedResource {
                            self.resource = nil
                            return
                        } else if resource.path.starts(with: deletedResource.path) {
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
 
    private var resources: [Resource] = []
    
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
                resourceManager.updateResource(at: resource.path) { (error) in
                    NSLog("Failed to update resources: \(error)")
                }
            }
            
            self.resources = try resourceManager.content(at: resource.path)

        } catch {
            NSLog("Failed to get resources: \(error)")
        }
    }
    
    func resource(at indexPath: IndexPath) -> Resource? {
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
        
        let resource: Resource
        
        init(resource: Resource) {
            self.resource = resource
        }
    }
    
}
