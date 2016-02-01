//
//  StyledTableViewDiff.swift
//  Thermo2
//
//  Created by Ulrik Damm on 28/07/15.
//  Copyright © 2015 Robocat. All rights reserved.
//

import UIKit

public class DeclarableTableViewDiff {
	public let tableView : UITableView
	
	public init(tableView : UITableView) {
		self.tableView = tableView
	}
	
	let queue = dispatch_queue_create("Table view diff queue", DISPATCH_QUEUE_SERIAL)
	
	var animationForRowType : (String -> UITableViewRowAnimation?)?
	
	public typealias DiffData = (sectionChanges : [Diff.Change], rowChanges : [Int: [Diff.Change]])
	
	public func performDiff(id : Int, from : [Section], to : [Section], completion : (Int, DiffData) -> Void) {
		let fromRowCount = from.map { $0.rows.count }.reduce(0, combine: +)
		let toRowCount = to.map { $0.rows.count }.reduce(0, combine: +)
		
		if fromRowCount > 25 || toRowCount > 25 {
			getChangesAsync(from, to: to) { changes in
				completion(id, changes)
			}
		} else {
			completion(id, diffSections(from: from, to: to))
		}
	}
	
	public func performUpdate(sectionChanges sectionChanges : [Diff.Change], rowChanges : [Int: [Diff.Change]]) {
		if sectionChanges.count > 0 || rowChanges.count > 0 {
			tableView.beginUpdates()
			
			for change in sectionChanges {
				applySectionChange(change)
			}
			
			for (section, changes) in rowChanges {
				for change in changes {
					applyRowChange(section, change: change)
				}
			}
			
			tableView.endUpdates()
		}
	}
	
	func getChangesAsync(from : [Section], to : [Section], completion : (sectionChanges : [Diff.Change], rowChanges : [Int: [Diff.Change]]) -> Void) {
		dispatch_async(queue) {
			let (sectionChanges, rowChanges) = self.diffSections(from: from, to: to)
			
			dispatch_async(dispatch_get_main_queue()) {
				completion(sectionChanges: sectionChanges, rowChanges: rowChanges)
			}
		}
	}
	
	public func sectionEquals(section1 : Identifiable, section2 : Identifiable) -> Bool {
		if let section1 = section1 as? Section, section2 = section2 as? Section {
			return section1 == section2
		} else {
			return false
		}
	}
	
	public func rowEquals(row1 : Identifiable, row2 : Identifiable) -> Bool {
		if let row1 = row1 as? CellType, row2 = row2 as? CellType {
			if row1.id == row2.id {
				if let rowType1 = row1 as? RefreshCellType {
					return !rowType1.shouldRefresh(to: row2)
				} else {
					return true
				}
			}
		}
		
		return false
	}
	
	public func diffSections(from from : [Section], to : [Section]) -> (sectionChanges : [Diff.Change], rowChanges : [Int: [Diff.Change]]) {
		let fromIds = from.map { $0.id }
		let toIds = to.map { $0.id }
		
		let sectionChanges = Diff.WFDistance(from: fromIds, to: toIds)
		
		var rowChanges : [Int: [Diff.Change]] = [:]
		
		for (toIndex, section) in to.enumerate() {
			if let fromIndex = from.indexOf({ $0.id == section.id }) {
				let fromRowIds = from[fromIndex].rows.map { $0.id }
				let toRowIds = section.rows.map { $0.id }
				
				let changes = Diff.WFDistance(from: fromRowIds, to: toRowIds)
				
				if changes.count > 0 {
					rowChanges[toIndex] = changes
				}
			}
		}
		
		return (sectionChanges, rowChanges)
	}
	
	public func applySectionChange(change : Diff.Change) -> Void {
		switch change {
		case .Insert(let at): tableView.insertSections(NSIndexSet(index: at), withRowAnimation: .Automatic)
		case .Remove(let at): tableView.deleteSections(NSIndexSet(index: at), withRowAnimation: .Automatic)
		case .Move(let from, let to): tableView.moveSection(from, toSection: to)
		case .Update(let at): tableView.reloadSections(NSIndexSet(index: at), withRowAnimation: .None)
		}
	}
	
	public func applyRowChange(section : Int, change : Diff.Change) -> Void {
		switch change {
		case .Insert(let at): tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: at, inSection: section)], withRowAnimation: .Automatic)
		case .Remove(let at): tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: at, inSection: section)], withRowAnimation: .Automatic)
		case .Move(let from, let to): tableView.moveRowAtIndexPath(NSIndexPath(forRow: from, inSection: section), toIndexPath: NSIndexPath(forRow: to, inSection: section))
		case .Update(let at): tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: at, inSection: section)], withRowAnimation: .Automatic)
		}
	}
}
