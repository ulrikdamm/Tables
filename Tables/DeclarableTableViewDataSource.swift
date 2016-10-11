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
	
	public var cellTypeForRow : ((String) -> UITableViewCell.Type?)?
	
	public private(set) var tableView : UITableView?
	
	private var registedCellTypes : Set<String> = []
	
	var updateCount = 0
	
	public func attachToTableView(_ tableView : UITableView) {
		self.tableView = tableView
		registedCellTypes = []
		tableView.dataSource = self
	}
	
	public func update(_ sections : [Section]) {
		guard let tableView = tableView else { return }
		let diff = DeclarableTableViewDiff(tableView: tableView)
		
		updateCount += 1
		
		diff.performDiff(updateCount, from: self.sections, to: sections) { id, changes in
			guard id == self.updateCount else { return }
			
			self.sections = sections
			diff.performUpdate(sectionChanges: changes.0, rowChanges: changes.1)
			
			for cell in tableView.visibleCells {
				let indexPath = tableView.indexPath(for: cell)
				
				if let indexPath = indexPath, var cell = cell as? DeclarativeCell {
					cell.cellType = self.rowAtIndexPath(indexPath)!
				}
			}
		}
	}
	
	public func rowAtIndexPath(_ indexPath : Foundation.IndexPath) -> CellType? {
		guard (indexPath as NSIndexPath).section < sections.count else { return nil }
		let section = sections[(indexPath as NSIndexPath).section]
		
		guard (indexPath as NSIndexPath).row < section.rows.count else { return nil }
		let row = section.rows[(indexPath as NSIndexPath).row]
		
		return row
	}
	
	func cellTypeForRowOrDefault(_ type : String) -> UITableViewCell.Type? {
		if let cellTypeForRow = cellTypeForRow, let cell = cellTypeForRow(type) {
			return cell
		}
		
		switch type {
		case TextInputCell.typeId: return InputCell.self
		case ButtonCell.typeId: return TablesButtonCell.self
		case _: return nil
		}
	}
	
	public func numberOfSections(in tableView : UITableView) -> Int {
		return sections.count
	}
	
	public func tableView(_ tableView : UITableView, numberOfRowsInSection section : Int) -> Int {
		assert(section < sections.count, "Invalid section index")
		
		return sections[section].rows.count
	}
	
	public func tableView(_ tableView : UITableView, cellForRowAt indexPath : IndexPath) -> UITableViewCell {
		let row = rowAtIndexPath(indexPath)!
		let cellId = type(of: row).typeId
		
		let cell : UITableViewCell
		
		if registedCellTypes.contains(cellId) {
			cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
		} else {
			if let cellType = cellTypeForRowOrDefault(cellId) {
				tableView.register(cellType, forCellReuseIdentifier: cellId)
				registedCellTypes.insert(cellId)
				cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
			} else {
				if let c = tableView.dequeueReusableCell(withIdentifier: cellId) {
					cell = c
				} else {
					if row is SubtitleCellType {
						cell = TablesPlainCell(style: .subtitle, reuseIdentifier: cellId)
					} else {
						cell = TablesPlainCell(style: .default, reuseIdentifier: cellId)
					}
				}
			}
		}
		
		if var cell = cell as? DeclarativeCell {
			cell.cellType = row
		}
		
		return cell
	}
	
	public func tableView(_ tableView : UITableView, titleForHeaderInSection section : Int) -> String? {
		assert(section < sections.count, "Invalid section index")
		
		return sections[section].header
	}
	
	public func tableView(_ tableView : UITableView, titleForFooterInSection section : Int) -> String? {
		assert(section < sections.count, "Invalid section index")
		
		return sections[section].footer
	}
	
	public func tableView(_ tableView : UITableView, canEditRowAt indexPath : IndexPath) -> Bool {
		return rowAtIndexPath(indexPath)! is EditableCellType
	}
	
	public func tableView(_ tableView : UITableView, commit editingStyle : UITableViewCellEditingStyle, forRowAt indexPath : IndexPath) {
		guard let row = rowAtIndexPath(indexPath)! as? EditableCellType else { fatalError("Editing non-editable cell at \(indexPath)") }
		row.deleteAction()
	}
	
	public func tableView(_ tableView : UITableView, canMoveRowAt indexPath : IndexPath) -> Bool {
		return rowAtIndexPath(indexPath)! is MovableCellType
	}
	
	public func tableView(_ tableView : UITableView, moveRowAt sourceIndexPath : IndexPath, to destinationIndexPath : IndexPath) {
		guard let row = rowAtIndexPath(sourceIndexPath)! as? MovableCellType else { fatalError("Moving non-movable cell at \(sourceIndexPath)") }
		
		var section = sections[(sourceIndexPath as NSIndexPath).section]
		let item = section.rows.remove(at: (sourceIndexPath as NSIndexPath).row)
		sections[(sourceIndexPath as NSIndexPath).section] = section
		
		var newSection = sections[(destinationIndexPath as NSIndexPath).section]
		newSection.rows.insert(item, at: (destinationIndexPath as NSIndexPath).row)
		sections[(destinationIndexPath as NSIndexPath).section] = newSection
		
		row.moveAction(SimpleIndexPath(indexPath: destinationIndexPath))
	}
	
	public func sectionForIndex(_ index : Int) -> Section? {
		return index >= sections.count ? nil : sections[index]
	}
	
	public func rowForIndexPath(_ indexPath : Foundation.IndexPath) -> CellType? {
		guard (indexPath as NSIndexPath).section < sections.count else { return nil }
		guard (indexPath as NSIndexPath).row < sections[(indexPath as NSIndexPath).section].rows.count else { return nil }
		return sections[(indexPath as NSIndexPath).section].rows[(indexPath as NSIndexPath).row]
	}
	
	public func findSection(_ sectionId : String) -> Int? {
		return sections.index { $0.id == sectionId }
	}
	
	public func findCell(_ sectionId : String, rowId : String) -> Foundation.IndexPath? {
		guard let sectionIndex = sections.index(where: { $0.id == sectionId }) else { return nil }
		guard let rowIndex = sections[sectionIndex].rows.index(where: { $0.id == rowId }) else { return nil }
		return Foundation.IndexPath(row: rowIndex, section: sectionIndex)
	}
}
