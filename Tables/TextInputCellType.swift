//
//  TextInputCellType.swift
//  Tables
//
//  Created by Ulrik Damm on 08/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import UIKit

public class InputCell : UITableViewCell, DeclarativeCell, UITextFieldDelegate {
	public var title : String? { didSet { view.label.text = title } }
	public var value : String? { get { return view.input.text } set { view.input.text = newValue } }
	public var placeholder : String? { didSet { view.input.placeholder = placeholder } }
	
	public let view = InputCellView()
	
	public var awatingText : String?
	
	public override init(style : UITableViewCellStyle, reuseIdentifier : String?) {
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
		
		contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: contentView.readableContentGuide, attribute: .leading, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: contentView.readableContentGuide, attribute: .trailing, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: contentView.readableContentGuide, attribute: .top, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: contentView.readableContentGuide, attribute: .bottom, multiplier: 1, constant: 0))
		
		textLabel?.isHidden = true
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
				view.input.isEnabled = cellType.enabled
				view.label.textColor = (cellType.invalid ? .red : nil)
				view.input.isSecureTextEntry = cellType.secure
//				view.input.returnKeyType = cellType.returnButton ?? .Default
			}
		}
	}
	
	public func textField(_ textField : UITextField, shouldChangeCharactersIn range : NSRange, replacementString string : String) -> Bool {
		let text = textField.text ?? ""
		let r = text.characters.index(text.startIndex, offsetBy: range.location) ..< text.characters.index(text.startIndex, offsetBy: range.location + range.length)
		let newText = text.replacingCharacters(in: r, with: string)
		awatingText = newText
		
		(cellType as? TextInputCell)?.valueChanged(newText)
		
		return textField.text != awatingText
	}
	
	public func textFieldShouldReturn(_ textField : UITextField) -> Bool {
		(cellType as? TextInputCell)?.done?(textField.text ?? "")
		return true
	}
	
	public func textFieldDidEndEditing(_ textField : UITextField) {
		textField.layoutIfNeeded()
	}
}

public class InputCellView : UIStackView {
	public init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	public required init(coder aDecoder : NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	public let label = UILabel()
	public let input = UITextField(frame: CGRect.zero)
	
	func setup() {
		distribution = .fill
		alignment = .fill
		spacing = 10
		
		label.addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))
		
		addArrangedSubview(label)
		addArrangedSubview(input)
	}
}

