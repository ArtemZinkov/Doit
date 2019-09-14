//
//  TaskTableViewCell.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

final class TaskTableViewCell: UITableViewCell {
    
    override var reuseIdentifier: String? { return String(describing: self) }
    
    func setup(with model: TaskModel) {
        backgroundColor = .init(red: .random(in: 0..<1),
                                green: .random(in: 0..<1),
                                blue: .random(in: 0..<1),
                                alpha: .random(in: 0..<1))
    }
}
