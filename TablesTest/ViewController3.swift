//
//  ViewController3.swift
//  Tables
//
//  Created by Ulrik Damm on 09/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit
import Tables

class DarkTableView : TablesTableView {
	init(style : UITableViewStyle) {
		super.init(style: style)
		setStyle()
	}
	
	required init?(coder : NSCoder) {
		super.init(coder: coder)
		setStyle()
	}
	
	func setStyle() {
		backgroundColor = UIColor(red: 62 / 255.0, green: 139 / 255.0, blue: 162 / 255.0, alpha: 1)
	}
}

class DarkTableViewCell : TablesPlainCell {
	override init(style : UITableViewCellStyle, reuseIdentifier : String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setStyle()
	}
	
	required init?(coder : NSCoder) {
		super.init(coder: coder)
		setStyle()
	}
	
	func setStyle() {
		backgroundColor = UIColor(red: 62 / 255.0, green: 139 / 255.0, blue: 162 / 255.0, alpha: 1)
		textLabel?.font = UIFont(name: "Didot", size: 15)
		textLabel?.textColor = .whiteColor()
	}
}

class ViewController3 : UIViewController {
	override func loadView() {
		view = DarkTableView(style: .Grouped)
	}
	
	var contentView : DarkTableView {
		return view as! DarkTableView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		contentView.tablesDataSource.cellTypeForRow = { _ in return DarkTableViewCell.self }
		
		let rows : [CellType] = [
			PlainCell(id: "1", title: "Plain Cell"),
			DetailsCell(id: "2", title: "Details Cell", action: deselect),
			EditableCell(id: "3", title: "Editable Cell", deleteAction: { _ in }),
			EditableDetailsCell(id: "4", title: "Editable Details Cell", action: deselect, deleteAction: { _ in })
		]
		
		contentView.tablesDataSource.update([Section("section", rows: rows)])
	}
	
	func deselect() {
		if let selected = contentView.indexPathForSelectedRow {
			contentView.deselectRowAtIndexPath(selected, animated: true)
		}
	}
}
