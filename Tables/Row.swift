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

public protocol InputCellType : CellType {
	typealias Value
	
	var placeholder : String? { get }
	var enabled : Bool { get }
	var invalid : Bool { get }
	
	var value : Value { get }
	var valueChanged : Value -> Void { get }
	var done : (Value -> Void)? { get }
}

public protocol SpinnerCellType : CellType {
	var spinning : Bool { get }
}


public protocol DeclarativeCell {
	var cellType : CellType? { get set }
}


public struct PlainCell : CellType {
	public let title : String?
	
	public init(title : String?) {
		self.title = title
	}
}

public struct SubtitleCell : SubtitleCellType {
	public let title : String?
	public let subtitle : String?
	
	public init(title : String?, subtitle : String?) {
		self.title = title
		self.subtitle = subtitle
	}
}

public struct DetailsCell : DetailsCellType {
	public let title : String?
	public let action : Void -> Void
	
	public init(title : String?, action : Void -> Void) {
		self.title = title
		self.action = action
	}
}

public struct DetailsSubtitleCell : SubtitleCellType, DetailsCellType {
	public let title : String?
	public let subtitle : String?
	public let action : Void -> Void
	
	public init(title : String?, subtitle : String?, action : Void -> Void) {
		self.title = title
		self.subtitle = subtitle
		self.action = action
	}
}

public struct ButtonCell : PressableCellType, SpinnerCellType {
	public let title : String?
	public let action : Void -> Void
	public let spinning : Bool
	
	public init(title : String?, loading : Bool = false, action : Void -> Void) {
		self.title = title
		self.spinning = loading
		self.action = action
	}
}

public struct EditableCell : EditableCellType {
	public let title : String?
	public let deleteAction : Void -> Void
	
	public init(title : String?, deleteAction : Void -> Void) {
		self.title = title
		self.deleteAction = deleteAction
	}
}

public struct EditableDetailsCell : EditableCellType, DetailsCellType {
	public let title : String?
	public let action : Void -> Void
	public let deleteAction : Void -> Void
	
	public init(title : String?, action : Void -> Void, deleteAction : Void -> Void) {
		self.title = title
		self.action = action
		self.deleteAction = deleteAction
	}
}

public struct EditableSubtitleCell : EditableCellType, SubtitleCellType {
	public let title : String?
	public let subtitle : String?
	public let deleteAction : Void -> Void
	
	public init(title : String?, subtitle : String?, deleteAction : Void -> Void) {
		self.title = title
		self.subtitle = subtitle
		self.deleteAction = deleteAction
	}
}

public struct EditableDetailsSubtitleCell : EditableCellType, DetailsCellType, SubtitleCellType {
	public let title : String?
	public let subtitle : String?
	public let action : Void -> Void
	public let deleteAction : Void -> Void
	
	public init(title : String?, subtitle : String?, action : Void -> Void, deleteAction : Void -> Void) {
		self.title = title
		self.subtitle = subtitle
		self.action = action
		self.deleteAction = deleteAction
	}
}

public struct MovableDetailsSubtitleCell : MovableCellType, DetailsCellType, SubtitleCellType {
	public let title : String?
	public let subtitle : String?
	public let action : Void -> Void
	public let deleteAction : Void -> Void
	public let moveAction : IndexPath -> Void
	
	public init(title : String?, subtitle : String?, action : Void -> Void, deleteAction : Void -> Void, moveAction : IndexPath -> Void) {
		self.title = title
		self.subtitle = subtitle
		self.action = action
		self.deleteAction = deleteAction
		self.moveAction = moveAction
	}
}

public struct TextInputCell : InputCellType {
	public typealias Value = String
	
	public let title : String?
	public let placeholder : String?
	public let enabled : Bool
	public let invalid : Bool
	public let value : String
	public let valueChanged : String -> Void
	public let done : (String -> Void)?
	
	public init(title : String?, placeholder : String? = nil, enabled : Bool = true, invalid : Bool = false, value : String, valueChanged : String -> Void, done : (String -> Void)? = nil) {
		self.title = title
		self.placeholder = placeholder
		self.enabled = enabled
		self.invalid = invalid
		self.value = value
		self.valueChanged = valueChanged
		self.done = done
	}
}
