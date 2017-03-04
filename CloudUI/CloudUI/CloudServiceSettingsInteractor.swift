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
    
    public func values(forAccountWith identifier: String) -> [String:Any]? {
        do {
            guard
                let account = try self.account(with: identifier)
                else { return nil }
            var result: [String:Any] = [:]
            result[SettingsLabelKey] = account.label
            result[SettingsBaseURLKey] = account.url
            result[SettingsUsernameKey] = account.username
            return result
        } catch {
            return nil
        }
    }
    
    public func password(forAccountWith identifier: String) -> String? {
        do {
            guard
                let account = try account(with: identifier)
                else { return nil }
            return password(for: account)
        } catch {
            return nil
        }
    }
    
    public func update(accountWith identifier: String, using values: [String:Any]) throws -> [String:Any]? {
        guard
            let account = try self.account(with: identifier)
            else { return values }
        let label = values[SettingsLabelKey] as? String
        if account.label != label {
            try update(account, with: label)
        }
        return self.values(forAccountWith: identifier)
    }
    
    public func setPassword(_ password: String?, forAccountWith identifier: String) throws {
        guard
            let account = try account(with: identifier)
            else { return }
        setPassword(password, for: account)
    }
    
    public func remove(accountWith identifier: String) throws {
        guard
            let account = try account(with: identifier)
            else { return }
        try remove(account)
    }
}
