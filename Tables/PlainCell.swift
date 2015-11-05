//
//  PlainCell.swift
//  Tables
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit

public class TablesPlainCell : UITableViewCell, DeclarativeCell {
	public var cellType : CellType? {
		didSet {
			if let cellType = cellType {
				textLabel?.text = cellType.title
			}
			
			if cellType is DetailsCellType {
				accessoryType = .DisclosureIndicator
			}
			
			if let cellType = cellType as? SubtitleCellType {
				detailTextLabel?.text = cellType.subtitle
			}
		}
	}
}
