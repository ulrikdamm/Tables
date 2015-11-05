//
//  Row.swift
//  Tables
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit

public protocol RowType : Identifiable {
	var type : CellType { get }
}

public struct Row : RowType {
	public let id : String
	public let type : CellType
	
	public init(_ id : String, _ type : CellType) {
		self.id = id
		self.type = type
	}
}

public func ==(lhs : RowType, rhs : RowType) -> Bool {
	return lhs.id == rhs.id
}

public protocol CellType {
	static var typeId : String { get }
	var title : String? { get }
}

public extension CellType {
	static var typeId : String {
		return "\(Mirror(reflecting: self).subjectType)"
	}
}

public protocol SubtitleCellType : CellType {
	var subtitle : String? { get }
}

public protocol PressableCellType : CellType {
	var action : Void -> Void { get }
}

public protocol DetailsCellType : PressableCellType {
	
}

public protocol EditableCellType : CellType {
	var deleteAction : Void -> Void { get }
}

public protocol MovableCellType : EditableCellType {
	var moveAction : (IndexPath -> Void) { get }
}

public protocol RefreshCellType {
	func shouldRefresh(to to : CellType) -> Bool
}

public protocol DeclarativeCell {
	var cellType : CellType? { get set }
}
