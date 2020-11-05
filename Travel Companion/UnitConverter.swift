//
//  UnitConverter.swift
//  Travel Companion
//
//  Created by Nghia Nguyen on 30/5/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import UIKit
import Foundation

class UnitConverter: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var unitType: UISegmentedControl!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var fromUnit: UIPickerView!
    @IBOutlet weak var toUnit: UIPickerView!
    @IBOutlet weak var result: UILabel!
    
    var selectedFromUnit = 0    // Saved the index of selected item from fromUnit pickerview
    var selectedToUnit = 0      // Saved the index of selected item from toUnit pickerview
    
    // Use array of tuples (of string and arrays) to store the unit
    // Use Dimension from Foundation
    // Measurement of the same type are put in the same tuple
    let conversions: [(title: String, unit: [Dimension])] = [
        (title: "Distance", unit: [UnitLength.micrometers, UnitLength.nanometers, UnitLength.millimeters, UnitLength.centimeters, UnitLength.meters, UnitLength.kilometers, UnitLength.inches, UnitLength.feet, UnitLength.yards, UnitLength.miles, UnitLength.nauticalMiles]),
        (title: "Mass", unit: [UnitMass.micrograms, UnitMass.milligrams, UnitMass.grams, UnitMass.kilograms, UnitMass.metricTons, UnitMass.ounces, UnitMass.pounds, UnitMass.stones, UnitMass.shortTons]),
        (title: "Volume", unit: [UnitVolume.milliliters, UnitVolume.liters, UnitVolume.cubicMeters, UnitVolume.cubicFeet, UnitVolume.teaspoons, UnitVolume.tablespoons, UnitVolume.cups, UnitVolume.gallons]),
        (title: "Temperature", unit: [UnitTemperature.celsius, UnitTemperature.fahrenheit, UnitTemperature.kelvin])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set Delegate and Data Source
        fromUnit.delegate = self
        fromUnit.dataSource = self
        
        toUnit.delegate = self
        toUnit.dataSource = self
        
        // Set Delegate to check for input
        amount.delegate = self
        
        // Default segmented control required at the minimum 2 segments
        // Remove them all so we can build the segments from sratch as required
        unitType.removeAllSegments()
        
        // Enumerated to get the "index" and value of the array at the same time
        // Insert into segmented control segments with title and index from array
        for (index, conversion) in conversions.enumerated() {
            unitType.insertSegment(withTitle: conversion.title, at: index, animated: false)
        }
        
        // Default selection of segmented control at first tab
        unitType.selectedSegmentIndex = 0
        
        // Reset all value to default and reload both picker views
        unitChanged(self)
        
        // Allow user to turn keyboard off when tap elsewhere on screen
        turnOffKeyboardOnTap()
        
        // create a toolbar for a done button to be displayed above the keyboard
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
            
        // create a done button for each text field and picker view
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
            
        // create a flexible space so done button is displayed on the right
        let flexspace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
        // add done buttons to toolbar
        toolbar.setItems([flexspace, done], animated: true)
        toolbar.sizeToFit()
            
        // add toolbar to text fields
        amount.inputAccessoryView = toolbar
    }
        
    @objc func donePressed() {
        amount.resignFirstResponder()
    }
    
    // Add new tap gesture for turning off keyboard
    func turnOffKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.turnOffKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Turn off keyboard
    @objc func turnOffKeyboard() {
        view.endEditing(true)
    }
    
    // Whenever user move to new segment
    // Saved index reset to 0
    // Reset both picker views
    // Reset textfield
    // Reload both picker views
    // Update result
    @IBAction func unitChanged(_ sender: Any) {
        selectedFromUnit = 0
        selectedToUnit = 0
        fromUnit.selectRow(0, inComponent: 0, animated: false)
        toUnit.selectRow(0, inComponent: 0, animated: false)
        amount.text = "0"
        fromUnit.reloadAllComponents()
        toUnit.reloadAllComponents()
        updateResult()
    }
    
    // Update result if textfield value changed
    @IBAction func textFieldChanged(_ sender: Any) {
        updateResult()
    }
    
    // Update result label
    @objc func updateResult() {
        // Attempt to retrieve text from amount textfield
        // If not possible then return empty string
        // Attempt to convert it to double
        // If not possible then treat it as 0.0
        let userInput = Double(amount.text ?? "") ?? 0.0
        
        // Retrieve the tuple from conversions array at same index of selected segment
        let conversion = conversions[unitType.selectedSegmentIndex]
        
        // Use saved index of selected item from picker views to extract correct unit
        // From fromUnit and toUnit
        let from = conversion.unit[selectedFromUnit]
        
        let to = conversion.unit[selectedToUnit]
        
        // Convert unit using built-in method
        let input = Measurement(value: userInput, unit: from)
        let output = input.converted(to: to)
        
        // Formatted and output result to result.text
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        result.text = formatter.string(from: output)
    }
    
    // There is only 1 column in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of row = number of element inside unit array inside conversions array
    // At the index of currently selected segment
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return conversions[unitType.selectedSegmentIndex].unit.count
    }
    
    // Populated picker view
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Define the format
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        
        // Get the index of current measurement type (segment)
        let conversion = conversions[unitType.selectedSegmentIndex]
        
        // Get unit from corresponding row index of picker view
        let unit = conversion.unit[row]
        
        // Return formatted unit name
        return formatter.string(from: unit).capitalized
    }
    
    // Retrieve index of selected row in picker view each time a new value is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Depend on which table is selected
        // The value will be saved to one of the two variable
        // tag = 0 -> fromTable, tag = 1 -> toTable
        if pickerView.tag == 0 {
            selectedFromUnit = row
        } else {
            selectedToUnit = row
        }
        
        // Update result each time the selected item changed
        updateResult()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // If amount text is not empty or input string is not empty (if there is existing text or if there is new input)
        // Check
        if amount.text != "" || string != "" {
            let tempText = (amount.text ?? "") + string // Concat input string with current text
            let isDouble = Double(tempText) != nil      // Attempt to cast to Double to check if it is double
            return isDouble                             // Return check result
        }
        return true                                     // Default
    }
}
