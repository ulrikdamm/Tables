//
//  TableViewData.swift
//  Thermo2
//
//  Created by Ulrik Damm on 27/07/15.
//  Copyright © 2015 Robocat. All rights reserved.
//

import UIKit

public class DeclarableTableViewDataSource : NSObject, UITableViewDataSource {
	public var sections : [Section] = []
	
	public var cellTypeForRow : (String -> UITableViewCell.Type?)?
	
	public private(set) var tableView : UITableView?
	
	private var registedCellTypes : Set<String> = []
	
	public func attachToTableView(tableView : UITableView) {
		self.tableView = tableView
		registedCellTypes = []
		tableView.dataSource = self
	}
	
	public func update(sections : [Section]) {
		let old = self.sections
		self.sections = sections
		
		guard let tableView = tableView else { return }
		let diff = DeclarableTableViewDiff(tableView: tableView)
		diff.updateTableView(old, to: sections)
		
		for cell in tableView.visibleCells {
			let indexPath = tableView.indexPathForCell(cell)
			
			if let indexPath = indexPath, var cell = cell as? DeclarativeCell {
				cell.cellType = rowAtIndexPath(indexPath).type
			}
		}
	}
	
	public func rowAtIndexPath(indexPath : NSIndexPath) -> Row {
		assert(indexPath.section < sections.count, "Invalid indexPath section")
		let section = sections[indexPath.section]
		
		assert(indexPath.row < section.rows.count, "Invalid indexPath row")
		let row = section.rows[indexPath.row]
		
		return row
	}
	
	public func numberOfSectionsInTableView(tableView : UITableView) -> Int {
		return sections.count
	}
	
	public func tableView(tableView : UITableView, numberOfRowsInSection section : Int) -> Int {
		assert(section < sections.count, "Invalid section index")
		
		return sections[section].rows.count
	}
	
	public func tableView(tableView : UITableView, cellForRowAtIndexPath indexPath : NSIndexPath) -> UITableViewCell {
		let row = rowAtIndexPath(indexPath)
		let cellId = row.type.dynamicType.typeId
		
		let cell : UITableViewCell
		
		if registedCellTypes.contains(cellId) {
			cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
		} else {
			if let cellTypeForRow = cellTypeForRow, cellType = cellTypeForRow(cellId) {
				tableView.registerClass(cellType, forCellReuseIdentifier: cellId)
				registedCellTypes.insert(cellId)
				cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
			} else {
				if let c = tableView.dequeueReusableCellWithIdentifier(cellId) {
					cell = c
				} else {
					if row.type is SubtitleCellType {
						cell = TablesPlainCell(style: .Subtitle, reuseIdentifier: cellId)
					} else {
						cell = TablesPlainCell(style: .Default, reuseIdentifier: cellId)
					}
				}
			}
		}
		
		if var cell = cell as? DeclarativeCell {
			cell.cellType = row.type
		}
		
		return cell
	}
	
	public func tableView(tableView : UITableView, titleForHeaderInSection section : Int) -> String? {
		assert(section < sections.count, "Invalid section index")
		
		return sections[section].header
	}
	
	public func tableView(tableView : UITableView, titleForFooterInSection section : Int) -> String? {
		assert(section < sections.count, "Invalid section index")
		
		return sections[section].footer
	}
	
	public func tableView(tableView : UITableView, canEditRowAtIndexPath indexPath : NSIndexPath) -> Bool {
		return rowAtIndexPath(indexPath).type is EditableCellType
	}
	
	public func tableView(tableView : UITableView, commitEditingStyle editingStyle : UITableViewCellEditingStyle, forRowAtIndexPath indexPath : NSIndexPath) {
		guard let row = rowAtIndexPath(indexPath).type as? EditableCellType else { fatalError("Editing non-editable cell at \(indexPath)") }
		row.deleteAction()
	}
	
	public func tableView(tableView : UITableView, canMoveRowAtIndexPath indexPath : NSIndexPath) -> Bool {
		return rowAtIndexPath(indexPath).type is MovableCellType
	}
	
	public func tableView(tableView : UITableView, moveRowAtIndexPath sourceIndexPath : NSIndexPath, toIndexPath destinationIndexPath : NSIndexPath) {
		guard let row = rowAtIndexPath(sourceIndexPath).type as? MovableCellType else { fatalError("Moving non-movable cell at \(sourceIndexPath)") }
		row.moveAction(IndexPath(indexPath: destinationIndexPath))
	}
}
