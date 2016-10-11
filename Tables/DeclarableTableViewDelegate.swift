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
	
	public func tableView(_ tableView : UITableView, shouldHighlightRowAt indexPath : IndexPath) -> Bool {
		let cell = dataSource?.rowAtIndexPath(indexPath)
		
		if let c = cell as? ButtonCell, c.enabled == false {
			return false
		}
		
		return cell is PressableCellType 
	}
	
	public func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
		let cell = dataSource?.rowAtIndexPath(indexPath)
		
		if let c = cell as? ButtonCell, c.enabled == false {
			return
		}
		
		if let row = cell as? PressableCellType {
			row.action()
		}
	}
	
	public func tableView(_ tableView : UITableView, willDisplay cell : UITableViewCell, forRowAt indexPath : IndexPath) {
		if var dcell = cell as? DeclarativeCell {
			dcell.cellType = dcell.cellType
		}
	}
	
	public func tableView(_ tableView : UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath : IndexPath, toProposedIndexPath proposedDestinationIndexPath : IndexPath) -> IndexPath {
		if dataSource?.rowAtIndexPath(proposedDestinationIndexPath) is MovableCellType {
			return proposedDestinationIndexPath
		} else {
			return sourceIndexPath
		}
	}
}
