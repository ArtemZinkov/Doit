//
//  TaskTableViewCell.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

final class TaskTableViewCell: UITableViewCell {
    
    public static var dateFormatter: DateFormatter = { // Performance reason
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    func setup(with model: TaskModel) {
        titleLabel.text = model.title
        priorityLabel.text = model.priority?.rawValue
        if let dueBy = model.dueBy {
            dateLabel.text = TaskTableViewCell.dateFormatter.string(from: Date(timeIntervalSince1970: dueBy))
        }
    }
}
