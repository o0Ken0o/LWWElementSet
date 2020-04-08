//
//  LWWElementSetTest+Add.swift
//  CRDTTests
//
//  Created by Kam Hei Siu on 8/4/2020.
//  Copyright © 2020 Kam Hei Siu. All rights reserved.
//

import XCTest
@testable import CRDT

class LWWElementSetAddTest: XCTestCase {
	
	private var sut: LWWElementSet<Int>!

    override func setUp() {
		super.setUp()
		sut = LWWElementSet<Int>()
    }

    override func tearDown() {
		super.tearDown()
    }
	
	func testAdd() {
		let addSetWrapper = SetWrapper(set: Set<Record<Int>>())
		sut = LWWElementSet(addSetWrapper: addSetWrapper)
		
		// 1. Given
		let target = 1
		
		// 2. When
		sut.add(newValue: target)
		
		// 3. Then
		XCTAssertTrue(addSetWrapper.set.first?.value == target)
	}
}
