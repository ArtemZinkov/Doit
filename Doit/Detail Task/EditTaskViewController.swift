//
//  EditTaskViewController.swift
//  Doit
//
//  Created by Артём Зиньков on 9/15/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

protocol TaskCreationDelegate: class {
    func createdTask()
}

final class EditTaskViewController: UIViewController {
    
    public static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priorityStackView: UIStackView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    private var selectedPriority: TaskPriority?
    private var model: TaskModel?
    
    public weak var delegate: TaskCreationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextView.layer.borderWidth = 0.5
        titleTextView.layer.borderColor = UIColor.gray.cgColor
        titleTextView.layer.cornerRadius = titleTextView.frame.height / 4
        
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        descriptionTextView.layer.cornerRadius = titleTextView.frame.height / 4
        
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        dateTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        priorityStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        TaskPriority.allCases.forEach { priorityStackView.addArrangedSubview(createPriorityButton(for: $0)) }
        
        if model == nil { title = "Creating Task" }
        
        titleTextView.text = model?.title
        descriptionTextView.text = model?.description
        selectedPriority = model?.priority
        if let dueBy = model?.dueBy {
            dateTextField.text = EditTaskViewController.dateFormatter.string(from: Date(timeIntervalSince1970: dueBy))
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContentView))
        contentView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setup(with model: TaskModel, with delegate: TaskCreationDelegate? = nil) {
        self.model = model
        self.delegate = delegate
    }
    
    // MARK: - Private Methods
    @objc private func didTapContentView() {
        titleTextView.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        dateTextField.resignFirstResponder()
    }
    
    @IBAction private func saveTask() {
        
        if !passedCheck() { return }
        
        if model == nil { // Create
            var parameters = [
                "title": titleTextView.text ?? "",
                "description": descriptionTextView.text ?? ""
            ]
            
            if let text = dateTextField.text,
                let date = EditTaskViewController.dateFormatter.date(from: text),
                let timeSince1970 = Int(exactly: date.timeIntervalSince1970) {
                parameters["dueBy"] = timeSince1970.description
            }
            
            if let priority = selectedPriority {
                parameters["priority"] = priority.rawValue
            }
            
            APIManager.shared.createTask(with: parameters, createdTask)
        } else {
            APIManager.shared.save(model!)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func passedCheck() -> Bool {
        if titleTextView.text.isEmpty {
            let alertController = UIAlertController(title: "Fill all fields", message: "Title should be fulfilled", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true)
            return false
        }

        if dateTextField.text?.isEmpty ?? true {
            let alertController = UIAlertController(title: "Fill all fields", message: "Date should be chosed", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true)
            return false
        }

        if selectedPriority == nil {
            let alertController = UIAlertController(title: "Chose priority", message: "Priority should be chosed", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true)
            return false
        }
        
        return true
    }
    
    private func createdTask() {
        delegate?.createdTask()
    }
    
    private func createPriorityButton(for priority: TaskPriority) -> UIButton {
        let button = UIButton()
        if priority == model?.priority {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .gray
        } else {
            button.setTitleColor(.gray, for: .normal)
            button.backgroundColor = .clear
        }
        button.setTitle(priority.rawValue, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = button.frame.height / 4
        button.addTarget(self, action: #selector(priorityButtonPressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func priorityButtonPressed(_ sender: UIButton) {
        selectedPriority = TaskPriority(rawValue: sender.titleLabel?.text ?? "")
        model?.priority = selectedPriority
        
        UIView.animate(withDuration: 0.3) {
            if let buttons = self.priorityStackView.arrangedSubviews as? [UIButton] {
                for button in buttons {
                    button.setTitleColor(.gray, for: .normal)
                    button.backgroundColor = .clear
                }
            }
            
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = .gray
        }
    }
    
    @objc private func handleDatePicker(sender: UIDatePicker) {
        dateTextField.text = EditTaskViewController.dateFormatter.string(from: sender.date)
        model?.dueBy = sender.date.timeIntervalSince1970
    }

    @objc private func onKeyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            var shift = keyboardFrame.height - saveButton.frame.height
            if #available(iOS 11.0, *) { shift -= view.safeAreaInsets.bottom }
            
            scrollViewBottomConstraint.constant = -shift
        }
    }
    
    @objc private func onKeyboardWillHide(_ notification: Notification) {
        scrollViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

extension EditTaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == titleTextView {
            model?.title = textView.text
        }
        
        if textView == descriptionTextView {
            model?.description = textView.text
        }
    }
}
