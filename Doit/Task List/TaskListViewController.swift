//
//  TaskListViewController.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

final class TaskListViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private var cellModels: [TaskModel] { return model?.tasks ?? [] }
    private var model: TaskListModel! { didSet { tableView.reloadData() } }
    private var sortBy = "title"
    private var isAscending = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.layer.cornerRadius = addButton.frame.height / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Router.set(navigationController: navigationController)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 9001 // Kame-Kame-Ha!
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateTasks), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTasks()
    }
    
    @IBAction private func addTask() {
        Router.route(to: .CreateTask, self)
    }
    
    @IBAction private func sort(_ sender: UIBarButtonItem) {
        
        let handler: (UIAlertAction) -> Void = { [weak self] alertAction in
            if let wself = self, let title = alertAction.title {
                wself.sortBy = title == "Date" ? "dueBy" : title.lowercased()
                
                let handler: (UIAlertAction) -> Void = { [weak self] alertAction in
                    if let wself = self {
                        wself.isAscending = alertAction.title == "Ascending"
                        wself.updateTasks()
                    }
                }
                
                let sortAlert = UIAlertController(title: "Chose Order to sort", message: nil, preferredStyle: .actionSheet)
                sortAlert.addAction(UIAlertAction(title: "Ascending", style: .default, handler: handler))
                sortAlert.addAction(UIAlertAction(title: "Descending", style: .default, handler: handler))
                
                wself.present(sortAlert, animated: true)
            }
        }
        
        let sortAlert = UIAlertController(title: "Chose Property to sort by", message: nil, preferredStyle: .actionSheet)
        sortAlert.addAction(UIAlertAction(title: "Title", style: .default, handler: handler))
        sortAlert.addAction(UIAlertAction(title: "Date", style: .default, handler: handler))
        sortAlert.addAction(UIAlertAction(title: "Priority", style: .default, handler: handler))
        sortAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(sortAlert, animated: true)
    }
    
    @objc private func updateTasks() {
        if !APIManager.hasToken {
            Router.route(to: .Authorization)
        } else {
            let parameters = ["page": (model?.meta.current ?? 1).description,
                              "sort": "\(sortBy) \(isAscending ? "asc" : "desc")"]
            refreshControl.beginRefreshing()
            APIManager.shared.getTasks(with: parameters, { [weak self] taskListModel in
                self?.model = taskListModel
                self?.refreshControl.endRefreshing()
            })
        }
    }
}

// MARK: - UITableViewDataSource Methods
extension TaskListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let taskCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? TaskTableViewCell,
            let cellModel = cellModels[safe: indexPath.row] {
            
            taskCell.setup(with: cellModel)
            return taskCell
        }
        return TaskTableViewCell()
    }
}

// MARK: - UITableViewDelegate Methods
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Router.route(to: .TaskDetail, cellModels[safe: indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let model = cellModels[safe: indexPath.row] {
            refreshControl.beginRefreshing()
            APIManager.shared.delete(model, { [weak self] in
                self?.updateTasks()
            })
        }
    }
}

// MARK: - TaskCreationDelegate Methods
extension TaskListViewController: TaskCreationDelegate {
    func createdTask() {
        updateTasks()
    }
}
