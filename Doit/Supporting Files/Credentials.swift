//
//  Credentials.swift
//  Doit
//
//  Created by Артём Зиньков on 9/14/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import Foundation

struct Credentials: Encodable {
    let email: String
    let password: String
    
    func isValid() -> Bool {
        return email.isValidEmail() && !password.isEmpty
    }
}
