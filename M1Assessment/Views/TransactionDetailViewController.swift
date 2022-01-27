//
//  TransactionDetailViewController.swift
//  M1Assessment
//
//  Created by Moore, Michael H on 10/9/21.
//

import UIKit

class TransactionDetailViewController: UIViewController {
    
    var transaction: Transaction? {
        didSet {
            configureView()
        }
    }
    private var viewModel = TransactionsListViewModel.shared
    private var titleLabel = UILabel()
    private var amountLabel = UILabel()
    private var dateLabel = UILabel()
    private var noteTextView = UITextView()
    private var checkImage = UIImageView()
    private var closeButton = UIButton()
    private let placeholderText = "Jot down a quick note of what you purchased"
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
        view.backgroundColor = .white
        addSubviewsAndSetConstraints()
        loadImage()
        createToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveNote()
    }
    
    // MARK: Selectors
    @objc func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: UI Configuration
    private func addSubviewsAndSetConstraints() {
        view.addSubview(closeButton)
        setCloseConstraints()
        
        if let isCredit = transaction?.isCredit, isCredit {
            if transaction?.imageURL != nil {
                view.addSubview(checkImage)
                setCheckConstraints()
            }
        } else {
            view.addSubview(noteTextView)
            view.addSubview(titleLabel)
            view.addSubview(amountLabel)
            view.addSubview(dateLabel)
            
            setNoteConstraints()
            setTitleConstraints()
            setDateConstraints()
            setAmountConstraints()
        }
    }
    
    private func setTitleConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    }
    
    private func setDateConstraints() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -18).isActive = true
        dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
    }
    
    private func setAmountConstraints() {
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 18).isActive = true
        amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
    }
    
    private func setCloseConstraints() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -72).isActive = true
    }
    
    private func setNoteConstraints() {
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noteTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60).isActive = true
        
        let wMultiplier = traitCollection.horizontalSizeClass == .compact ? 0.8 : 0.6
        noteTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: wMultiplier).isActive = true
        
        let hMultiplier = traitCollection.horizontalSizeClass == .compact ? 0.4 : 0.2
        noteTextView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: hMultiplier).isActive = true
    }
    
    private func setCheckConstraints() {
        checkImage.translatesAutoresizingMaskIntoConstraints = false
        checkImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        checkImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.frame.height / 4)) .isActive = true
        checkImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        checkImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        checkImage.contentMode = .scaleAspectFit
        checkImage.clipsToBounds = true
    }
    
    private func configureView() {
        addTapGesture()
        configureCloseButton()
        
        guard let transaction = transaction else { return }
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.text = transaction.title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        
        dateLabel.text = viewModel.formatDate(from: transaction.date)
        dateLabel.font = .systemFont(ofSize: 16)
        
        let formattedAmount = viewModel.formatAmount(transaction.amount)
        amountLabel.text = transaction.isCredit ? "+$\(formattedAmount)" : "-$\(formattedAmount)"
        amountLabel.font = .systemFont(ofSize: 16)
        
        if let note = transaction.note?.note, !note.isEmpty {
            noteTextView.text = transaction.note?.note
            noteTextView.textColor = .black
        } else {
            noteTextView.text = placeholderText
            noteTextView.textColor = .lightGray
        }
        
        noteTextView.layer.borderColor = UIColor.systemMint.withAlphaComponent(0.4).cgColor
        noteTextView.layer.borderWidth = 1.0
        noteTextView.layer.cornerRadius = 4
        
    }
    
    /// Allows user to tap on the view behind the keyboard to dismiss it
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configureCloseButton() {
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.addTarget(self, action: #selector(self.closeButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func loadImage() {
        guard let imageURL = transaction?.imageURL, let url = URL(string: imageURL) else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.checkImage.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self?.displayErrorAlert(altTitle: "Ooops!", altMessage: "We had trouble loading your image. So sorry! Please try again in a little bit.", altActionTitle: "Sad day 😔", completion: {
                        self?.dismiss(animated: true)
                    })
                }
            }
        }
    }
    
    private func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        doneButton.tintColor = .systemBlue
        toolBar.setItems([flexSpace, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        noteTextView.inputAccessoryView = toolBar
    }
    
    // MARK: Persistence
    private func saveNote() {
        if let id = transaction?.id {
            let note = Note(id: id, note: noteTextView.text)
            // first, we add the note to the transaction
            if let transactionIndex = viewModel.transactions.firstIndex(where: { $0.id == id }) {
                viewModel.transactions[transactionIndex].note = note
            }
            // next, we remove old note from our saved notes, if we have one
            if let noteIndex = viewModel.notes.firstIndex(where: { $0.id == id }){
                viewModel.notes.remove(at: noteIndex)
            }
            // and then add in the new/updated one
            viewModel.notes.append(note)
        }
    }
}

// MARK: UITextViewDelegate
extension TransactionDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
}
