//
//  Category.swift
//  Time to Budget
//
//  Created by Robert Kennedy on 12/11/14.
//  Copyright (c) 2014 Arrken Games, LLC. All rights reserved.
//

import Foundation
import RealmSwift

public class Category: Object {
    // ==================== Properties ====================
    public dynamic var name = ""
    public dynamic var totalTimeRemaining = 0.0
    public dynamic var totalTimeBudgeted = 0.0
    public dynamic var parent: Budget!
    public let tasks = List<Task>()
    
    // ==================== Methods ====================
    public func calcTime() {
        self.totalTimeRemaining = 0.0
        self.totalTimeBudgeted = 0.0
        
        for task in tasks {
            totalTimeRemaining += task.timeRemaining
            totalTimeBudgeted += task.timeBudgeted
        }
    }
    
}
