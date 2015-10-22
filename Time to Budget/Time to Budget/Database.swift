//
//  Database.swift
//  Time to Budget
//
//  Created by Robert Kennedy on 1/23/15.
//  Copyright (c) 2015 Arrken Games, LLC. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

public class Database {
    
    public class func getExampleRealm() -> Realm {
        let path = NSBundle.mainBundle().pathForResource("example", ofType: "realm")
        let exampleRealm: Realm!
        do {
            exampleRealm = try Realm(configuration: Realm.Configuration(path: path, readOnly: true))
        } catch let error as NSError {
            NSErrorPointer().memory = error
            exampleRealm = nil
        }
        
        return exampleRealm
    }
    
    public class func newBudget() {
        let realm = try! Realm()
        
        let currentBudgetCount = realm.objects(Budget).filter("isCurrent == TRUE").count
        
        print("newBudget->currentBudgetCount: ", currentBudgetCount)
        
        if  currentBudgetCount > 0 {
            let oldBudget = realm.objects(Budget).filter("isCurrent == TRUE").first!
            
            try! realm.write {
                oldBudget.isCurrent = false
            }
            
            let newBudget = Budget()
            newBudget.autoInit()
            
            Database.migrateToNewBudget(oldBudget: oldBudget, newBudget: newBudget)
            
            try! realm.write {
                realm.add(newBudget)
            }
        } else {
            try! realm.write {
                let newBudget = Budget()
                newBudget.autoInit()
                realm.add(newBudget)
            }
        }
        
        let budgets = realm.objects(Budget)
        let currentBudgets = budgets.filter("isCurrent = true")
        
        print("newBudget->All Budgets:")
        for budget in budgets {
            print(budget.name)
        }
        print("newBduget->Current Budgets:")
        for current in currentBudgets {
            print(current.name)
        }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduleLocalNotification(Factory.archiveBudgetNotification())
    }
    
    public class func migrateToNewBudget(oldBudget oldBudget: Budget, newBudget: Budget) {
        let newCategories = List<Category>()
        let oldCategories = oldBudget.categories
        
        for var i = 0; i < oldCategories.count; i++ {
            let oldCategory = oldCategories[i] 
            
            let newCategory = Category()
            
            newCategory.name = oldCategory.name
            newCategory.parent = newBudget
            
            for var x = 0; x < oldCategory.tasks.count; x++ {
                let oldTask = oldCategory.tasks[x] 
                
                let newTask = Task()
                newTask.name = oldTask.name
                newTask.memo = oldTask.memo
                newTask.timeBudgeted = oldTask.timeBudgeted
                newTask.parent = newCategory
                newTask.calcTime()
                
                newCategory.tasks.append(newTask)
            }
            
            newCategory.calcTime()
            newCategories.append(newCategory)
        }
        
        for category in newCategories {
            newBudget.categories.append(category)
        }
    }
    
    public class func checkCategoryName(name name: String) -> Bool {
        let realm = try! Realm()
        
        let budget = realm.objects(Budget).filter("isCurrent = TRUE").first!
        let count = Int(budget.categories.filter("name = '\(name)'").count)
        
        if (count == 0) {
            return true
        } else if (count == 1) {
            return false
        } else {
            return false
        }
    }
    
    public class func addCategory(name name: String) {
        let realm = try! Realm()
        
        let currentBudget = realm.objects(Budget).filter("isCurrent = TRUE").first!
        
        if (Database.checkCategoryName(name: name)) {
            try! realm.write {
                let newCategory = Category()
                newCategory.name = name
                newCategory.calcTime()
                currentBudget.categories.append(newCategory)
            }
            
            let testCategory = realm.objects(Category).filter("name = '\(name)'").first!
            print("addCategory->testCategory.name: ", testCategory.name)
            
        } else {
            print("Category Name Taken")
        }
    }
    
    public class func deleteCategory(categoryName categoryName: String, retainTasks: Bool) {
        let realm = try! Realm()
        
