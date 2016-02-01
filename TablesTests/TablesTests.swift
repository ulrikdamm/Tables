//
//  TablesTests.swift
//  TablesTests
//
//  Created by Ulrik Damm on 05/11/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import XCTest
@testable import Tables

class TablesTests : XCTestCase {
    func testPerformanceExample() {
        measureBlock {
			let from = Array(0..<100)
			let to = Array(100..<200)
			
			Diff.WFDistance(from: from, to: to)
        }
    }
}
