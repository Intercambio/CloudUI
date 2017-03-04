//
//  SettingsDataSourceTests.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 04.03.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import XCTest
@testable import CloudUI

class SettingsDataSourceTests: XCTestCase, SettingsInteractor {
    
    var dataSource: SettingsDataSource?
    
    override func setUp() {
        super.setUp()
        dataSource = SettingsDataSource(interactor: self, accountIdentifier: "123")
    }
    
    override func tearDown() {
        dataSource = nil
        super.tearDown()
    }
    
    func testSettingsItems() {
        guard
            let dataSource = self.dataSource
            else { XCTFail(); return }
        
        XCTAssertEqual(dataSource.numberOfSections(), 4)
        XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(dataSource.numberOfItems(inSection: 1), 2)
        XCTAssertEqual(dataSource.numberOfItems(inSection: 2), 1)
        XCTAssertEqual(dataSource.numberOfItems(inSection: 3), 1)
        
        var item: FormItem? = nil
        
        item = dataSource.item(at: IndexPath(item: 0, section: 0)) as? FormItem
        XCTAssertEqual(item?.identifier, SettingsKey.Label)
        
        item = dataSource.item(at: IndexPath(item: 0, section: 1)) as? FormItem
        XCTAssertEqual(item?.identifier, SettingsKey.BaseURL)
        
        item = dataSource.item(at: IndexPath(item: 1, section: 1)) as? FormItem
        XCTAssertEqual(item?.identifier, SettingsKey.Username)
        
        item = dataSource.item(at: IndexPath(item: 0, section: 2)) as? FormItem
        XCTAssertEqual(item?.identifier, "password")
        
        item = dataSource.item(at: IndexPath(item: 0, section: 3)) as? FormItem
        XCTAssertEqual(item?.identifier, "remove")
    }
    
    func testUpdateLabel() {
        guard
            let dataSource = self.dataSource
            else { XCTFail(); return }
        
        var item: FormTextItem? = nil

        item = dataSource.item(at: IndexPath(item: 0, section: 0)) as? FormTextItem
        XCTAssertNil(item?.text)
        
        dataSource.setValue("Romeo", forItemAt: IndexPath(item: 0, section: 0))
        
        item = dataSource.item(at: IndexPath(item: 0, section: 0)) as? FormTextItem
        XCTAssertEqual(item?.text, "Romeo")
    }
    
    // MARK: - SettingsInteractor
    
    var identifier: AccountID? = "123"
    var values: [SettingsKey:Any]? = nil
    var password: String? = nil
    
    func values(forAccountWith identifier: AccountID) -> [SettingsKey:Any]? {
        guard
            self.identifier == identifier
            else { return nil }
        return values
    }
    
    func password(forAccountWith identifier: AccountID) -> String? {
        guard
            self.identifier == identifier
            else { return nil }
        
        return password
    }
    
    func update(accountWith identifier: AccountID, using values: [SettingsKey:Any]) throws -> [SettingsKey:Any]? {
        guard
            self.identifier == identifier
            else { return nil }
        self.values = values
        return values
    }
    
    func setPassword(_ password: String?, forAccountWith identifier: AccountID) throws {
        guard
            self.identifier == identifier
            else { return }
        self.password = password
    }
    
    func remove(accountWith identifier: AccountID) throws {
        guard
            self.identifier == identifier
            else { return }
        self.identifier = nil
        self.values = nil
        self.password = nil
    }
}
