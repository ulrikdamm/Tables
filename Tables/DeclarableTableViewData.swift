//
//  StyledTableViewData.swift
//  Thermo2
//
//  Created by Ulrik Damm on 27/07/15.
//  Copyright © 2015 Robocat. All rights reserved.
//

import UIKit

public struct IndexPath {
	public let section: Int
	public let item: Int
}

public extension IndexPath {
	init(indexPath : NSIndexPath) {
		self.section = indexPath.section
		self.item = indexPath.row
	}
}
