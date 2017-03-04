//
//  CloudServiceSettingsInteractor.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 04.03.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CloudService

extension CloudService: SettingsInteractor {
    
    public func values(forAccountWith identifier: AccountID) -> [SettingsKey:Any]? {
        do {
            guard
                let account = try self.account(with: identifier)
                else { return nil }
            var result: [String:Any] = [:]
            result[SettingsKey.Label] = account.label
            result[SettingsKey.BaseURL] = account.url
            result[SettingsKey.Username] = account.username
            return result
        } catch {
            return nil
        }
    }
    
    public func password(forAccountWith identifier: AccountID) -> String? {
        do {
            guard
                let account = try account(with: identifier)
                else { return nil }
            return password(for: account)
        } catch {
            return nil
        }
    }
    
    public func update(accountWith identifier: AccountID, using values: [SettingsKey:Any]) throws -> [SettingsKey:Any]? {
        guard
            let account = try self.account(with: identifier)
            else { return values }
        let label = values[SettingsKey.Label] as? String
        if account.label != label {
            try update(account, with: label)
        }
        return self.values(forAccountWith: identifier)
    }
    
    public func setPassword(_ password: String?, forAccountWith identifier: AccountID) throws {
        guard
            let account = try account(with: identifier)
            else { return }
        setPassword(password, for: account)
    }
    
    public func remove(accountWith identifier: AccountID) throws {
        guard
            let account = try account(with: identifier)
            else { return }
        try remove(account)
    }
}
