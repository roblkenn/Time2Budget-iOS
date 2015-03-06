//
//  TaskEditorViewController.swift
//  Time to Budget
//
//  Created by Robert Kennedy on 3/1/15.
//  Copyright (c) 2015 Arrken Games, LLC. All rights reserved.
//

import UIKit

class TaskEditorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    var budgetEditorViewController:BudgetEditorViewController!
    var currentTask:Task?
    var returning:Bool? = false
    var editTask:Bool! = false
    
    var taskName:String?
    var taskMemo:String?
    var taskCategory:String?
    var taskTime:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editTask! {
            self.navigationItem.title = "Edit \(currentTask!.name)"
        } else {
            self.navigationItem.title = "Add Task"
        }

        // Do any additional setup after loading the view.
        if let unwrappedTask = currentTask? {
            self.taskName = unwrappedTask.name
            self.taskMemo = unwrappedTask.memo
            self.taskCategory = unwrappedTask.parent.name
            self.taskTime = unwrappedTask.timeBudgeted
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        //fixContentInset(calledFromSegue: false)
        self.tableView.reloadData()
    }
    
    //Table View Overrides
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return Factory.prepareAddTaskNameCell(tableView: self.tableView, name: self.taskName?)
        case 1:
            return Factory.prepareAddTaskMemoCell(tableView: self.tableView, memo: self.taskMemo?)
        case 2:
            return Factory.prepareAddTaskCategoryCell(tableView: self.tableView, categoryName: self.taskCategory?)
        default:
            return Factory.prepareAddTaskTimeCell(tableView: self.tableView, time: self.taskTime?)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 2 {
            performSegueWithIdentifier("showTaskEditorCategorySelectorView", sender: self)
        } else if indexPath.row == 3 {
            performSegueWithIdentifier("showTaskEditorTimePickerView", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showTaskEditorTimePickerView") {
            let timePickerVC = segue.destinationViewController as TaskEditorTimePickerViewController
            timePickerVC.taskEditorVC = self
        } else if (segue.identifier == "showTaskEditorCategorySelectorView") {
            let categorySelectorVC = segue.destinationViewController as TaskEditorCategorySelectorViewController
            categorySelectorVC.taskEditorVC = self
        }
        
        fixContentInset(calledFromSegue: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func taskNameTextfieldChanged(sender: UITextField) {
        if sender.text == "" {
            self.taskName = nil
        } else {
            self.taskName = sender.text
        }
    }
    
    @IBAction func taskMemoTextfieldChanged(sender: UITextField) {
        if sender.text == "" {
            self.taskMemo = nil
        } else {
            self.taskMemo = sender.text
        }
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        
        if let unwrappedCategory = self.taskCategory? {
            if let unwrappedTime = self.taskTime? {
                if let unwrappedName = self.taskName? {
                    if let unwrappedMemo = self.taskMemo? {
                        if self.editTask! {
                            if let unwrappedTask = currentTask? {
                                Database.updateTask(taskName: unwrappedTask.name, name: unwrappedName, memo: unwrappedMemo, time: unwrappedTime, categoryName: unwrappedCategory)
                            } else {
                                Factory.displayAlert(viewController: self, title: "Error: Task Missing", message: "Task missing while in edit mode. D':")
                            }
                        } else {
                            Database.addTask(name: unwrappedName, memo: unwrappedMemo, time: unwrappedTime, categoryName: unwrappedCategory)
                        }
                    } else {
                        if self.editTask! {
                            if let unwrappedTask = currentTask? {
                                Database.updateTask(taskName: unwrappedTask.name, name: unwrappedName, memo: "", time: unwrappedTime, categoryName: unwrappedCategory)
                            } else {
                                Factory.displayAlert(viewController: self, title: "Error: Task Missing", message: "Task missing while in edit mode. D':")
                            }
                        } else {
                            Database.addTask(name: unwrappedName, memo: "", time: unwrappedTime, categoryName: unwrappedCategory)
                        }
                    }
                } else {
                    Factory.displayAlert(viewController: self, title: "Name Not Given", message: "You must name the task before saving.")
                }
            } else {
                Factory.displayAlert(viewController: self, title: "Time Budgeted Not Selected", message: "You must select an amount of time to budget.")
            }
        } else {
            Factory.displayAlert(viewController: self, title: "Category Not Selected", message: "You must select a Category")
        }
        
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func fixContentInset(#calledFromSegue: Bool) {
        if calledFromSegue {
            if (returning != nil) {
                self.returning = true
            }
        } else {
            if (returning != nil) {
                if !returning! {
                    self.tableView.contentInset.top = 64
                }
                else if returning! {
                    self.tableView.contentInset.top -= 64
                    self.returning = nil
                }
            }
            else {
                
            }
        }
    }
}