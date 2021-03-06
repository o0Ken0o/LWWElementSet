//
//  LWWElementSetTest+Compare.swift
//  CRDTTests
//
//  Created by Kam Hei Siu on 8/4/2020.
//  Copyright © 2020 Kam Hei Siu. All rights reserved.
//

import XCTest
@testable import CRDT

class LWWElementSetCompareTest: XCTestCase {
	
	private var sut: LWWElementSet<IntRecordSetWrapper>!

    override func setUp() {
		super.setUp()
		sut = LWWElementSet<IntRecordSetWrapper>()
    }

    override func tearDown() {
		super.tearDown()
    }
	
	func testCompare_BothEmpty() {
		// 1. Given
		let lwwSetA = LWWElementSet<IntRecordSetWrapper>()
		let lwwSetB = LWWElementSet<IntRecordSetWrapper>()
		
		// 2. When
		let compareResult = LWWElementSet<IntRecordSetWrapper>.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = true
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_ANotEmpty_BEmpty() {
		// 1. Given
		let lwwSetA = LWWElementSet<IntRecordSetWrapper>()
		let lwwSetB = LWWElementSet<IntRecordSetWrapper>()
		lwwSetA.add(newValue: 1)
		
		// 2. When
		let compareResult = LWWElementSet<IntRecordSetWrapper>.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = false
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_AEmpty_BNotEmpty() {
		// 1. Given
		let lwwSetA = LWWElementSet<IntRecordSetWrapper>()
		let lwwSetB = LWWElementSet<IntRecordSetWrapper>()
		lwwSetB.add(newValue: 1)
		
		// 2. When
		let compareResult = LWWElementSet<IntRecordSetWrapper>.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = true
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_BothNotEmpty_BothAreTheSame_SameTimestamp() {
		// 1. Given
		let mockGenerator = MockTimestampGeneratorAlwaysEqual()
		let lwwSetA = LWWElementSet<IntRecordSetWrapper>(timestampGenerator: mockGenerator)
		let lwwSetB = LWWElementSet<IntRecordSetWrapper>(timestampGenerator: mockGenerator)
		lwwSetA.add(newValue: 1)
		lwwSetA.add(newValue: 2)
		lwwSetA.add(newValue: 3)
		lwwSetB.add(newValue: 1)
		lwwSetB.add(newValue: 2)
		lwwSetB.add(newValue: 3)
		
		// 2. When
		let compareResult = LWWElementSet<IntRecordSetWrapper>.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = true
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_BothNotEmpty_BothAreTheSame_DifferentTimestamp() {
		// 1. Given
		let lwwSetA = LWWElementSet<IntRecordSetWrapper>()
		let lwwSetB = LWWElementSet<IntRecordSetWrapper>()
		lwwSetA.add(newValue: 1)
		lwwSetA.add(newValue: 2)
		lwwSetA.add(newValue: 3)
		lwwSetB.add(newValue: 1)
		lwwSetB.add(newValue: 2)
		lwwSetB.add(newValue: 3)
		
		// 2. When
		let compareResult = LWWElementSet<IntRecordSetWrapper>.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = false
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_BothNotEmpty_BothAreDifferent_SameTimestamp() {
		// 1. Given
		let mockGenerator = MockTimestampGeneratorAlwaysEqual()
		let lwwSetA = LWWElementSet<IntRecordSetWrapper>(timestampGenerator: mockGenerator)
		let lwwSetB = LWWElementSet<IntRecordSetWrapper>(timestampGenerator: mockGenerator)
		lwwSetA.add(newValue: 1)
		lwwSetA.add(newValue: 2)
		lwwSetA.add(newValue: 3)
		lwwSetB.add(newValue: 2)
		lwwSetB.add(newValue: 3)
		lwwSetB.add(newValue: 4)
		
		// 2. When
		let compareResult = LWWElementSet<IntRecordSetWrapper>.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = false
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_BothNotEmpty_BothAreDifferent_DifferentTimestamp() {
		// 1. Given
		let lwwSetA = LWWElementSet<IntRecordSetWrapper>()
		let lwwSetB = LWWElementSet<IntRecordSetWrapper>()
		lwwSetA.add(newValue: 1)
		lwwSetA.add(newValue: 2)
		lwwSetA.add(newValue: 3)
		lwwSetB.add(newValue: 2)
		lwwSetB.add(newValue: 3)
		lwwSetB.add(newValue: 4)
		
		// 2. When
		let compareResult = LWWElementSet<IntRecordSetWrapper>.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = false
		XCTAssertEqual(compareResult, expectedResult)
	}
}
