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
	
	private var sut: LWWElementSet<IntRecordSetWrapper>!

    override func setUp() {
		super.setUp()
		sut = LWWElementSet<IntRecordSetWrapper>()
    }

    override func tearDown() {
		super.tearDown()
    }
	
	func testAdd() {
		let addSetWrapper = IntRecordSetWrapper(set: Set<Record<Int>>())
		sut = LWWElementSet(addSetWrapper: addSetWrapper)
		
		// 1. Given
		let target = 1
		
		// 2. When
		sut.add(newValue: target)
		
		// 3. Then
		XCTAssertTrue(addSetWrapper.set.count == 1)
		XCTAssertTrue(addSetWrapper.set.first?.value == target)
	}
	
	func testAdd_MoreItems() {
		let mockTimestampGenerator = MockTimestampGeneratorWithTimestampList()
		let addSetWrapper = IntRecordSetWrapper(set: Set<Record<Int>>())
		sut = LWWElementSet<IntRecordSetWrapper>(addSetWrapper: addSetWrapper, timestampGenerator: mockTimestampGenerator)
		var expectedSet = Set<Record<Int>>()
		
		for i in 1...10 {
			// 1. Given
			// 2. When
			sut.add(newValue: i)
			
			// 3. Then
			XCTAssertTrue(addSetWrapper.set.count == i)
			let record = Record<Int>(value: i, timestamp: mockTimestampGenerator.timestampList[i - 1])
			expectedSet.insert(record)
		}
		
		// 3. Then
		XCTAssertTrue(addSetWrapper.set == expectedSet)
	}
}
