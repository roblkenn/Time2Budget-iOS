//
//  TaskEditorCategorySelectorViewController.swift
//  Time to Budget
//
//  Created by Robert Kennedy on 3/1/15.
//  Copyright (c) 2015 Arrken Games, LLC. All rights reserved.
//

import UIKit
import RealmSwift

class TaskEditorCategorySelectorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var realm:Realm!
    var currentBudget:Budget!
    var taskEditorVC:TaskEditorViewController!
    var delegate: writeNameBackDelegate?
    var returning:Bool? = false
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CategoryView", bundle: nil)
        self.tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "CategoryView")
        
        self.realm = try! Realm()
        self.currentBudget = realm.objects(Budget).filter("isCurrent = TRUE").first!

        // Do any additional setup after loading the view.
        fixContentInset(calledFromSegue: false)
    }
    
    /*
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.tableView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        }
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //==================== UITableViewDataSource Methods ====================
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Int(currentBudget.categories.count)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let categoryCell = Factory.prepareCategoryCell(tableView: self.tableView, categoryList: currentBudget.categories, section: indexPath.row)
        
        return categoryCell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UITableViewCell()
        
    }
    
    //==================== UITableViewDelegate Methods ====================
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.writeNameBack(currentBudget.categories[indexPath.row].name)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }

    func fixContentInset(calledFromSegue calledFromSegue: Bool) {
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
