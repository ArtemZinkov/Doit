//
//  DetailTaskViewController.swift
//  Doit
//
//  Created by Артём Зиньков on 9/15/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

final class DetailTaskViewController: UIViewController {
    
    public static var dateFormatter: DateFormatter = { // Performance reason
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter
    }()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var model: TaskModel!
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        Router.route(to: .EditTask, model)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    private func update() {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        priorityLabel.text = model.priority?.rawValue
        if let dueBy = model.dueBy {
            dateLabel.text = DetailTaskViewController.dateFormatter.string(from: Date(timeIntervalSince1970: dueBy))
        }
    }
    
    func setup(with model: TaskModel) {
        self.model = model
    }
}
