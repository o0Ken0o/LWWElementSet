//
//  LWWElementSetTest+Merge.swift
//  CRDTTests
//
//  Created by Kam Hei Siu on 8/4/2020.
//  Copyright © 2020 Kam Hei Siu. All rights reserved.
//

import XCTest
@testable import CRDT

class LWWElementSetMergeTest: XCTestCase {
	
	private var sut: LWWElementSet<Int>!

    override func setUp() {
		super.setUp()
		sut = LWWElementSet<Int>()
    }

    override func tearDown() {
		super.tearDown()
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
