//
//  TransactionTableViewCell.swift
//  M1Assessment
//
//  Created by Moore, Michael H on 10/9/21.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    var transaction: Transaction? {
        didSet {
            configureLabels()
        }
    }
    private var titleLabel = UILabel()
    private var dateLabel = UILabel()
    private var amountLabel = UILabel()
    private let viewModel = TransactionsListViewModel.shared

    // MARK: Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviewsAndSetConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Configuration
    private func addSubviewsAndSetConstraints() {
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(amountLabel)
        
        setTitleConstraints()
        setDateConstraints()
        setAmountConstraints()
    }
        
    private func configureLabels() {
        guard let transaction = transaction else { return }
        titleLabel.text = transaction.title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.adjustsFontSizeToFitWidth = true
        
        dateLabel.text = viewModel.formatDate(from: transaction.date)
        dateLabel.font = .italicSystemFont(ofSize: 12)

        amountLabel.font = .systemFont(ofSize: 16)
        let formattedAmount = viewModel.formatAmount(transaction.amount)
        if transaction.isCredit {
            amountLabel.textColor = .systemGreen
            amountLabel.text = "+$\(formattedAmount)"
        } else {
            amountLabel.textColor = .systemRed
            amountLabel.text = "-$\(formattedAmount)"
        }
    }
    
    private func setTitleConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.7).isActive = true
    }

    private func setDateConstraints() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        dateLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.7).isActive = true
        dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
    }

    private func setAmountConstraints() {
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        amountLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 125).isActive = true
    }
}
