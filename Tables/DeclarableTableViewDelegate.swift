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
		return dataSource?.rowAtIndexPath(indexPath).type is PressableCellType ?? true
	}
	
	public func tableView(tableView : UITableView, didSelectRowAtIndexPath indexPath : NSIndexPath) {
		if let row = dataSource?.rowAtIndexPath(indexPath).type as? PressableCellType {
			row.action()
		}
	}
	
	public func tableView(tableView : UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath : NSIndexPath, toProposedIndexPath proposedDestinationIndexPath : NSIndexPath) -> NSIndexPath {
		if dataSource?.rowAtIndexPath(proposedDestinationIndexPath).type is MovableCellType {
			return proposedDestinationIndexPath
		} else {
			return sourceIndexPath
		}
	}
}
