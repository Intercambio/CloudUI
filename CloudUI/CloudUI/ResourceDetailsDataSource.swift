//
//  ResourceDetailsDataSource.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 27.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import MobileCoreServices
import Fountain
import CloudService

class ResourceDetailsDataSource: NSObject, FormDataSource {
    
    let interactor: ResourceDetailsInteractor
    
    var resource: Resource? {
        willSet {
            proxy.dataSourceWillReset(self)
        }
        didSet {
            proxy.dataSourceDidReset(self)
        }
    }
    
    private let proxy: FTObserverProxy
    public init(interactor: ResourceDetailsInteractor, resource: Resource?) {
        self.interactor = interactor
        self.resource = resource
        proxy = FTObserverProxy()
        super.init()
        proxy.object = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(interactorDidChange(_:)),
            name: Notification.Name.ResourceDetailsInteractorDidChange,
            object: interactor
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Actions
    
    @objc private func remove() {
        guard
            let resource = self.resource
        else { return }
        do {
            try interactor.deleteFileForResource(with: resource.resourceID)
        } catch {
            NSLog("Failed to delete downloaded file: \(error)")
        }
    }
    
    // Options
    
    var supportedKeys: [String] {
        return [
            "name",
            "type",
            "size",
            "modified",
            "remove"
        ]
    }
    
    private func indexPath(for option: String) -> IndexPath? {
        switch option {
        case "name": return IndexPath(item: 0, section: 0)
        case "type": return IndexPath(item: 0, section: 1)
        case "size": return IndexPath(item: 1, section: 1)
        case "modified": return IndexPath(item: 2, section: 1)
        case "download": return IndexPath(item: 0, section: 2)
        default: return nil
        }
    }
    
    private func option(for indexPath: IndexPath) -> String? {
        switch indexPath {
        case IndexPath(item: 0, section: 0): return "name"
        case IndexPath(item: 0, section: 1): return "type"
        case IndexPath(item: 1, section: 1): return "size"
        case IndexPath(item: 2, section: 1): return "modified"
        case IndexPath(item: 0, section: 2): return "remove"
        default: return nil
        }
    }
    
    // MARK: - FormDataSource
    
    func setValue(_: Any?, forItemAt _: IndexPath) {
        
    }
    
    func performAction(_ action: Selector, forItemAt _: IndexPath) {
        if action == #selector(remove) {
            remove()
        }
    }
    
    // MARK: - FTDataSource
    
    public func numberOfSections() -> UInt {
        guard
            let resource = self.resource
        else { return 0 }
        
        if resource.fileState == .none {
            return 2
        } else {
            return 3
        }
    }
    
    public func numberOfItems(inSection section: UInt) -> UInt {
        switch section {
        case 0: return 1
        case 1: return 3
        case 2: return 1
        default: return 0
        }
    }
    
    public func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    public func item(at indexPath: IndexPath!) -> Any! {
        guard
            let resource = self.resource,
            let key = option(for: indexPath)
        else { return nil }
        switch key {
        case "name":
            let item = FormTextItemData(identifier: key)
            item.selectable = false
            item.editable = false
            item.text = resource.resourceID.name
            return item
        case "type":
            let item = FormValueItemData(identifier: key)
            item.title = "Type"
            if
                let type = resource.properties.contentType,
                let identifiers = UTTypeCreateAllIdentifiersForTag(kUTTagClassMIMEType, type as CFString, nil)?.takeRetainedValue() as? Array<CFString>,
                let identifier = identifiers.first {
                item.value = UTTypeCopyDescription(identifier)?.takeRetainedValue() as? String
            } else {
                item.value = "undefined"
            }
            return item
        case "size":
            let item = FormValueItemData(identifier: key)
            item.title = "Size"
            if let size = resource.properties.contentLength {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                item.value = formatter.string(fromByteCount: Int64(size))
            } else {
                item.value = "undefined"
            }
            return item
        case "modified":
            let item = FormValueItemData(identifier: key)
            item.title = "Modified"
            if let modified = resource.properties.modified {
                let formatter = DateFormatter()
                formatter.doesRelativeDateFormatting = true
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                item.value = formatter.string(from: modified)
            } else {
                item.value = "undefined"
            }
            return item
        case "remove":
            let item = FormButtonItemData(identifier: key, action: #selector(remove))
            item.destructive = true
            item.title = "Delete Download"
            item.destructionMessage = "Delete the downloaded file from this device"
            return item
        default:
            return nil
        }
    }
    
    func observers() -> [Any]! {
        return proxy.observers()
    }
    
    func addObserver(_ observer: FTDataSourceObserver!) {
        proxy.addObserver(observer)
    }
    
    func removeObserver(_ observer: FTDataSourceObserver!) {
        proxy.removeObserver(observer)
    }
    
    // MARK: - Notification Handling
    
    @objc private func interactorDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            do {
                if let resource = self.resource {
                    
                    if let deleted = notification.userInfo?[ResourceDetailsInteractorDeletedResourcesKey] as? [ResourceID] {
                        for deletedResource in deleted {
                            if resource.resourceID == deletedResource {
                                self.resource = nil
                                return
                            }
                        }
                    }
                    
                    if let insertedOrUpdate = notification.userInfo?[ResourceDetailsInteractorInsertedOrUpdatedResourcesKey] as? [ResourceID] {
                        for updatedResource in insertedOrUpdate {
                            if resource.resourceID == updatedResource {
                                self.resource = try self.interactor.resource(with: updatedResource)
                                return
                            }
                        }
                    }
                }
            } catch {
                NSLog("Failed to update resource: \(error)")
            }
        }
    }
}
