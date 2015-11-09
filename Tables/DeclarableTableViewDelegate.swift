//
//  StyledTableViewDelegate.swift
//  Thermo2
//
//  Created by Ulrik Damm on 27/07/15.
//  Copyright © 2015 Robocat. All rights reserved.
//

import UIKit

public class DeclarableTableViewDelegate : NSObject, UITableViewDelegate {
	public weak var dataSource : DeclarableTableViewDataSource?
	
	public init(dataSource : DeclarableTableViewDataSource? = nil) {
		self.dataSource = dataSource
	}
	
	public func tableView(tableView : UITableView, shouldHighlightRowAtIndexPath indexPath : NSIndexPath) -> Bool {
		let cell = dataSource?.rowAtIndexPath(indexPath)
		
		if let c = cell as? ButtonCell where c.enabled == false {
			return false
		}
		
		return cell is PressableCellType ?? true
	}
	
	public func tableView(tableView : UITableView, didSelectRowAtIndexPath indexPath : NSIndexPath) {
		let cell = dataSource?.rowAtIndexPath(indexPath)
		
		if let c = cell as? ButtonCell where c.enabled == false {
			return
		}
		
		if let row = cell as? PressableCellType {
			row.action()
		}
	}
	
	public func tableView(tableView : UITableView, willDisplayCell cell : UITableViewCell, forRowAtIndexPath indexPath : NSIndexPath) {
		if var dcell = cell as? DeclarativeCell {
			dcell.cellType = dcell.cellType
		}
	}
	
	public func tableView(tableView : UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath : NSIndexPath, toProposedIndexPath proposedDestinationIndexPath : NSIndexPath) -> NSIndexPath {
		if dataSource?.rowAtIndexPath(proposedDestinationIndexPath) is MovableCellType {
			return proposedDestinationIndexPath
		} else {
			return sourceIndexPath
		}
	}
}
