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
		let carRow = Row("car", PlainRow(title: "Car"))
		
		let section = Section("new_cars", rows: [carRow])
		
		tableView.tablesDataSource.update([section])
	}
}
