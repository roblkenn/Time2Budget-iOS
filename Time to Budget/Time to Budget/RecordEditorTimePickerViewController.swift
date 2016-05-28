//
//  TimePickerViewController.swift
//  Time to Budget
//
//  Created by Robert Kennedy on 2/14/15.
//  Copyright (c) 2015 Arrken Games, LLC. All rights reserved.
//

import UIKit

class RecordEditorTimePickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // ========== View Properties ==========
    var recordEditorVC: RecordEditorViewController!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var colonLabel: UILabel!
    
    // ========== Time Picker Properties ==========
    var timeHourPickerData: [Int] = Factory.prepareTimeHourPickerData()
    var timeMinutePickerData: [Int] = Factory.prepareTimeMinutePickerData()
    var timePicked: Time = Time()

    // ==================== View Controller Methods ====================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.viewController(self)
        Style.button(self.doneButton)
        Style.label(self.colonLabel)

        // Time Picker Setup
        timePicker.dataSource = self
        timePicker.delegate = self
        
        if let unwrappedTime = recordEditorVC.timeSpent {
            timePicked = unwrappedTime
        } else {
            timePicked.hours = 0
            timePicked.minutes = 0
        }
        
        timePicker.selectRow(getHourIndex(), inComponent: 0, animated: true)
        timePicker.selectRow(getMinIndex(), inComponent: 1, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        labelForHours()
        labelForMinutes()
    }

    // ==================== UIPickerViewDataSource Methods ====================
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return timeHourPickerData.count
        } else {
            return timeMinutePickerData.count
        }
    }
    
    // ==================== UIPickerDelegate Methods ====================
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            return Style.picker(timeHourPickerData[row])
        }
        else {
            return Style.picker(timeMinutePickerData[row])
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            timePicked.hours = timeHourPickerData[row]
        } else {
            timePicked.minutes = timeMinutePickerData[row]
        }
    }
    
    // ==================== IBAction Methods ====================
    @IBAction func saveButtonPressed(sender: UIButton) {
        recordEditorVC.timeSpent = self.timePicked
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // ==================== Helper Methods ====================
    /**
     Returns the integer index for the currently selected hour based on the self.timePicked.hours property.
     
     - Parameter None:
     - returns: Int index for the currently selected hour.
     */
    func getHourIndex() -> Int {
        return timePicked.hours
    }
    
    /**
     Returns the integer index for the currently selected minutes based on the seld.timePicked.minutes property.
     
     - Parameter None:
     - returns: Int index for the currently selected minutes.
     */
    func getMinIndex() -> Int {
        if timePicked.minutes == 15 {
            return 1
        }
        else if timePicked.minutes == 30 {
            return 2
        }
        else if timePicked.minutes == 45 {
            return 3
        }
        else {
            return 0
        }
    }
    
    func labelForHours() {
        let lblText = "Hours"
        let lblWidth = self.timePicker.frame.size.width / CGFloat(self.timePicker.numberOfComponents)
        let lblXPos = self.timePicker.frame.origin.x
        let lblYPos = self.timePicker.frame.origin.y
        
        let hrsLabel = UILabel()
        hrsLabel.frame = CGRect(x: lblXPos, y: lblYPos, width: lblWidth, height: 20)
        hrsLabel.text = lblText
        hrsLabel.textAlignment = NSTextAlignment.Center
        
        Style.label(hrsLabel)
        
        self.view.addSubview(hrsLabel)
    }
    
    func labelForMinutes() {
        let lblText = "Minutes"
        let lblWidth = self.timePicker.frame.size.width / CGFloat(self.timePicker.numberOfComponents)
        let lblXPos = self.timePicker.frame.origin.x + lblWidth
        let lblYPos = self.timePicker.frame.origin.y
        
        let minsLabel = UILabel(frame: CGRect(x: lblXPos, y: lblYPos, width: lblWidth, height: 20))
        minsLabel.text = lblText
        minsLabel.textAlignment = NSTextAlignment.Center
        
        Style.label(minsLabel)
        
        self.view.addSubview(minsLabel)
    }
    
}
