//
//  Router.swift
//  Doit
//
//  Created by Артём Зиньков on 9/14/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

final class Router {
    
    public static func route(to route: Routes, _ parameter: Any? = nil) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                shared.route(to: route, parameter)
            }
        } else {
            shared.route(to: route, parameter)
        }
    }
    
    enum Routes {
        case Authorization
        case TaskList
        case TaskDetail
        case EditTask
        case CreateTask
    }
    
    private static var shared = Router()
    private var navigationController: UINavigationController?
    
    public static func set(navigationController: UINavigationController?) {
        if Router.shared.navigationController == nil {
            Router.shared.navigationController = navigationController
        }
    }
}

extension Router {
    
    func route(to route: Routes, _ parameter: Any? = nil) {
        switch route {
        case .Authorization:
            if let authorizationViewController = UIStoryboard(name: "Authorization", bundle: nil).instantiateViewController(withIdentifier: "AuthorizationViewController") as? AuthorizationViewController {
                navigationController?.visibleViewController?.present(authorizationViewController, animated: true)
            }
        case .TaskList:
            
            if passPrecheck(TaskListViewController.self) {
                return
            }
            
            if let taskListViewController = UIStoryboard(name: "TaskList", bundle: nil).instantiateViewController(withIdentifier: "TaskListViewController") as? TaskListViewController {
                navigationController?.pushViewController(taskListViewController, animated: true)
            }
        case .TaskDetail:
            
            if passPrecheck(DetailTaskViewController.self) {
                return
            }
            
            if let detailTaskViewController = UIStoryboard(name: "DetailTask", bundle: nil).instantiateViewController(withIdentifier: "DetailTaskViewController") as? DetailTaskViewController {
                
                if let model = parameter as? TaskModel {
                    detailTaskViewController.setup(with: model)
                }
                
                navigationController?.pushViewController(detailTaskViewController, animated: true)
            }
        case .EditTask:
            
            if passPrecheck(EditTaskViewController.self) {
                return
            }
            
            if let detailTaskViewController = UIStoryboard(name: "DetailTask", bundle: nil).instantiateViewController(withIdentifier: "EditTaskViewController") as? EditTaskViewController {
                
                if let model = parameter as? TaskModel {
                    detailTaskViewController.setup(with: model)
                }
                
                navigationController?.pushViewController(detailTaskViewController, animated: true)
            }
            
        case .CreateTask:
            
            if passPrecheck(EditTaskViewController.self) {
                return
            }
            
            if let detailTaskViewController = UIStoryboard(name: "DetailTask", bundle: nil).instantiateViewController(withIdentifier: "EditTaskViewController") as? EditTaskViewController {
                
                if let delegate = parameter as? TaskCreationDelegate {
                    detailTaskViewController.delegate = delegate
                }
                
                navigationController?.pushViewController(detailTaskViewController, animated: true)
            }
        }
    }
    
    // Checking is there any controller for this class
    private func passPrecheck<T: UIViewController>(_ T: T.Type) -> Bool {
        
        if navigationController?.topViewController is T {
            return true
        }
        
        if let taskListViewController = navigationController?.viewControllers.first(where: { return $0 is T }) {
            navigationController?.pushViewController(taskListViewController, animated: true)
            return true
        }
        
        return false
    }
}
