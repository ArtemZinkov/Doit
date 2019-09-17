//
//  TaskModel.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import Foundation

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
}

class TaskModel: Codable {
    let id: Int?
    var title: String?
    var description: String?
    var dueBy: TimeInterval?
    var priority: TaskPriority?
    
    public func mapToJSON() -> [String: String] {
        var json: [String: String] = [:]
        
        if let title = title                { json["title"] = title }
        if let dueBy = dueBy                { json["dueBy"] = Int(exactly: dueBy)!.description }
        if let id = id                      { json["id"] = id.description }
        if let description = description    { json["description"] = description }
        if let priority = priority          { json["priority"] = priority.rawValue }
        
        return json
    }
}
