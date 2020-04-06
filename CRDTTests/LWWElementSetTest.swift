//
//  LWWElementSetTest.swift
//  CRDTTests
//
//  Created by Kam Hei Siu on 6/4/2020.
//  Copyright © 2020 Kam Hei Siu. All rights reserved.
//

import XCTest
@testable import CRDT

class LWWElementSetTest: XCTestCase {
	
	private var sut: LWWElementSet<Int>!

    override func setUp() {
		super.setUp()
		
		sut = LWWElementSet<Int>()
    }

    override func tearDown() {
		super.tearDown()
    }

	func testLookupWithTheElement() {
		// 1. Given
		let target = 1
		sut.add(newValue: target)
		
		// 2. When
		let isFound = sut.lookup(target: target)
		
		// 3. Then
		XCTAssertTrue(isFound)
	}
	
	func testLookupWithoutTheElement() {
		// 1. Given
		let target = 1
		
		// 2. When
		let isFound = sut.lookup(target: target)
		
		// 3. Then
		XCTAssertFalse(isFound)
	}

}
