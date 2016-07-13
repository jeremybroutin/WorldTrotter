//
//  ConversionViewController.swift
//  WorldTrotter
//
//  Created by Jeremy Broutin on 6/8/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import UIKit

class ConversionViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet var celsiusLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	
	var fahrenheitValue: Double? {
		didSet {
			updateCelsiusLabel()
		}
	}
	
	// set value of celsiusValue based on fahrenheitValue
	var celsiusValue: Double? {
		if let value = fahrenheitValue {
			return (value-32) * (5/9)
		} else {
			return nil
		}
	}
	
	// set a formatter to limit the celsiusLabel text to 1 decimal
	let numberFormatter: NSNumberFormatter = {
		let nf = NSNumberFormatter()
		nf.numberStyle = .DecimalStyle
		nf.minimumFractionDigits = 0
		nf.maximumFractionDigits = 1
		return nf
	}()
	
	// Time related properties
	let currentHour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
	let sunriseHour = 7
	let sunsetHour = 21
	
	/* MARK: - App Life Cycle */
	
	// Note: viewDidLoad is called after the view controller's interface file is loaded
	override func viewDidLoad() {
		// Always call the super implementation of viewDidLoad
		super.viewDidLoad()
		
		print("ConversionViewController loaded its view")
	}
	
	// Note: viewWillAppear is called just before a view controller's view is added to the window
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// switch to darker background at night
		if currentHour < sunriseHour && currentHour > sunsetHour {
			view.backgroundColor = UIColor.darkGrayColor()
		}
	}
	
	/* MARK: - Interface Builder Actions */
	
	// listen to text change in fahrenheit text field
	@IBAction func fahrenheitFieldEditingChanged(textField: UITextField){
		if let text = textField.text, number = numberFormatter.numberFromString(text){
			fahrenheitValue = number.doubleValue
		} else {
			fahrenheitValue = nil
		}
	}
	
	@IBAction func dismissKeyboard(sender:AnyObject){
		textField.resignFirstResponder()
	}
	
	/* MARK: - Helper functions */
	
	func updateCelsiusLabel(){
		if let value = celsiusValue {
			celsiusLabel.text = numberFormatter.stringFromNumber(value)
		} else {
			celsiusLabel.text = "---"
		}
	}
	
	/* MARK: - TextField Delegate Methods */
	
	// prevent the use of multiple decimal separators and non numeric character
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		let currentLocale = NSLocale.currentLocale()
		let decimalSeparator = currentLocale.objectForKey(NSLocaleDecimalSeparator) as! String
		
		let existingTextHasDecimalSeparator = textField.text?.rangeOfString(decimalSeparator)
		let replacementTextHasDecimalSeparator = string.rangeOfString(decimalSeparator)
		
		let characterSet = NSMutableCharacterSet.decimalDigitCharacterSet()
		characterSet.addCharactersInString(decimalSeparator)
		
		
		if existingTextHasDecimalSeparator != nil && replacementTextHasDecimalSeparator != nil {
			return false
		} else {
			if string.rangeOfCharacterFromSet(characterSet.invertedSet) == nil {
				return true
			} else {
				return false
			}
		}
		
	}

}

