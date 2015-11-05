//
//  TablesTableView.swift
//  Tables
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit

public class TablesTableView : UITableView {
	public required init?(coder aDecoder : NSCoder) { fatalError() }
	
	public init(style : UITableViewStyle, dataSource : DeclarableTableViewDataSource? = nil, delegate : DeclarableTableViewDelegate? = nil) {
		tablesDataSource = dataSource ?? DeclarableTableViewDataSource()
		tablesDelegate = delegate ?? DeclarableTableViewDelegate()
		super.init(frame: CGRectZero, style: style)
		setup()
	}
	
	public let tablesDataSource : DeclarableTableViewDataSource
	public let tablesDelegate : DeclarableTableViewDelegate
	
	func setup() {
		tablesDelegate.dataSource = tablesDataSource
		tablesDataSource.attachToTableView(self)
		delegate = tablesDelegate
		
		rowHeight = UITableViewAutomaticDimension
		estimatedRowHeight = 44
	}
}
