//
//  Item.swift
//  Rock paper ice
//
//  Created by Leslie Coffie on 2026-08-17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
