//
//  TransactionsModel.swift
//  M1Assessment
//
//  Created by Moore, Michael H on 10/9/21.
//

import Foundation

struct Transactions: Codable {
    let transactions: [Transaction]
}

struct Transaction: Codable {
    let id: Int
    let date: String
    let amount: Double
    let isCredit: Bool
    let title: String
    let imageURL: String?
    // a non-parsing property
    var note: Note? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, date, amount, isCredit
        case title = "description"
        case imageURL = "imageUrl"
    }
}

struct Note: Codable {
    let id: Int
    var note: String
}
