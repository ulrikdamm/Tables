//
//  ViewController.swift
//  TablesTest
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit
import Tables

struct PlainRow : CellType {
	let title : String?
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
	]
	
	override func viewDidLoad() {
		let rows = cars.enumerate().map { i, c in Row("car\(i)", PlainRow(title: c.name)) }
		
		let section = Section("new_cars", rows: rows)
		
		tableView.tablesDataSource.update([section])
	}
}
