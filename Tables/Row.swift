//
//  Row.swift
//  Tables
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit

public protocol CellType : Identifiable {
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

public protocol ImageCellType : CellType {
    var image : UIImage? { get }
}

public protocol PressableCellType : CellType {
	
	var action : (Void) -> Void { get }
}

public protocol DetailsCellType : PressableCellType {
	
}

public protocol EditableCellType : CellType {
	var deleteAction : (Void) -> Void { get }
}

public protocol MovableCellType : EditableCellType {
	var moveAction : ((SimpleIndexPath) -> Void) { get }
}

public protocol RefreshCellType {
	func shouldRefresh(to : CellType) -> Bool
}

public protocol InputCellType : CellType {
	associatedtype Value
	
	var placeholder : String? { get }
	var enabled : Bool { get }
	var invalid : Bool { get }
	
	var value : Value { get }
	var valueChanged : (Value) -> Void { get }
	var done : ((Value) -> Void)? { get }
}

public protocol SpinnerCellType : CellType {
	var spinning : Bool { get }
}


public protocol DeclarativeCell {
	var cellType : CellType? { get set }
}


public struct PlainCell : CellType {
	public let id : String
	public let title : String?
	
	public init(id : String, title : String?) {
		self.id = id
		self.title = title
	}
}

public struct SubtitleCell : SubtitleCellType {
	public let id : String
	public let title : String?
	public let subtitle : String?
	
	public init(id : String, title : String?, subtitle : String?) {
		self.id = id
		self.title = title
		self.subtitle = subtitle
	}
}

public struct DetailsCell : DetailsCellType {
	public let id : String
	public let title : String?
	public let action : (Void) -> Void
	
	public init(id : String, title : String?, action : (Void) -> Void) {
		self.id = id
		self.title = title
		self.action = action
	}
}

public struct ImageCell : ImageCellType {
    public let id : String
    public let title : String?
    public let image : UIImage?
    
    public init(id : String, title: String?, image : UIImage?) {
        self.id = id
        self.title = title
        self.image = image
    }
}

public struct ImageDetailsCell: ImageCellType, SubtitleCellType, DetailsCellType {
    public let id : String
    public let title : String?
    public let subtitle : String?
    public let action : (Void) -> Void
    public let image : UIImage?
    
    public init(id : String, title : String?, subtitle : String?, image: UIImage?, action : (Void) -> Void) {
        self.id = id
        self.title = title
        self.image = image
        self.subtitle = subtitle
        self.action = action
    }
}

public struct DetailsSubtitleCell : SubtitleCellType, DetailsCellType {
	public let id : String
	public let title : String?
	public let subtitle : String?
	public let action : (Void) -> Void
	
	public init(id : String, title : String?, subtitle : String?, action : (Void) -> Void) {
		self.id = id
		self.title = title
		self.subtitle = subtitle
		self.action = action
	}
}

public struct ButtonCell : PressableCellType, SpinnerCellType {
	public let id : String
	public let title : String?
	public let action : (Void) -> Void
	public let enabled : Bool
	public let spinning : Bool
	
	public init(id : String, title : String?, enabled : Bool = true, loading : Bool = false, action : (Void) -> Void) {
		self.id = id
		self.title = title
		self.enabled = enabled
		self.spinning = loading
		self.action = action
	}
}

public struct EditableCell : EditableCellType {
	public let id : String
	public let title : String?
	public let deleteAction : (Void) -> Void
	
	public init(id : String, title : String?, deleteAction : (Void) -> Void) {
		self.id = id
		self.title = title
		self.deleteAction = deleteAction
	}
}

public struct EditableDetailsCell : EditableCellType, DetailsCellType {
	public let id : String
	public let title : String?
	public let action : (Void) -> Void
	public let deleteAction : (Void) -> Void
	
	public init(id : String, title : String?, action : (Void) -> Void, deleteAction : (Void) -> Void) {
		self.id = id
		self.title = title
		self.action = action
		self.deleteAction = deleteAction
	}
}

public struct EditableSubtitleCell : EditableCellType, SubtitleCellType {
	public let id : String
	public let title : String?
	public let subtitle : String?
	public let deleteAction : (Void) -> Void
	
	public init(id : String, title : String?, subtitle : String?, deleteAction : (Void) -> Void) {
		self.id = id
		self.title = title
		self.subtitle = subtitle
		self.deleteAction = deleteAction
	}
}

public struct EditableDetailsSubtitleCell : EditableCellType, DetailsCellType, SubtitleCellType {
	public let id : String
	public let title : String?
	public let subtitle : String?
	public let action : (Void) -> Void
	public let deleteAction : (Void) -> Void
	
	public init(id : String, title : String?, subtitle : String?, action : (Void) -> Void, deleteAction : (Void) -> Void) {
		self.id = id
		self.title = title
		self.subtitle = subtitle
		self.action = action
		self.deleteAction = deleteAction
	}
}

public struct MovableDetailsSubtitleCell : MovableCellType, DetailsCellType, SubtitleCellType {
	public let id : String
	public let title : String?
	public let subtitle : String?
	public let action : (Void) -> Void
	public let deleteAction : (Void) -> Void
	public let moveAction : (SimpleIndexPath) -> Void
	
	public init(id : String, title : String?, subtitle : String?, action : (Void) -> Void, deleteAction : (Void) -> Void, moveAction : (SimpleIndexPath) -> Void) {
		self.id = id
		self.title = title
		self.subtitle = subtitle
		self.action = action
		self.deleteAction = deleteAction
		self.moveAction = moveAction
	}
}

public struct TextInputCell : InputCellType {
	public let id : String
	public typealias Value = String
	
	public let title : String?
	public let placeholder : String?
	public let enabled : Bool
	public let invalid : Bool
	public let secure : Bool
	public let value : String
	public let valueChanged : (String) -> Void
	public let done : ((String) -> Void)?
	
	public init(id : String, title : String?, placeholder : String? = nil, enabled : Bool = true, invalid : Bool = false, secure : Bool = false, value : String, valueChanged : (String) -> Void, done : ((String) -> Void)? = nil) {
		self.id = id
		self.title = title
		self.placeholder = placeholder
		self.enabled = enabled
		self.invalid = invalid
		self.secure = secure
		self.value = value
		self.valueChanged = valueChanged
		self.done = done
	}
}
