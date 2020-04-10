//
//  LWWElementSetTest+Remove.swift
//  CRDTTests
//
//  Created by Kam Hei Siu on 8/4/2020.
//  Copyright © 2020 Kam Hei Siu. All rights reserved.
//

import XCTest
@testable import CRDT

class LWWElementSetRemoveTest: XCTestCase {
	
	private var sut: LWWElementSet<IntSetWrapper>!

    override func setUp() {
		super.setUp()
		sut = LWWElementSet<IntSetWrapper>()
    }

    override func tearDown() {
		super.tearDown()
    }
	
	func testRemove_WithoutAddedTarget() {
		let removeSetWrapper = IntSetWrapper()
		sut = LWWElementSet(removeSetWrapper: removeSetWrapper)
		
		// 1. Given
		let target = 1
		
		// 2. When
		sut.remove(oldValue: target)
		
		// 3. Then
		XCTAssertNil(removeSetWrapper.set.first)
	}
	
	func testRemove_WithAddedTarget() {
		let removeSetWrapper = IntSetWrapper()
		sut = LWWElementSet(removeSetWrapper: removeSetWrapper)
		
		// 1. Given
		let target = 1
		
		// 2. When
		sut.add(newValue: target)
		sut.remove(oldValue: target)
		
		// 3. Then
		XCTAssertTrue(removeSetWrapper.set.first?.value == target)
	}
}
