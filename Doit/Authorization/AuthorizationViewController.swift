//
//  AuthorizationViewController.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

final class AuthorizationViewController: UIViewController {
    
    @IBOutlet weak var authenticationLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var authenticationSwitch: UISwitch!
    
    @IBAction func changeAuthenticationMode(_ sender: UISwitch) {
        if sender.isOn {
            UIView.transition(with: authenticationLabel, duration: 0.5, options: .transitionCrossDissolve, animations: { self.authenticationLabel.text = "Sign In" })
            UIView.transition(with: proceedButton, duration: 0.5, options: .transitionCrossDissolve, animations: { self.proceedButton.setTitle("LOG IN", for: .normal) })
        } else {
            UIView.transition(with: authenticationLabel, duration: 0.5, options: .transitionCrossDissolve, animations: { self.authenticationLabel.text = "Sign Up" })
            UIView.transition(with: proceedButton, duration: 0.5, options: .transitionCrossDissolve, animations: { self.proceedButton.setTitle("REGISTER", for: .normal) })
        }
    }
    
    @IBAction func authenticationButtonPressed(_ sender: Any) {
        
        let credentials = Credentials(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        if authenticationSwitch.isOn { // Log In
            APIManager.shared.login(with: credentials, success: authenticationSuccess, error: authenticationError)
        } else { // Registration
            APIManager.shared.register(with: credentials, success: authenticationSuccess, error: authenticationError)
        }
    }
    
    private func authenticationSuccess() {
        // Show next screen
    }

    private func authenticationError(_ error: Error) {
        // Show error
    }
}
