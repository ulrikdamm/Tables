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
	
	class func WFDistance<T : Equatable>(from from : [T], to : [T]) -> [Change] {
		let matrix = distanceMatrix(from: from, to: to)
		
		var steps = [(x: matrix[0].count - 1, y: matrix.count - 1)]
		
		while let step = findNextStep(matrix, from: steps.last!) {
			steps.append(step)
		}
		
		let ops = steps.reverse().map { position in (position, matrix[position.y][position.x]) }.flatMap { position, cell -> Change? in
			switch cell.operation {
			case .None: return nil
			case .Insert: return .Insert(max(position.y - 1, 0))
			case .Delete: return .Delete(max(position.y - 1, 0))
			case .Substitute: return .Update(max(position.y - 1, 0))
			}
		}
		
		return ops
	}
	
	class func distanceMatrix<T : Equatable>(from from : [T], to : [T]) -> [[Cell]] {
		let initialRow = (0...from.count).map { Cell(operation: ($0 == 0 ? .None : .Delete), value: $0) }
		
		if to.count == 0 {
			return [initialRow]
		}
		
		return (1...to.count).reduce([initialRow]) { rows, rowindex in
			let initialCell = Cell(operation: .Insert, value: rowindex)
			
			if from.count == 0 {
				return rows + [[initialCell]]
			}
			
			let row = (1...from.count).reduce([initialCell]) { all, cellindex in
				let cell : Cell
				
				if from[cellindex - 1] == to[rowindex - 1] {
					cell = Cell(operation: .None, value: rows.last![cellindex - 1].value)
				} else {
					let delete = Cell(operation: .Delete, value: all.last!.value + 1)
					let insert = Cell(operation: .Insert, value: rows.last![cellindex].value + 1)
					let substitute = Cell(operation: .Substitute, value: rows.last![cellindex - 1].value + 1)
					cell = [delete, insert, substitute].minElement()!
				}
				
				return all + [cell]
			}
			
			return rows + [row]
		}
	}
	
	typealias Position = (x : Int, y : Int)
	
	class func findNextStep(matrix : [[Cell]], from : Position) -> Position? {
		if from.x == 0 && from.y == 0 {
			return nil
		}
		
		switch matrix[from.y][from.x].operation {
		case .None, .Substitute: return (x: from.x - 1, y: from.y - 1)
		case .Insert: return (x: from.x, y: from.y - 1)
		case .Delete: return (x: from.x - 1, y: from.y)
		}
	}
}

struct Cell {
	enum Operation : Int { case None = 3, Insert = 1, Delete = 0, Substitute = 2 }
	let operation : Operation
	let value : Int
}

extension Cell : Comparable, Equatable {}

func ==(lhs : Cell, rhs : Cell) -> Bool {
	return lhs.value == rhs.value && lhs.operation == rhs.operation
}

func <(lhs : Cell, rhs : Cell) -> Bool {
	if lhs.value == rhs.value {
		return lhs.operation.rawValue < rhs.operation.rawValue
	} else {
		return lhs.value < rhs.value
	}
}
