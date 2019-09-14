//
//  TaskListViewController.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

final class TaskListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var cellModels: [TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = .greatestFiniteMagnitude
        tableView.register(cellClass: TaskTableViewCell.self)
    }
}

// MARK: - UITableViewDataSource Methods
extension TaskListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let taskCell = tableView.dequeueReusableCell(TaskTableViewCell.self, for: indexPath),
            let cellModel = cellModels[safe: indexPath.row] {
            
            taskCell.setup(with: cellModel)
            return taskCell
        }
        return TaskTableViewCell()
    }
}
