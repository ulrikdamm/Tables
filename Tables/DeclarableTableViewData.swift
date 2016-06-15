//
//  StyledTableViewData.swift
//  Thermo2
//
//  Created by Ulrik Damm on 27/07/15.
//  Copyright © 2015 Robocat. All rights reserved.
//

import UIKit

public struct SimpleIndexPath {
	public let section : Int
	public let item : Int
	
	init(indexPath : IndexPath) {
		section = indexPath.section
		item = indexPath.row
	}
}
