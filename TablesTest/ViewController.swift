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

class ViewController : UIViewController {
	override func loadView() {
		view = TablesTableView(style: .Grouped)
	}
	
	var tableView : TablesTableView {
		return view as! TablesTableView
	}
	
	override func viewDidLoad() {
		let cars = [Row("car1", PlainRow(title: "Car 1")), Row("car2", PlainRow(title: "Car 2"))]
		
		let section = Section("new_cars", rows: cars)
		
		tableView.tablesDataSource.update([section])
	}
}
