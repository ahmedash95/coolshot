//
//  Storage.swift
//  coolshot
//
//  Created by Ahmed on 28.12.22.
//

import Foundation

enum ConfigKeys: String {
    case autoclose_on_copy
    case launch_at_login
}

class Storage {
    static let shared = Storage()
    
    private let defaults = UserDefaults.standard

    func set(_ key: ConfigKeys, _ value: Any) {
        defaults.set(value, forKey: key.rawValue)
    }

    func value(_ key: ConfigKeys, defaultValue: Any) -> Any {
        return defaults.object(forKey: key.rawValue) ?? defaultValue
    }
}