        let currentBudget = realm.objects(Budget).filter("isCurrent = TRUE").first!
        let currentCategory = currentBudget.categories.filter("name = '\(categoryName)'").first!
        let currentCategoryTasks = currentCategory.tasks
        let oldIndex = currentBudget.categories.indexOf(currentCategory)!
        let loopCount = currentCategoryTasks.count
        
        if (retainTasks) {
            if realm.objects(Category).filter("name = 'Uncategorized'").count == 0 {
                Database.addCategory(name: "Uncategorized")
            }
            
            for var i = 0; i < loopCount; ++i {
                Database.moveTask(task: currentCategoryTasks.first!, newCategoryName: "Uncategorized")
            }
            
            try! realm.write {
                currentBudget.categories.removeAtIndex(oldIndex)
                realm.delete(currentCategory)
            }
        } else {
            for var i = 0; i < loopCount; ++i {
                Database.deleteTask(task: currentCategoryTasks.first!, retainRecords: false)
            }
            
            try! realm.write {
                currentBudget.categories.removeAtIndex(oldIndex)
                realm.delete(currentCategory)
            }
        }
    }
    
    public class func updateCategory(categoryName categoryName: String, newCategoryName: String) {
        let realm = try! Realm()
        let currentBudget = realm.objects(Budget).filter("isCurrent = TRUE").first!
        let currentCategory = currentBudget.categories.filter("name = '\(categoryName)'").first!
        
        try! realm.write {
            currentCategory.name = newCategoryName
        }
        
        let testCategory = realm.objects(Category).filter("name = '\(newCategoryName)'").first!
        print("updateCategory->newCategory.name: ", testCategory.name)
    }
    
    public class func checkTaskName(name name: String, category: Category) -> Bool {
        let realm = try! Realm()
        let count = realm.objects(Task).filter("name = '\(name)'").count
        
        if (count == 0) {
            return true
        } else if (count == 1) {
            return false
        } else {
            return false
        }
    }
    
    public class func addTask(name name: String, memo: String, time: Double, categoryName: String) {
        let realm = try! Realm()
        let currentBudget = realm.objects(Budget).filter("isCurrent = TRUE").first!
        let parentCategory = (currentBudget.categories.filter("name = '\(categoryName)'")).first!
        
        if (Database.checkTaskName(name: name, category: parentCategory)) {
            
            try! realm.write {
                let newTask = Task()
                
                newTask.parent = parentCategory
                newTask.name = name
                newTask.memo = memo
                newTask.timeBudgeted = time
                newTask.calcTime()
                
                parentCategory.tasks.append(newTask)
                parentCategory.calcTime()
            }
            
            let testTask = realm.objects(Task).filter("name = '\(name)'").first!
            print("addTask->testTask.name: ", testTask.name)
            print("addTask->testTask.memo: ", testTask.memo)
            print("addTask->testTask.time: ", testTask.timeBudgeted)
            print("addTask->testTask.categoryName: ", testTask.parent.name)
        } else {
            print("Task Name Taken")
        }
    }
    
    public class func moveTask(task task: Task, newCategoryName: String) {
        let realm = try! Realm()
        let currentBudget = realm.objects(Budget).filter("isCurrent = TRUE").first!
        let oldCategory = task.parent
        let oldIndex = oldCategory.tasks.indexOf(task)!
        let newCategory = currentBudget.categories.filter("name = '\(newCategoryName)'").first!

        try! realm.write {
            oldCategory.tasks.removeAtIndex(oldIndex)
            oldCategory.calcTime()
            task.parent = newCategory
            newCategory.tasks.append(task)
            newCategory.calcTime()
        }
        
        let testTask = realm.objects(Task).filter("name = \(task.name)").first!
        print("moveTask->testTask.name: ", testTask.name)
        print("moveTask->testTask.memo: ", testTask.memo)
        print("moveTask->testTask.time: ", testTask.timeBudgeted)
        print("moveTask->testTask.categoryName: ", testTask.parent.name)
    }
    
    public class func updateTask(task task: Task, name: String, memo: String, time: Double, categoryName: String) {
        let realm = try! Realm()

        try! realm.write {
            task.name = name
            task.timeBudgeted = time
            task.memo = memo
            task.calcTime()
            task.parent.calcTime()
        }
        
