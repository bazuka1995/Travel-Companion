//
//  CurrencyConverter.swift
//  Travel Companion
//
//  Created by Kurtis Stringer on 30/5/20.
//  Copyright © 2020 Kurtis Stringer. All rights reserved.
//

import UIKit
import Foundation
import Network

class CurrencyConverter: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
        //items to display in pickerview
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryList[row]
        //match items to row
    }
    
    var fromCountry: String = "AUD"
    var toCountry: String = "USD"
    var lastCache: String = ""
    var countryList = ["AUD", "CAD", "EUR", "GBP", "NZD", "USD"]
    var fromPicker: UIPickerView!
    var toPicker: UIPickerView!

    @IBOutlet var amountField: UITextField!
    @IBOutlet var testButton: UIButton!
    @IBOutlet var testLabel: UILabel!
    @IBOutlet var fromBox: UITextField!
    @IBOutlet var toBox: UITextField!
    
    var apiStringResult: String = ""
    var apiResult: String = ""

    var currenciesR = [String: CurrencyRate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fromBox.tag = 1
        toBox.tag = 2
        fromPicker = UIPickerView()
        toPicker = UIPickerView()
        fromPicker.dataSource = self
        toPicker.dataSource = self
        fromPicker.delegate = self
        toPicker.delegate = self
        fromBox.inputView = fromPicker //box to display chosen picker view source country
        toBox.inputView = toPicker //textbox to display chosen picker view destination country
        fromBox.text = countryList[0] //initally set source country to Australia
        toBox.text = countryList[5] //initially set destination country to USA
        
        // create a toolbar for a done button to be displayed above the keyboard
        let toToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let fromToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let amountToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        
        // create a done button for each text field and picker view
        let fromDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(fromPressed))
        let toDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(toPressed))
        let amountDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(amountPressed))
        
        // create a flexible space so done button is displayed on the right
        let flexspace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // add done buttons to toolbar
        fromToolbar.setItems([flexspace, fromDone], animated: true)
        toToolbar.setItems([flexspace, toDone], animated: true)
        amountToolbar.setItems([flexspace, amountDone], animated: true)
        fromToolbar.sizeToFit()
        toToolbar.sizeToFit()
        amountToolbar.sizeToFit()
        
        // add toolbar to text fields
        fromBox.inputAccessoryView = fromToolbar
        toBox.inputAccessoryView = toToolbar
        amountField.inputAccessoryView = amountToolbar
        
        // Allow user to turn keyboard off when tap elsewhere on screen
        turnOffKeyboardOnTap()
    }
    
    @objc func fromPressed() {
        fromBox.resignFirstResponder()
    }
    
    @objc func toPressed() {
        toBox.resignFirstResponder()
    }
    
    @objc func amountPressed() {
        amountField.resignFirstResponder()
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
    
    func URLBuilder() -> String {
        //generate the url to send for API
        var result: String = ""
        if fromCountry == "AUD" {
            result = String("https://api.exchangeratesapi.io/latest?base=AUD&symbols=CAD,EUR,GBP,NZD,USD")
        }
        else if fromCountry == "CAD" {
            result = String("https://api.exchangeratesapi.io/latest?base=CAD&symbols=AUD,EUR,GBP,NZD,USD")
        }
        else if fromCountry == "EUR" {
            result = String("https://api.exchangeratesapi.io/latest?base=EUR&symbols=AUD,CAD,GBP,NZD,USD")
        }
        else if fromCountry == "GBP" {
            result = String("https://api.exchangeratesapi.io/latest?base=GBP&symbols=AUD,CAD,EUR,NZD,USD")
        }
        else if fromCountry == "NZD" {
            result = String("https://api.exchangeratesapi.io/latest?base=NZD&symbols=AUD,CAD,EUR,GBP,USD")
        }
        else if fromCountry == "USD" {
            result = String("https://api.exchangeratesapi.io/latest?base=USD&symbols=AUD,CAD,EUR,GBP,NZD")
        }
        else {
            result = String("https://api.exchangeratesapi.io/latest?base=AUD&symbols=CAD,EUR,GBP,NZD,USD")
        }
        return result
    }
    
    func getExchangeRates() {
        //check if the source and destination countries are the same
        if fromCountry != toCountry {
            //create URL first
            if self.lastCache != fromCountry { //check if the last source country is the same, and if it is, dont re-grab info from internet
                self.currenciesR.removeAll(keepingCapacity: false) //clear dictionary of exchange rates
                self.lastCache = fromCountry // set the "last country" to current country
                let session = URLSession.shared
                let url = URL(string: URLBuilder())

                if let url = url {
                    let task = session.dataTask(with: url, completionHandler: {(data, response, error) in
                        if let data = data {
                            if let dataString = String(data: data, encoding: .utf8) {
         
                                sleep(2) //wait for response (slow internet)
                                self.apiStringResult = (dataString)
                                do {
                                    let myJson = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                                    
                                    let convertedString = String(data: data, encoding: String.Encoding.utf8) //convert json to string
                                    self.apiResult = convertedString ?? "error"
                                    
                                    if self.apiResult != "error" {
                                    
                                        var counter = 11 //starting point in string
                                        for _ in 1..<6 { // for each currency
                                            var start = self.apiResult.index(self.apiResult.startIndex, offsetBy: counter)
                                            counter += 3
                                            var end = self.apiResult.index(self.apiResult.startIndex, offsetBy: counter)
                                            var range = start..<end
                                            var name = String(self.apiResult[range])
                                            
                                            counter += 2
                                            start = self.apiResult.index(self.apiResult.startIndex, offsetBy: counter)
                                            
                                            let tempstring = self.apiResult.substring(from: self.apiResult.index(self.apiResult.startIndex, offsetBy: counter))
                                            
                                            let temp1 = tempstring.index(after: tempstring.firstIndex(of: "}")!).encodedOffset - 1 //get int value of index
                                            let temp2 = tempstring.index(after: tempstring.firstIndex(of: ",")!).encodedOffset - 1
                                            self.apiResult = tempstring
                                            if temp1 < temp2 { //if there is a } before comma, go to there first (end)
                                                counter = temp1
                                                range = tempstring.startIndex..<tempstring.firstIndex(of: "}")!
                                            }
                                            else {
                                                counter = temp2
                                                range = tempstring.startIndex..<tempstring.firstIndex(of: ",")!
                                            }
                                            
                                            
                                            
                                            let amount = Float(self.apiResult[range])
                                            
                                            self.currenciesR[name] = CurrencyRate(name: name, rate: amount!) //add currency to dictionary of exchange rates
                                            
                                            counter += 2
                                            
                                        }
                                    }
                                    else {
                                        //error occured
                                        self.MsgBox(_message: "Failed to get exchange rates from internet")
                                    }
                                }
                                catch {
                                    self.MsgBox(_message: "Failed to get exchange rates from internet")
                                }
                                if self.apiResult != "error"{
                                    DispatchQueue.main.async { //update labels with correct conversion and (not anymore) current date
                                        //let date = Date()
                                        //let formatter = DateFormatter()
                                        //formatter.dateFormat = "dd.MM.yyyy"
                                        let amount:Float = (self.amountField.text as! NSString).floatValue
                                        let value = ((self.currenciesR[self.toCountry])?.getRate())! * amount
                                        self.testLabel.text = (NSString(format: "%.2f", value) as String)
                                        
                                    }
                                }
                               
                            }
                        }
                    })
                    task.resume()
                }
                
            }
            else if lastCache == fromCountry {  //dont use API if the source country is the same.
                if self.apiResult != "error" {
                    DispatchQueue.main.async { //update labels with correct conversion and (not anymore) current date
                        //let date = Date()
                        //let formatter = DateFormatter()
                        //formatter.dateFormat = "dd.MM.yyyy"
                        let amount:Float = (self.amountField.text as! NSString).floatValue
                        let value = ((self.currenciesR[self.toCountry])?.getRate())! * amount
                        self.testLabel.text = (NSString(format: "%.2f", value) as String)// + "    Correct as of " + formatter.string(from: date))
                    }
                }
                else {
                    MsgBox(_message: "An error occured, likely due to internet connection")
                }
            }
        }
        else { //source and destination countries are the same
            DispatchQueue.main.async { //update labels with correct conversion and (not anymore) current date
                //let date = Date()
                //let formatter = DateFormatter()
                //formatter.dateFormat = "dd.MM.yyyy"
                let amount:Float = (self.amountField.text as! NSString).floatValue
                //let value = ((self.currenciesR[self.toCountry])?.getRate())! * amount
                self.testLabel.text = (NSString(format: "%.2f", amount) as String) //+ "    Correct as of " + formatter.string(from: date))
            }
            
        }
    }
    
    struct CurrencyRate {
        let name: String
        let rate: Float
        func getName() -> String {
            return name
        }
        func getRate() -> Float {
            return rate
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fromPicker {
            fromCountry = countryList[row]
            fromBox.text = fromCountry
        }
        else if pickerView == toPicker {
            toCountry = countryList[row]
            toBox.text = toCountry
        }
    }
    
    func createPickerView() {
       let pickerView = UIPickerView()
       pickerView.delegate = self
       fromBox.inputView = pickerView
    }
    func dismissPickerView() { //debug only
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        fromBox.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    @IBAction func testButtonPress(_ sender: Any) { //convert button pressed
        do {
            let amount:Float = (self.amountField.text as! NSString).floatValue
            getExchangeRates()
        }
        catch {
            //invalid character in amount field
            MsgBox(_message: "Invalid character(s) in: amount")
        }
    }
    
    func MsgBox(_message: String) {
        let alert = UIAlertController(title: "Message", message: _message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

