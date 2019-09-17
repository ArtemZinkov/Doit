//
//  AuthorizationViewController.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

final class AuthorizationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var authenticationLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var authenticationSwitch: UISwitch!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - IBActions
    @IBAction func changeAuthenticationMode(_ sender: UISwitch) {
        if sender.isOn {
            UIView.transition(with: authenticationLabel, duration: 0.5, options: .transitionCrossDissolve, animations: { self.authenticationLabel.text = "Sign In" })
            UIView.transition(with: proceedButton, duration: 0.5, options: .transitionCrossDissolve, animations: { self.proceedButton.setTitle("LOG IN", for: .normal) })
        } else {
            UIView.transition(with: authenticationLabel, duration: 0.5, options: .transitionCrossDissolve, animations: { self.authenticationLabel.text = "Sign Up" })
            UIView.transition(with: proceedButton, duration: 0.5, options: .transitionCrossDissolve, animations: { self.proceedButton.setTitle("REGISTER", for: .normal) })
        }
    }
    
    @IBAction private func textFieldEditingChanged() {
        let credentials = Credentials(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        if credentials.isValid() {
            proceedButton.alpha = 1.0
            proceedButton.isUserInteractionEnabled = true
        } else {
            proceedButton.alpha = 0.5
            proceedButton.isUserInteractionEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction private func authenticationButtonPressed(_ sender: Any) {
        validateAndProceed()
    }
    
    // MARK: - Private Methods
    private func validateAndProceed() {
        let credentials = Credentials(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        
        if !credentials.isValid() {
            
            // TODO: Handle error
            
            return
        }
        
        if authenticationSwitch.isOn { // Log In
            APIManager.shared.login(with: credentials, authenticationSuccess, authenticationError)
        } else { // Registration
            APIManager.shared.register(with: credentials, authenticationSuccess, authenticationError)
        }
    }
    
    private func authenticationSuccess() {
        dismiss(animated: true) {
            Router.route(to: .TaskList)
        }
    }

    private func authenticationError(_ error: Error) {
        let alertController = UIAlertController(title: "Authentication Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    @objc private func onKeyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            view.frame.origin.y = -max(0, proceedButton.frame.maxY - keyboardFrame.minY)
        }
    }

    @objc private func onKeyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
}

extension AuthorizationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
}
