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
	
	let queue = DispatchQueue(label: "Table view diff queue")
	
	var animationForRowType : ((String) -> UITableViewRowAnimation?)?
	
	public typealias DiffData = (sectionChanges : [Diff.Change], rowChanges : [Int: [Diff.Change]])
	
	public func performDiff(_ id : Int, from : [Section], to : [Section], completion : @escaping (Int, DiffData) -> Void) {
		let fromRowCount = from.map { $0.rows.count }.reduce(0, +)
		let toRowCount = to.map { $0.rows.count }.reduce(0, +)
		
		if fromRowCount > 25 || toRowCount > 25 {
			getChangesAsync(from, to: to) { changes in
				completion(id, changes)
			}
		} else {
			completion(id, diffSections(from: from, to: to))
		}
	}
	
	public func performUpdate(sectionChanges : [Diff.Change], rowChanges : [Int: [Diff.Change]]) {
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
	
	func getChangesAsync(_ from : [Section], to : [Section], completion : @escaping (_ sectionChanges : [Diff.Change], _ rowChanges : [Int: [Diff.Change]]) -> Void) {
		queue.async {
			let (sectionChanges, rowChanges) = self.diffSections(from: from, to: to)
			
			DispatchQueue.main.async {
				completion(sectionChanges, rowChanges)
			}
		}
	}
	
	public func sectionEquals(_ section1 : Identifiable, section2 : Identifiable) -> Bool {
		if let section1 = section1 as? Section, let section2 = section2 as? Section {
			return section1 == section2
		} else {
			return false
		}
	}
	
	public func rowEquals(_ row1 : Identifiable, row2 : Identifiable) -> Bool {
		if let row1 = row1 as? CellType, let row2 = row2 as? CellType {
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
	
	public func diffSections(from : [Section], to : [Section]) -> (sectionChanges : [Diff.Change], rowChanges : [Int: [Diff.Change]]) {
		let fromIds = from.map { $0.id }
		let toIds = to.map { $0.id }
		
		let sectionChanges = Diff.WFDistance(from: fromIds, to: toIds)
		
		var rowChanges : [Int: [Diff.Change]] = [:]
		
		for (toIndex, section) in to.enumerated() {
			if let fromIndex = from.index(where: { $0.id == section.id }) {
				let fromRowIds = from[fromIndex].rows.map { $0.id }
				let toRowIds = section.rows.map { $0.id }
				
				let changes = Diff.WFDistance(from: fromRowIds, to: toRowIds)
				
				for change in changes {
					if case .remove(_) = change {
						let fromIndex = from.index { $0.id == section.id }!
						
						if let changes = rowChanges[fromIndex] {
							rowChanges[fromIndex] = changes + [change]
						} else {
							rowChanges[fromIndex] = [change]
						}
					} else {
						if let changes = rowChanges[toIndex] {
							rowChanges[toIndex] = changes + [change]
						} else {
							rowChanges[toIndex] = [change]
						}
					}
				}
			}
		}
		
		return (sectionChanges, rowChanges)
	}
	
	public func applySectionChange(_ change : Diff.Change) -> Void {
		switch change {
		case .insert(let at): tableView.insertSections(IndexSet(integer: at), with: .automatic)
		case .remove(let at): tableView.deleteSections(IndexSet(integer: at), with: .automatic)
		case .move(let from, let to): tableView.moveSection(from, toSection: to)
		case .update(let at): tableView.reloadSections(IndexSet(integer: at), with: .none)
		}
	}
	
	public func applyRowChange(_ section : Int, change : Diff.Change) -> Void {
		switch change {
		case .insert(let at): tableView.insertRows(at: [Foundation.IndexPath(row: at, section: section)], with: .automatic)
		case .remove(let at): tableView.deleteRows(at: [Foundation.IndexPath(row: at, section: section)], with: .automatic)
		case .move(let from, let to): tableView.moveRow(at: Foundation.IndexPath(row: from, section: section), to: Foundation.IndexPath(row: to, section: section))
		case .update(let at): tableView.reloadRows(at: [Foundation.IndexPath(row: at, section: section)], with: .automatic)
		}
	}
}
