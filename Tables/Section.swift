//
//  Section.swift
//  Tables
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import Foundation

public protocol SectionType : Identifiable {
	var header : String? { get }
	var footer : String? { get }
	var rows : [CellType] { get }
}

public func ==(lhs : SectionType, rhs : SectionType) -> Bool {
	return lhs.id == rhs.id
}

public struct Section : SectionType {
	public var id : String
	public var header : String?
	public var footer : String?
	public var rows : [CellType]
	
	public init(_ sectionId : String, header : String? = nil, footer : String? = nil, rows : [CellType]) {
		self.id = sectionId
		self.header = header
		self.footer = footer
		self.rows = rows
	}
}
