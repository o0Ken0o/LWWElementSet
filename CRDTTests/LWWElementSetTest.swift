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
	
	// MARK: - test lookup
	func testLookup_WithoutTheElement_WithoutRemove() {
		// 1. Given
		let target = 1
		
		// 2. When
		let isFound = sut.lookup(target: target)
		
		// 3. Then
		XCTAssertFalse(isFound)
	}

	func testLookup_WithTheElement_WithoutRemove() {
		// 1. Given
		let target = 1
		sut.add(newValue: target)
		
		// 2. When
		let isFound = sut.lookup(target: target)
		
		// 3. Then
		XCTAssertTrue(isFound)
	}
	
	func testLookup_WithTheElement_WithRemoveLessLatest() {
		// 1. Given
		let target = 1
		sut.remove(oldValue: target)
		sut.add(newValue: target)
		
		// 2. When
		let isFound = sut.lookup(target: target)
		
		// 3. Then
		XCTAssertTrue(isFound)
	}
	
	func testLookup_WithTheElement_WithRemoveMoreLatest() {
		// 1. Given
		let target = 1
		sut.add(newValue: target)
		sut.remove(oldValue: target)
		
		// 2. When
		let isFound = sut.lookup(target: target)
		
		// 3. Then
		XCTAssertFalse(isFound)
	}
	
	func testLookup_WithTheElement_WithRemove_Equal() {
		sut = LWWElementSet(timestampGenerator: MockTimestampGeneratorAlwaysEqual())
		
		// 1. Given
		let target = 1
		sut.add(newValue: target)
		sut.remove(oldValue: target)
		
		// 2. When
		let isFound = sut.lookup(target: target)
		
		// 3. Then
		XCTAssertTrue(isFound)
	}
	
	// MARK: - test add
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
	
	// MARK: - test remove
	func testRemove_WithoutAddedTarget() {
		let removeSetWrapper = SetWrapper(set: Set<Record<Int>>())
		sut = LWWElementSet(removeSetWrapper: removeSetWrapper)
		
		// 1. Given
		let target = 1
		
		// 2. When
		sut.remove(oldValue: target)
		
		// 3. Then
		XCTAssertNil(removeSetWrapper.set.first)
	}
	
	func testRemove_WithAddedTarget() {
		let removeSetWrapper = SetWrapper(set: Set<Record<Int>>())
		sut = LWWElementSet(removeSetWrapper: removeSetWrapper)
		
		// 1. Given
		let target = 1
		
		// 2. When
		sut.add(newValue: target)
		sut.remove(oldValue: target)
		
		// 3. Then
		XCTAssertTrue(removeSetWrapper.set.first?.value == target)
	}
	
	// MARK: - test compare
	func testCompare_BothEmpty() {
		// 1. Given
		let lwwSetA = LWWElementSet<Int>()
		let lwwSetB = LWWElementSet<Int>()
		
		// 2. When
		let compareResult = sut.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = true
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_ANotEmpty_BEmpty() {
		// 1. Given
		let lwwSetA = LWWElementSet<Int>()
		let lwwSetB = LWWElementSet<Int>()
		lwwSetA.add(newValue: 1)
		
		// 2. When
		let compareResult = sut.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = false
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_AEmpty_BNotEmpty() {
		// 1. Given
		let lwwSetA = LWWElementSet<Int>()
		let lwwSetB = LWWElementSet<Int>()
		lwwSetB.add(newValue: 1)
		
		// 2. When
		let compareResult = sut.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = true
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_BothNotEmpty_BothAreTheSame_SameTimestamp() {
		// 1. Given
		let mockGenerator = MockTimestampGeneratorAlwaysEqual()
		let lwwSetA = LWWElementSet<Int>(timestampGenerator: mockGenerator)
		let lwwSetB = LWWElementSet<Int>(timestampGenerator: mockGenerator)
		lwwSetA.add(newValue: 1)
		lwwSetA.add(newValue: 2)
		lwwSetA.add(newValue: 3)
		lwwSetB.add(newValue: 1)
		lwwSetB.add(newValue: 2)
		lwwSetB.add(newValue: 3)
		
		// 2. When
		let compareResult = sut.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = true
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_BothNotEmpty_BothAreTheSame_DifferentTimestamp() {
		// 1. Given
		let lwwSetA = LWWElementSet<Int>()
		let lwwSetB = LWWElementSet<Int>()
		lwwSetA.add(newValue: 1)
		lwwSetA.add(newValue: 2)
		lwwSetA.add(newValue: 3)
		lwwSetB.add(newValue: 1)
		lwwSetB.add(newValue: 2)
		lwwSetB.add(newValue: 3)
		
		// 2. When
		let compareResult = sut.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = false
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_BothNotEmpty_BothAreDifferent_SameTimestamp() {
		// 1. Given
		let mockGenerator = MockTimestampGeneratorAlwaysEqual()
		let lwwSetA = LWWElementSet<Int>(timestampGenerator: mockGenerator)
		let lwwSetB = LWWElementSet<Int>(timestampGenerator: mockGenerator)
		lwwSetA.add(newValue: 1)
		lwwSetA.add(newValue: 2)
		lwwSetA.add(newValue: 3)
		lwwSetB.add(newValue: 2)
		lwwSetB.add(newValue: 3)
		lwwSetB.add(newValue: 4)
		
		// 2. When
		let compareResult = sut.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = false
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	func testCompare_BothNotEmpty_BothAreDifferent_DifferentTimestamp() {
		// 1. Given
		let lwwSetA = LWWElementSet<Int>()
		let lwwSetB = LWWElementSet<Int>()
		lwwSetA.add(newValue: 1)
		lwwSetA.add(newValue: 2)
		lwwSetA.add(newValue: 3)
		lwwSetB.add(newValue: 2)
		lwwSetB.add(newValue: 3)
		lwwSetB.add(newValue: 4)
		
		// 2. When
		let compareResult = sut.compare(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3. Then
		let expectedResult = false
		XCTAssertEqual(compareResult, expectedResult)
	}
	
	// MARK: - test merge
	func testMerge_TwoABitDifferentSet() {
		// 1. Given
		var addArray = [Record<Int>]()
		for i in 1...10 {
			addArray.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		var removeArray = [Record<Int>]()
		for i in 1...10 {
			removeArray.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		var addArrayA = [Record<Int>]()
		for i in 11...20 {
			addArrayA.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		var removeArrayA = [Record<Int>]()
		for i in 11...20 {
			removeArrayA.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		
		let addSetA = Set(addArrayA).union(Set(addArray))
		let removeSetA = Set(removeArrayA).union(Set(removeArray))
		let addSetWrapperA = SetWrapper(set: addSetA)
		let removeSetWrapperA = SetWrapper(set: removeSetA)
		let lwwSetA = LWWElementSet<Int>(addSetWrapper: addSetWrapperA, removeSetWrapper: removeSetWrapperA)
		
		var addArrayB = [Record<Int>]()
		for i in 1...10 {
			addArrayB.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		var removeArrayB = [Record<Int>]()
		for i in 1...10 {
			removeArrayB.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		
		let addSetB = Set(addArrayB).union(Set(addArray))
		let removeSetB = Set(removeArrayB).union(Set(removeArray))
		let addSetWrapperB = SetWrapper(set: addSetB)
		let removeSetWrapperB = SetWrapper(set: removeSetB)
		let lwwSetB = LWWElementSet<Int>(addSetWrapper: addSetWrapperB, removeSetWrapper: removeSetWrapperB)
		
		// 2: When
		let mergedLWWElementSet = sut.merge(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3: Then
		var mergedAddArray = addArray
		mergedAddArray.append(contentsOf: addArrayA)
		mergedAddArray.append(contentsOf: addArrayB)
		var mergedRemoveArray = removeArray
		mergedRemoveArray.append(contentsOf: removeArrayA)
		mergedRemoveArray.append(contentsOf: removeArrayB)
		let expectedMergedSet = LWWElementSet(addSetWrapper: SetWrapper(set: Set<Record<Int>>(mergedAddArray)), removeSetWrapper: SetWrapper(set:  Set<Record<Int>>(mergedRemoveArray)))
		let isMergedToExpectedEqual = sut.compare(lwwSetA: mergedLWWElementSet, lwwSetB: expectedMergedSet)
		let isExpectedToMergedEqual = sut.compare(lwwSetA: expectedMergedSet, lwwSetB: mergedLWWElementSet)
		XCTAssertTrue(isMergedToExpectedEqual)
		XCTAssertTrue(isExpectedToMergedEqual)
	}
	
	func testMerge_TwoTotallyDifferentSet() {
		// 1. Given
		var addArrayA = [Record<Int>]()
		for i in 1...10 {
			addArrayA.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		var removeArrayA = [Record<Int>]()
		for i in 1...10 {
			removeArrayA.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		
		let addSetA = Set(addArrayA)
		let removeSetA = Set(removeArrayA)
		let addSetWrapperA = SetWrapper(set: addSetA)
		let removeSetWrapperA = SetWrapper(set: removeSetA)
		let lwwSetA = LWWElementSet<Int>(addSetWrapper: addSetWrapperA, removeSetWrapper: removeSetWrapperA)
		
		var addArrayB = [Record<Int>]()
		for i in 21...30 {
			addArrayB.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		var removeArrayB = [Record<Int>]()
		for i in 21...30 {
			removeArrayB.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		
		let addSetB = Set(addArrayB)
		let removeSetB = Set(removeArrayB)
		let addSetWrapperB = SetWrapper(set: addSetB)
		let removeSetWrapperB = SetWrapper(set: removeSetB)
		let lwwSetB = LWWElementSet<Int>(addSetWrapper: addSetWrapperB, removeSetWrapper: removeSetWrapperB)
		
		// 2: When
		let mergedLWWElementSet = sut.merge(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3: Then
		var mergedAddArray = addArrayA
		mergedAddArray.append(contentsOf: addArrayB)
		var mergedRemoveArray = removeArrayA
		mergedRemoveArray.append(contentsOf: removeArrayB)
		let expectedMergedSet = LWWElementSet(addSetWrapper: SetWrapper(set: Set<Record<Int>>(mergedAddArray)), removeSetWrapper: SetWrapper(set:  Set<Record<Int>>(mergedRemoveArray)))
		let isMergedToExpectedEqual = sut.compare(lwwSetA: mergedLWWElementSet, lwwSetB: expectedMergedSet)
		let isExpectedToMergedEqual = sut.compare(lwwSetA: expectedMergedSet, lwwSetB: mergedLWWElementSet)
		XCTAssertTrue(isMergedToExpectedEqual)
		XCTAssertTrue(isExpectedToMergedEqual)
	}
}

struct MockTimestampGeneratorAlwaysEqual: TimestampGeneratorProtocol {
	private let date = Date()
	
	func now() -> TimeInterval {
		return date.timeIntervalSince1970
	}
}
