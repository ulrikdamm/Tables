//
//  TextInputCellType.swift
//  Tables
//
//  Created by Ulrik Damm on 08/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit

public class InputCell : UITableViewCell, DeclarativeCell, UITextFieldDelegate {
	var title : String? { didSet { view.label.text = title } }
	var value : String? { get { return view.input.text } set { view.input.text = newValue } }
	var placeholder : String? { didSet { view.input.placeholder = placeholder } }
	
	let view = InputCellView()
	
	var awatingText : String?
	
	override init(style : UITableViewCellStyle, reuseIdentifier : String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required public init?(coder : NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	func setup() {
		contentView.addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: contentView.readableContentGuide, attribute: .Leading, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: contentView.readableContentGuide, attribute: .Trailing, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: contentView.readableContentGuide, attribute: .Top, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: contentView.readableContentGuide, attribute: .Bottom, multiplier: 1, constant: 0))
		
		textLabel?.hidden = true
		view.input.delegate = self
	}
	
	public func focus() {
		view.input.becomeFirstResponder()
	}
	
	public var cellType : CellType? {
		didSet {
			if let cellType = cellType as? TextInputCell {
				title = cellType.title
				if cellType.value != awatingText { value = cellType.value }
				placeholder = cellType.placeholder
				view.input.enabled = cellType.enabled
				view.label.textColor = (cellType.invalid ? .redColor() : nil)
//				view.input.returnKeyType = cellType.returnButton ?? .Default
			}
		}
	}
	
	public func textField(textField : UITextField, shouldChangeCharactersInRange range : NSRange, replacementString string : String) -> Bool {
		let text = textField.text ?? ""
		let r = Range(start: text.startIndex.advancedBy(range.location), end: text.startIndex.advancedBy(range.location + range.length))
		let newText = text.stringByReplacingCharactersInRange(r, withString: string)
		awatingText = newText
		
		(cellType as? TextInputCell)?.valueChanged(newText)
		
		return textField.text != awatingText
	}
	
	public func textFieldShouldReturn(textField : UITextField) -> Bool {
		(cellType as? TextInputCell)?.done?(textField.text ?? "")
		return true
	}
	
	public func textFieldDidEndEditing(textField : UITextField) {
		textField.layoutIfNeeded()
	}
}

class InputCellView : UIStackView {
	init() {
		super.init(frame: CGRectZero)
		setup()
	}
	
	required init?(coder aDecoder : NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	let label = UILabel()
	let input = UITextField(frame: CGRectZero)
	
	func setup() {
		distribution = .Fill
		alignment = .Fill
		spacing = 10
		
		label.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 80))
		
		addArrangedSubview(label)
		addArrangedSubview(input)
	}
}

