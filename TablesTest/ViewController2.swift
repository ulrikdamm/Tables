//
//  ViewController2.swift
//  Tables
//
//  Created by Ulrik Damm on 08/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit
import Tables

class EmailValidator {
	class func validate(str : String) -> Bool {
		return str.rangeOfString("^[^@]+?@[^@]+?\\.[^@]+?$", options: .RegularExpressionSearch) != nil
	}
	
	class func validatePartial(str : String) -> Bool {
		return str.rangeOfString("^([^@]+?(@([^@\\.]+?(\\.([^@]+?)?)?)?)?)?$", options: .RegularExpressionSearch) != nil
	}
}

class ViewController2 : UIViewController {
	override func loadView() {
		view = TablesTableView(style: .Grouped)
	}
	
	var contentView : TablesTableView {
		return view as! TablesTableView
	}
	
	var name = "" { didSet { nameInvalid = false } }
	var nameInvalid = false { didSet { if nameInvalid != oldValue { update() } } }
	
	var email = "" { didSet { emailInvalid = !EmailValidator.validatePartial(email) } }
	var emailInvalid = false { didSet { if emailInvalid != oldValue { update() } } }
	
	var loading = false { didSet { if loading != oldValue { update() } } }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: Selector("clear:"))
		
		update()
	}
	
	func update() {
		contentView.tablesDataSource.update(generateSections())
	}
	
	func generateSections() -> [Section] {
		let nameRow = TextInputCell(
			id: "name",
			title: "Name",
			placeholder: "Donald Duck",
			enabled: !loading,
			invalid: nameInvalid,
			value: name,
			valueChanged: { [weak self] in self?.name = $0 },
			done: { [weak self] _ in self?.selectRow("email") }
		)
		
		let emailRow = TextInputCell(
			id: "email",
			title: "Email",
			placeholder: "donald@duck.com",
			enabled: !loading,
			invalid: emailInvalid,
			value: email,
			valueChanged: { [weak self] in self?.email = $0 },
			done: { [weak self] _ in self?.submit() }
		)
		
		let inputSection = Section("input", header: "User information", rows: [nameRow, emailRow])
		
		let submitRow = ButtonCell(
			id: "submit",
			title: "Submit",
			enabled: !loading,
			loading: loading,
			action: { [weak self] in self?.submit() }
		)
		
		let submitSection = Section("submit", rows: [submitRow])
		
		return [inputSection, submitSection]
	}
	
	func selectRow(id : String) {
		guard let indexPath = contentView.tablesDataSource.findCell("input", rowId: id) else { fatalError("Not found") }
		(contentView.cellForRowAtIndexPath(indexPath) as? InputCell)?.focus()
	}
	
	func submit() {
		if let selected = contentView.indexPathForSelectedRow {
			contentView.deselectRowAtIndexPath(selected, animated: true)
		}
		
		if name.characters.count == 0 {
			let alert = UIAlertController(title: "Missing name", message: "Please fill in all fields", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			
			nameInvalid = true
			return
		}
		
		if !EmailValidator.validate(email) {
			let alert = UIAlertController(title: "Invalid email", message: "Please enter a valid email", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			
			emailInvalid = true
			return
		}
		
		// Send request
		loading = true
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * NSEC_PER_SEC)), dispatch_get_main_queue()) { [weak self] in
			self?.loading = false
			
			let alert = UIAlertController(title: "Completed", message: nil, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
			self?.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	func clear(sender : AnyObject) {
		if loading {
			return
		}
		
		name = ""
		email = ""
		update()
	}
}
