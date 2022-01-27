//
//  UserDefaults+Ext.swift
//  M1Assessment
//
//  Created by Moore, Michael H on 10/9/21.
//

import Foundation

extension UserDefaults {
    
    static var notes: [Note] {
        get {
            if let data = UserDefaults.standard.data(forKey: "transactionNotes") {
                do {
                    return try JSONDecoder().decode([Note].self, from: data)
                } catch let error {
                    assertionFailure("There was an error decoding notes. \(error): \(error.localizedDescription)")
                }
            }
            return []
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: "transactionNotes")
            } catch let error {
                assertionFailure("There was an error encoding notes.  \(error): \(error.localizedDescription)")
            }
        }
    }
}
