//
//  ViewController.swift
//  TablesTest
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit
import Tables

struct Car {
	var name : String
	var year : Int
	var used : Bool
}

class ViewController : UIViewController {
	override func loadView() {
		view = TablesTableView(style: .Plain)
	}
	
	var tableView : TablesTableView {
		return view as! TablesTableView
	}
	
	var cars : [Car] = [
		Car(name: "My car", year: 1991, used: true),
		Car(name: "Mom's car", year: 2010, used: true),
		Car(name: "Boss' car", year: 2015, used: false),
	] { didSet { tableView.tablesDataSource.update(generateSections()) } }
	
	func showCar(car : Car) {
		let vc = UIViewController()
		vc.title = car.name
		vc.view.backgroundColor = .whiteColor()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	func deleteCar(car : Car) {
		cars = cars.filter { $0.name != car.name }
	}
	
	override func viewDidLoad() {
		tableView.tablesDataSource.update(generateSections())
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("add:"))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("edit:"))
	}
	
	func edit(sender : AnyObject?) {
		tableView.setEditing(true, animated: true)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("done:"))
	}
	
	func done(sender : AnyObject?) {
		tableView.setEditing(false, animated: true)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("edit:"))
	}
	
	func rowForCar(index : Int, car : Car) -> Row {
		let cell = EditableDetailsSubtitleCell(
			title: car.name,
			subtitle: String(car.year),
			action: { [weak self] in self?.showCar(car) },
			deleteAction: { [weak self] in self?.deleteCar(car) }
		)
		
		return Row("car\(index)", cell)
	}
	
	func generateSections() -> [Section] {
		let newCars = cars.filter { !$0.used }.enumerate().map(rowForCar)
		let oldCars = cars.filter { $0.used }.enumerate().map(rowForCar)
		
		var sections : [Section] = []
		
		if newCars.count > 0 {
			sections.append(Section("new_cars", header: "New cars", rows: newCars))
		}
		
		if oldCars.count > 0 {
			sections.append(Section("old_cars", header: "Used cars", rows: oldCars))
		}
		
		return sections
	}
	
	override func viewWillAppear(animated : Bool) {
		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRowAtIndexPath(indexPath, animated: animated)
		}
	}
	
	func add(sender : AnyObject?) {
		cars.append(Car(name: "Unnamed car #\(arc4random_uniform(1000))", year: 1980 + Int(arc4random_uniform(35)), used: arc4random_uniform(100) % 2 == 0))
	}
}
