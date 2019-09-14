//
//  TaskModel.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import Foundation

enum TaskPriority: String, Decodable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

struct TaskModel: Decodable {
    let id: Int
    let title: String
    let dueBy: Int
    let priority: TaskPriority
}
