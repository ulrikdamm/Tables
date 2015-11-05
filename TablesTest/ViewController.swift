//
//  ViewController.swift
//  TablesTest
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit
import Tables

struct PlainRow : SubtitleCellType, DetailsCellType, EditableCellType {
	let title : String?
	let subtitle : String?
	
	let action : Void -> Void
	let deleteAction : Void -> Void
}

struct Car {
	let name : String
	let year : Int
	let used : Bool
}

class ViewController : UIViewController {
	override func loadView() {
		view = TablesTableView(style: .Grouped)
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
	}
	
	func generateSections() -> [Section] {
		let carCell : ((Int, Car) -> Row) = { i, c in
			Row("car\(i)", PlainRow(title: c.name, subtitle: String(c.year), action: { [weak self] in self?.showCar(c) }, deleteAction: { [weak self] in self?.deleteCar(c) }))
		}
		
		let newCars = cars.filter { !$0.used }.enumerate().map(carCell)
		let oldCars = cars.filter { $0.used }.enumerate().map(carCell)
		
		let newSection = Section("new_cars", header: "New cars", rows: newCars)
		let oldSection = Section("old_cars", header: "Used cars", rows: oldCars)
		
		return [newSection, oldSection]
	}
	
	override func viewWillAppear(animated : Bool) {
		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRowAtIndexPath(indexPath, animated: animated)
		}
	}
	
	func add(sender : AnyObject?) {
		cars.append(Car(name: "Unnamed car #\(arc4random_uniform(1000))", year: 2000, used: false))
	}
}
