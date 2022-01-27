//
//  TransactionListViewController.swift
//  M1Assessment
//
//  Created by Moore, Michael H on 10/9/21.
//

import UIKit

class TransactionListViewController: UIViewController {
    
    private var tableView = UITableView()
    private let viewModel = TransactionsListViewModel.shared
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        configureTableView()
        configureRefresh()
        fetchTransactions()
    }
    
    // MARK: UI Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "transactionCell")
        
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        setTableViewConstraints()
    }
    
    @objc func refeshTableView(_ sender: Any? = nil) {
        fetchTransactions()
    }
    
    private func configureRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(self.refeshTableView(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    private func setTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: super.view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: super.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: super.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: super.view.bottomAnchor).isActive = true
    }
    
    private func setupNavBar() {
        title = "Transactions"
        let sortButton = createSortButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)
    }

    // MARK: Networking
    private func fetchTransactions() {
        viewModel.fetchTransactions { [weak self] result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    if let isRefreshing = self?.tableView.refreshControl?.isRefreshing, isRefreshing {
                        self?.tableView.refreshControl?.endRefreshing()
                    }
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                assertionFailure("There was an error fetching the transactions.  \(error): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.displayErrorAlert()
                }
            }
        }
    }

    // MARK: Sorting
    @objc func sortButtonTapped(_ sender: UIButton) {
        let sortOptionsView = createSortView()
        
        if let popoverController = sortOptionsView.popoverPresentationController {
            popoverController.sourceView = sender
        }
        
        present(sortOptionsView, animated: true)
    }
    
    private func createSortButton() -> UIButton {
        let sortButton = UIButton()
        sortButton.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        sortButton.addTarget(self, action: #selector(self.sortButtonTapped(_:)), for: .touchUpInside)
        sortButton.tintColor = .black
        
        return sortButton
    }
    
    /// Creates view displaying sorting options
    /// iPad displays as mini popover from button, iPhone displays action sheet
    private func createSortView() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let dateOption = UIAlertAction(title: "Sort by Date", style: .default) { [weak self] _ in
            self?.viewModel.sortFor(.amount)
            self?.tableView.reloadData()
        }
        alertController.addAction(dateOption)
        
        let amountOption = UIAlertAction(title: "Sort by Amount", style: .default) { [weak self] _ in
            self?.viewModel.sortFor(.amount)
            self?.tableView.reloadData()
        }
        alertController.addAction(amountOption)
        
        let resetOption = UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            self?.viewModel.sortFor(.reset)
            self?.tableView.reloadData()
        }
        alertController.addAction(resetOption)
        
        let dismiss = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(dismiss)
        
        return alertController
    }
}

// MARK: TableViewDelegate and TableViewDataSource
extension TransactionListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as? TransactionTableViewCell else { return UITableViewCell() }
        
        cell.transaction = viewModel.transactions[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = viewModel.transactions[indexPath.row]
        guard !transaction.isCredit || (transaction.isCredit && transaction.imageURL != nil) else { return }
        
        let detailView = TransactionDetailViewController()
        detailView.transaction = transaction
        detailView.modalPresentationStyle = .fullScreen
        present(detailView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension < 60 ? 60 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
