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
	
	public class func unorderedDiff<T, U>(list1 : [T], list2 : [U], identifier1 : T -> String, identifier2 : U -> String) -> (add : [T], update : [T], remove : [U]) {
		var add : [T] = []
		var update : [T] = []
		
		var remove = list2
		
		for item1 in list1 {
			if let index = remove.indexOf({ item in identifier2(item) == identifier1(item1) }) {
				remove.removeAtIndex(index)
				update.append(item1)
			} else {
				add.append(item1)
			}
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
			case .Insert: return .Insert(at: position.y - 1)
			case .Delete: return .Remove(at: position.x - 1)
			case .Substitute: return .Update(at: position.x - 1)
			}
		}
		
		let opsWithMoves = ops.reduce([Change]()) { (all, this) in
			if case .Insert(let position) = this {
				if let index = all.indexOf({ if case .Remove(let index) = $0 where from[index] == to[position] { return true } else { return false } }) {
					var new = all
					new[index] = .Move(from: index, to: position)
					return new
				}
			} else if case .Remove(let position) = this {
				if let index = all.indexOf({ if case .Insert(let index) = $0 where to[index] == from[position] { return true } else { return false } }) {
					var new = all
					new[index] = .Move(from: position, to: index)
					return new
				}
			}
			
			return all + [this]
		}
		
		return opsWithMoves
	}
	
	class func distanceMatrix<T : Equatable>(from from : [T], to : [T]) -> [[Cell]] {
		var matrix = [[Cell?]](count: to.count + 1, repeatedValue: [Cell?](count: from.count + 1, repeatedValue: nil))
		
		for y in (0...to.count) {
			for x in (0...from.count) {
				let cell : Cell
				
				switch (x, y) {
				case (0, 0): cell = Cell(operation: .None, value: 0)
				case (_, 0): cell = Cell(operation: .Delete, value: x)
				case (0, _): cell = Cell(operation: .Insert, value: y)
				case (_, _):
					if from[x - 1] == to[y - 1] {
						cell = Cell(operation: .None, value: matrix[y - 1][x - 1]!.value)
					} else {
						let delete = Cell(operation: .Delete, value: matrix[y][x - 1]!.value + 1)
						let insert = Cell(operation: .Insert, value: matrix[y - 1][x]!.value + 1)
						let substitute = Cell(operation: .Substitute, value: matrix[y - 1][x - 1]!.value + 2)
						cell = [delete, insert, substitute].minElement()!
					}
				}
				
				matrix[y][x] = cell
			}
		}
		
		return matrix.map { $0.flatMap { $0 } }
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
