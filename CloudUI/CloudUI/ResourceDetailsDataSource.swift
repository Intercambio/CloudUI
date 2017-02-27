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
    
    let cloudService: CloudService
    var resource: Resource
    private let proxy: FTObserverProxy
    public init(cloudService: CloudService, resource: Resource) {
        self.cloudService = cloudService
        self.resource = resource
        proxy = FTObserverProxy()
        super.init()
        proxy.object = self
    }
    
    // Options
    
    var supportedKeys: [String] {
        return [
            "name",
            "type",
            "size",
            "modified"
        ]
    }
    
    private func indexPath(for option: String) -> IndexPath? {
        switch option {
        case "name": return IndexPath(item: 0, section: 0)
        case "type": return IndexPath(item: 0, section: 1)
        case "size": return IndexPath(item: 1, section: 1)
        case "modified": return IndexPath(item: 2, section: 1)
        default: return nil
        }
    }
    
    private func option(for indexPath: IndexPath) -> String? {
        switch (indexPath) {
        case IndexPath(item: 0, section: 0): return "name"
        case IndexPath(item: 0, section: 1): return "type"
        case IndexPath(item: 1, section: 1): return "size"
        case IndexPath(item: 2, section: 1): return "modified"
        default: return nil
        }
    }
    
    // MARK: - FormDataSource
    
    func setValue(_ value: Any?, forItemAt indexPath: IndexPath) {
        
    }
    
    func performAction(_ action: Selector, forItemAt _: IndexPath) {
        
    }
    
    // MARK: - FTDataSource
    
    public func numberOfSections() -> UInt {
        return 2
    }
    
    public func numberOfItems(inSection section: UInt) -> UInt {
        switch section {
        case 0: return 1
        case 1: return 3
        default: return 0
        }
    }
    
    public func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    public func item(at indexPath: IndexPath!) -> Any! {
        guard
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
}
