//
//  Diff.swift
//  Thermo2
//
//  Created by Ulrik Damm on 28/07/15.
//  Copyright © 2015 Robocat. All rights reserved.
//

import Foundation

public protocol Identifiable {
	var id : String { get }
}

public class Diff {
	public enum Change {
		case Insert(at : Int)
		case Remove(at : Int)
		case Move(from : Int, to : Int)
		case Update(at : Int)
	}
	
	public class func diff(list1 : [Identifiable], _ list2 : [Identifiable], equals : ((Identifiable, Identifiable) -> Bool)? = nil) -> [Change] {
		var changes : [Change] = []
		
		for (index1, item) in list1.enumerate() {
			if let index2 = list2.indexOf({ $0.id == item.id }) {
				if index1 != index2 {
					changes.append(.Move(from: index1, to: index2))
				} else if let equals = equals where !equals(item, list2[index2]) {
					changes.append(.Update(at: index1))
				}
			} else {
				changes.append(.Remove(at: index1))
			}
		}
		
		for (index2, item) in list2.enumerate() {
			if !list1.contains({ $0.id == item.id }) {
				changes.append(.Insert(at: index2))
			}
		}
		
		return changes
	}
	
	public class func unorderedDiff<T, U>(list1 : [T], var list2 : [U], identifier1 : T -> String, identifier2 : U -> String) -> (add : [T], update : [T], remove : [U]) {
		var add : [T] = []
		var update : [T] = []
		var remove : [U] = []
		
		for item1 in list1 {
			if let index = list2.indexOf({ item in identifier2(item) == identifier1(item1) }) {
				list2.removeAtIndex(index)
				update.append(item1)
			} else {
				add.append(item1)
			}
		}
		
		for item2 in list2 {
			remove.append(item2)
		}
		
		return (add, update, remove)
	}
}
