//
//  Encodable.swift
//  Doit
//
//  Created by Артём Зиньков on 9/14/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import Foundation

public typealias JSON = [AnyHashable: Any]

extension Encodable {
    public func mapToJSON() -> JSON? {
        if let data = try? JSONEncoder().encode(self),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON {
            
            return json
        }
        
        return nil
    }
}
