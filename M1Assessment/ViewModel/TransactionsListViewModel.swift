//
//  TransactionsListViewModel.swift
//  M1Assessment
//
//  Created by Moore, Michael H on 10/9/21.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case fetchingError
    case noData
}

enum SortingOption {
    case date, amount, reset
}

class TransactionsListViewModel {
    
    static let shared = TransactionsListViewModel()
    var transactions: [Transaction] = []
    var notes: [Note] {
        get { UserDefaults.notes }
        set { UserDefaults.notes = newValue }
    }
    
    // MARK: Networking
    func fetchTransactions(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard let url = URL(string: "https://m1-technical-assessment-data.netlify.app/transactions-v1.json") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard error == nil else {
                completion(.failure(.fetchingError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decodedTransactions = try JSONDecoder().decode(Transactions.self, from: data)
                self?.transactions = self?.addNotesTo(decodedTransactions.transactions) ?? decodedTransactions.transactions
                completion(.success(()))
                return
            } catch {
                completion(.failure(.decodingError))
                return
            }
            
            
        }.resume()
    }
    
    // MARK: Helper Functions
    // Notes don't come from the backend, but saved locally
    // Once we get the transactions from the backend, we match a note with it's transaction
    private func addNotesTo(_ transactions: [Transaction]) -> [Transaction] {
        var updatedTransactions = [Transaction]()
        for transaction in transactions {
            var notedTransaction = transaction
            for note in notes where note.id == transaction.id {
                notedTransaction.note = note
            }
            updatedTransactions.append(notedTransaction)
        }
        return updatedTransactions
    }
    
    func sortFor(_ option: SortingOption) {
        switch option {
        case .date:
            transactions.sort(by: { $0.date < $1.date })
        case .amount:
            transactions.sort(by: { $0.amount < $1.amount })
        case .reset:
            transactions.sort(by: { $0.id < $1.id })
        }
    }
    
    func formatAmount(_ amount: Double) -> String {
        return String(format: "%.02f", amount)
    }
    
    func formatDate(from dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let convertedDate = formatter.date(from: dateStr) else { return dateStr }
        formatter.dateStyle = .short
        return formatter.string(from: convertedDate)
    }
}
