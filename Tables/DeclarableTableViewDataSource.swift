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
				cell.cellType = rowAtIndexPath(indexPath)!
			}
		}
	}
	
	public func rowAtIndexPath(indexPath : NSIndexPath) -> CellType? {
		guard indexPath.section < sections.count else { return nil }
		let section = sections[indexPath.section]
		
		guard indexPath.row < section.rows.count else { return nil }
		let row = section.rows[indexPath.row]
		
		return row
	}
	
	func cellTypeForRowOrDefault(type : String) -> UITableViewCell.Type? {
		if let cellTypeForRow = cellTypeForRow, cell = cellTypeForRow(type) {
			return cell
		}
		
		switch type {
		case TextInputCell.typeId: return InputCell.self
		case ButtonCell.typeId: return TablesButtonCell.self
		case _: return nil
		}
	}
	
	public func numberOfSectionsInTableView(tableView : UITableView) -> Int {
		return sections.count
	}
	
	public func tableView(tableView : UITableView, numberOfRowsInSection section : Int) -> Int {
		assert(section < sections.count, "Invalid section index")
		
		return sections[section].rows.count
	}
	
	public func tableView(tableView : UITableView, cellForRowAtIndexPath indexPath : NSIndexPath) -> UITableViewCell {
		let row = rowAtIndexPath(indexPath)!
		let cellId = row.dynamicType.typeId
		
		let cell : UITableViewCell
		
		if registedCellTypes.contains(cellId) {
			cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
		} else {
			if let cellType = cellTypeForRowOrDefault(cellId) {
				tableView.registerClass(cellType, forCellReuseIdentifier: cellId)
				registedCellTypes.insert(cellId)
				cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
			} else {
				if let c = tableView.dequeueReusableCellWithIdentifier(cellId) {
					cell = c
				} else {
					if row is SubtitleCellType {
						cell = TablesPlainCell(style: .Subtitle, reuseIdentifier: cellId)
					} else {
						cell = TablesPlainCell(style: .Default, reuseIdentifier: cellId)
					}
				}
			}
		}
		
		if var cell = cell as? DeclarativeCell {
			cell.cellType = row
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
		return rowAtIndexPath(indexPath)! is EditableCellType
	}
	
	public func tableView(tableView : UITableView, commitEditingStyle editingStyle : UITableViewCellEditingStyle, forRowAtIndexPath indexPath : NSIndexPath) {
		guard let row = rowAtIndexPath(indexPath)! as? EditableCellType else { fatalError("Editing non-editable cell at \(indexPath)") }
		row.deleteAction()
	}
	
	public func tableView(tableView : UITableView, canMoveRowAtIndexPath indexPath : NSIndexPath) -> Bool {
		return rowAtIndexPath(indexPath)! is MovableCellType
	}
	
	public func tableView(tableView : UITableView, moveRowAtIndexPath sourceIndexPath : NSIndexPath, toIndexPath destinationIndexPath : NSIndexPath) {
		guard let row = rowAtIndexPath(sourceIndexPath)! as? MovableCellType else { fatalError("Moving non-movable cell at \(sourceIndexPath)") }
		
		var section = sections[sourceIndexPath.section]
		let item = section.rows.removeAtIndex(sourceIndexPath.row)
		sections[sourceIndexPath.section] = section
		
		var newSection = sections[destinationIndexPath.section]
		newSection.rows.insert(item, atIndex: destinationIndexPath.row)
		sections[destinationIndexPath.section] = newSection
		
		row.moveAction(IndexPath(indexPath: destinationIndexPath))
	}
	
	public func sectionForIndex(index : Int) -> Section? {
		return index >= sections.count ? nil : sections[index]
	}
	
	public func rowForIndexPath(indexPath : NSIndexPath) -> CellType? {
		guard indexPath.section < sections.count else { return nil }
		guard indexPath.row < sections[indexPath.section].rows.count else { return nil }
		return sections[indexPath.section].rows[indexPath.row]
	}
	
	public func findSection(sectionId : String) -> Int? {
		return sections.indexOf { $0.id == sectionId }
	}
	
	public func findCell(sectionId : String, rowId : String) -> NSIndexPath? {
		guard let sectionIndex = sections.indexOf({ $0.id == sectionId }) else { return nil }
		guard let rowIndex = sections[sectionIndex].rows.indexOf({ $0.id == rowId }) else { return nil }
		return NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
	}
}