        if task.parent.name != categoryName {
            Database.moveTask(task: task, newCategoryName: categoryName)
        }
        
        let testTask = realm.objects(Task).filter("name = '\(name)'").first!
        print("moveTask->testTask.name: ", testTask.name)
        print("moveTask->testTask.memo: ", testTask.memo)
        print("moveTask->testTask.time: ", testTask.timeBudgeted)
        print("moveTask->testTask.categoryName: ", testTask.parent.name)
    }
    
    public class func deleteTask(task task: Task, retainRecords: Bool) {
        let realm = try! Realm()
        //let currentBudget = realm.objects(Budget).filter("isCurrent = TRUE").first!
        let currentRecords = task.records
        let parent = task.parent
        
        if (retainRecords) {
            let loopCount = task.records.count
            
            if realm.objects(Task).filter("name = 'Taskless Records'").count == 0 {
                Database.addTask(name: "Taskless Records", memo: "Retained records from a deleted Task.", time: 0.0, categoryName: "\(parent.name)")
            }
            
            for var i = 0; i < loopCount; ++i {
                Database.moveRecord(record: task.records.first!, newTaskName: "Taskless Records")
            }
        } else {
            try! realm.write {
                realm.delete(currentRecords)
            }
        }
        
        try! realm.write {
            realm.delete(task)
            parent.calcTime()
        }
    }
    
    public class func addRecord(parentTask parentTask: Task, note: String, timeSpent: Double, date: NSDate) {
        let realm = try! Realm()

        try! realm.write {
            let newRecord = Record()
            
            newRecord.parent = parentTask
            newRecord.note = note
            newRecord.timeSpent = timeSpent
            newRecord.date = date
            
            parentTask.records.append(newRecord)
            parentTask.calcTime()
        }
        
        let testRecord = realm.objects(Task).filter("name = '\(parentTask.name)'").first!.records.filter("note = '\(note)'").first!
        print("addRecord->testRecord.note", testRecord.note)
        print("addRecord->testRecord.timeSpent", testRecord.timeSpent)
        print("addRecord->testRecord.date", testRecord.date)
        print("addRecord->testRecord.parent", testRecord.parent.name)
    }
    
    public class func moveRecord(record record: Record, newTaskName: String) {
        let realm = try! Realm()
        let oldTask = record.parent
        let oldIndex = oldTask.records.indexOf(record)!
        let newTask = (realm.objects(Task).filter("name = '\(newTaskName)'")).first!
        
        try! realm.write {
            oldTask.records.removeAtIndex(oldIndex)
            oldTask.calcTime()
            record.parent = newTask
            newTask.records.append(record)
            newTask.calcTime()
        }
        
        let testRecord = realm.objects(Task).filter("name = '\(newTaskName)'").first!.records.filter("note = '\(record.note)'").first!
        print("addRecord->testRecord.note", testRecord.note)
        print("addRecord->testRecord.timeSpent", testRecord.timeSpent)
        print("addRecord->testRecord.date", testRecord.date)
        print("addRecord->testRecord.parent", testRecord.parent.name)
    }
    
    public class func deleteRecord(record record: Record) {
        let realm = try! Realm()
        let parent = record.parent
        let index = parent.records.indexOf(record)!

        try! realm.write {
            parent.records.removeAtIndex(index)
            realm.delete(record)
            parent.calcTime()
        }
    }
    
    public class func updateRecord(record record: Record, taskName: String, note: String, timeSpent: Double, date: NSDate) {
        let realm = try! Realm()

        try! realm.write {
            record.note = note
            record.timeSpent = timeSpent
            record.date = date
            record.parent.calcTime()
        }
        
        if record.parent.name != taskName {
            Database.moveRecord(record: record, newTaskName: taskName)
        }
        
        let testRecord = realm.objects(Task).filter("name = '\(taskName)'").first!.records.filter("note = '\(note)'").first!
        print("addRecord->testRecord.note", testRecord.note)
        print("addRecord->testRecord.timeSpent", testRecord.timeSpent)
        print("addRecord->testRecord.date", testRecord.date)
        print("addRecord->testRecord.parent", testRecord.parent.name)
    }
}