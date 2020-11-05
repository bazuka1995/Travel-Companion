//
//  FirstViewController.swift
//  Travel Companion
//
//  Created by Dov Royal on 30/5/20.
//  Copyright © 2020 Dov Royal. All rights reserved.
//

import UIKit

class TipCalculator: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var billTextField: UITextField!
    
    @IBOutlet weak var leftTip: UILabel!
    @IBOutlet weak var middleTip: UILabel!
    @IBOutlet weak var rightTip: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var billError: UILabel!
    @IBOutlet weak var recommendationLabel: UILabel!
    
    enum KeyboardError: Error { // create custom error
        case invalidDecimal
    }
    
    let countryList = Locale.isoRegionCodes.compactMap { Locale.current.localizedString(forRegionCode: $0) }.sorted(by: { $0 < $1 }) // get country list and sort it alphabetically
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        billTextField.resignFirstResponder()
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        billTextField.addTarget(self, action: #selector(self.validateNumber), for: .editingChanged)
        
        billTextField.delegate = self
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        
        // create an empty space on the left side so that the done button is on the right
        let flexspace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnAction))
        
        toolbar.setItems([flexspace, doneBtn], animated: true)
        toolbar.sizeToFit()
        
        // set toolbar as accessory view to keyboard
        billTextField.inputAccessoryView = toolbar
        
        // Set the default tip colours and values
        updateTipLabels(s1: "5%", s2: "10%", s3: "15%")
        updateLabelColour(b1: false, b2: true, b3: true)
        updateTipValues()
        
        billError.isHidden = true
        
        recommendationLabel.text = ""
        
        //listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // Allow user to turn keyboard off when tap elsewhere on screen
        turnOffKeyboardOnTap()
    }
    
    deinit {
        //stop listening for keyboard events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
    
    func getPercentage(s: String) -> Double {
        let r = s.index(s.startIndex, offsetBy: 0)..<s.index(s.endIndex, offsetBy: -1) // get the first two letters in the string a range
        
        let perc = Double(String(s[r]))! / 100 // convert to percentage
        
        return perc
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        recommendationLabel.textColor = UIColor.black
        switch countryList[row] { // what to do when a user selects a country on the scroller
        case "United States", "Canada", "Columbia", "Qatar", "Saudi Arabia", "United Arab Emirates", "Dubai", "Slovakia", "Estonia", "Poland", "Armenia", "Serbia", "American Samoa":
            updateTipLabels(s1: "10%", s2: "15%", s3: "20%")
            // leave tip
            updateLabelColour(b1: false, b2: true, b3: true) // set the middle and right tup value to red to indicate this is the expected amount
            recommendationLabel.text = "Tipping is expected in this country"
        case "Mexico", "Nicaragua", "Austria", "Italy", "Russia", "Jordan", "Morocco", "South Africa", "Egypt", "Israel", "Cuba", "Uruguay", "Bulgaria", "Afghanistan":
            updateTipLabels(s1: "5%", s2: "10%", s3: "15%")
            //leave tip
            updateLabelColour(b1: false, b2: true, b3: true)
            recommendationLabel.text = "Tipping is expected in this country but watch out for a service charge which is sometimes included in the bill"
        case "Chile", "Costa Rica", "Czechia", "France", "Hungary", "Sweden", "Germany", "Ireland", "Portugal", "United Kingdom", "Jersey":
            updateTipLabels(s1: "2%", s2: "5%", s3: "10%")
            // rounding of bill
            updateLabelColour(b1: false, b2: true, b3: false)
            recommendationLabel.text = "Tipping isn't expected in this country but a rounding of the bill is a nice gesture"
        case "China mainland", "Myanmar", "Singapore", "Taipei", "Nepal", "Cambodia", "Indonesia", "Vietnam", "Turkey", "Australia", "Iran", "Finland", "Norway", "Denmark", "Netherlands", "Belgium", "Switzerland", "Croatia", "Macedonia", "Brazil", "Paraguay", "Ecuador", "Argentina", "Albania", "India":
            updateTipLabels(s1: "1%", s2: "3%", s3: "5%")
            //not expected
            updateLabelColour(b1: true, b2: true, b3: false)
            recommendationLabel.text = "Tipping isn't expected in this country"
        case "Japan", "South Korea", "Georgia", "Iceland":
            updateTipLabels(s1: "1%", s2: "3%", s3: "5%")
            //dont tip - insult people
            updateLabelColour(b1: false, b2: false, b3: false)
            recommendationLabel.text = "Tipping isn't expected in this country and you risk insulting people"
            recommendationLabel.textColor = UIColor.red
        case "Peru", "Bolivia", "Spain", "Kazakhstan", "Mongolia", "Thailand":
            updateTipLabels(s1: "1%", s2: "3%", s3: "5%")
            //dont tip - surprise people
            updateLabelColour(b1: false, b2: false, b3: false)
            recommendationLabel.text = "Tipping isn't expected in this country but people will be pleasantly surprised or neutral at worst"
        default:
            updateTipLabels(s1: "5%", s2: "10%", s3: "15%")
            updateLabelColour(b1: false, b2: false, b3: false)
            recommendationLabel.text = ""
        }
        updateTipValues()
    }
    
    func updateTipLabels(s1: String, s2: String, s3: String) { // update the three tip labels
        leftLabel.text = s1
        middleLabel.text = s2
        rightLabel.text = s3
    }
    
    func updateLabelColour(b1: Bool, b2: Bool, b3: Bool) { // update the colour of the tip amount. Red means the recommended amount
        if (b1) {
            leftTip.textColor = UIColor.universalGreen
        } else {
            leftTip.textColor = UIColor.black
        }
        
        if (b2) {
            middleTip.textColor = UIColor.universalGreen
        } else {
            middleTip.textColor = UIColor.black
        }
        
        if (b3) {
            rightTip.textColor = UIColor.universalGreen
        } else {
            rightTip.textColor = UIColor.black
        }
    }
    
    func updateTipValues() {
        // fix error with over 1000 bill and nil left label
        leftTip.text = "$" + String(format: "%.2f", Double(billTextField.text!)! * getPercentage(s: leftLabel.text!))
        middleTip.text = "$" + String(format: "%.2f", Double(billTextField.text!)! * getPercentage(s: middleLabel.text!))
        rightTip.text = "$" + String(format: "%.2f", Double(billTextField.text!)! * getPercentage(s: rightLabel.text!))
    }
    
    @objc func validateNumber() {
        do {
            var count = 0 // stores number of decimals
        
            for str in billTextField.text! { // count the number of decimals
                if str == "." {
                    count = count + 1
                }
            }
            
            if (count > 1) { // if there is more than 1 decimal
                throw KeyboardError.invalidDecimal // throw error
            }
            
            billError.text = "Please enter a number with less digits" // default error message
            
            if (!billTextField.text!.contains(".")) { // if number doesnt contain a decimal point
                if (billTextField.text!.isNumeric && billTextField.text!.count < 7) { // has to be a number, less than 5 digits
                    billError.isHidden = true // hide error label
                    updateTipValues()
                } else {
                    billError.isHidden = false // show error label
                    
                    if (billTextField.text?.count == 0) {
                        billError.text = "Please enter a number"
                    }
                    
                    leftTip.text = "" // Remove tip values
                    middleTip.text = ""
                    rightTip.text = ""
                }
            } else {
                if (billTextField.text!.isNumeric && billTextField.text!.count < 10) { // has to be a number, less than 5 digits
                    billError.isHidden = true // hide error label
                    updateTipValues()
                } else {
                    billError.isHidden = false // show error label
                    
                    leftTip.text = "" // Remove tip values
                    middleTip.text = ""
                    rightTip.text = ""
                }
            }
        } catch {
            billError.isHidden = false // show error label
            billError.text = "Too many decimal places"
            
            leftTip.text = "" // Remove tip values
            middleTip.text = ""
            rightTip.text = ""
        }
    }
    
    @objc func doneBtnAction() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification: Notification) { // function that runs when the keyboard will change
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { // create a rectangle the same size as the keyboard
            return
        }
        if (notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification) {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
}
