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
	
	private var sut: LWWElementSet<IntSetWrapper>!

    override func setUp() {
		super.setUp()
		sut = LWWElementSet<IntSetWrapper>()
    }

    override func tearDown() {
		super.tearDown()
    }
	
	func testMerge_TwoABitDifferentSet() {
		// 1. Given
		let addArray = generateRecordArray(start: 1, end: 10)
		let removeArray = generateRecordArray(start: 1, end: 10)
		
		let addArrayA = generateRecordArray(start: 11, end: 20)
		let removeArrayA = generateRecordArray(start: 11, end: 20)
		
		let addSetA = Set(addArrayA).union(Set(addArray))
		let removeSetA = Set(removeArrayA).union(Set(removeArray))
		let addSetWrapperA = IntSetWrapper(set: addSetA)
		let removeSetWrapperA = IntSetWrapper(set: removeSetA)
		let lwwSetA = LWWElementSet<IntSetWrapper>(addSetWrapper: addSetWrapperA, removeSetWrapper: removeSetWrapperA)
		
		let addArrayB = generateRecordArray(start: 1, end: 10)
		let removeArrayB = generateRecordArray(start: 1, end: 10)
		
		let addSetB = Set(addArrayB).union(Set(addArray))
		let removeSetB = Set(removeArrayB).union(Set(removeArray))
		let addSetWrapperB = IntSetWrapper(set: addSetB)
		let removeSetWrapperB = IntSetWrapper(set: removeSetB)
		let lwwSetB = LWWElementSet<IntSetWrapper>(addSetWrapper: addSetWrapperB, removeSetWrapper: removeSetWrapperB)
		
		// 2: When
		let mergedLWWElementSet = LWWElementSet<IntSetWrapper>.merge(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3: Then
		var mergedAddArray = addArray
		mergedAddArray.append(contentsOf: addArrayA)
		mergedAddArray.append(contentsOf: addArrayB)
		
		var mergedRemoveArray = removeArray
		mergedRemoveArray.append(contentsOf: removeArrayA)
		mergedRemoveArray.append(contentsOf: removeArrayB)
		
		let expectedMergedSet = LWWElementSet(addSetWrapper: IntSetWrapper(set: Set<Record<Int>>(mergedAddArray)), removeSetWrapper: IntSetWrapper(set:  Set<Record<Int>>(mergedRemoveArray)))
		XCTAssertTrue(mergedLWWElementSet == expectedMergedSet)
	}
	
	func testMerge_TwoTotallyDifferentSet() {
		// 1. Given
		let addArrayA = generateRecordArray(start: 1, end: 10)
		let removeArrayA = generateRecordArray(start: 1, end: 10)
		
		let addSetA = Set(addArrayA)
		let removeSetA = Set(removeArrayA)
		let addSetWrapperA = IntSetWrapper(set: addSetA)
		let removeSetWrapperA = IntSetWrapper(set: removeSetA)
		let lwwSetA = LWWElementSet<IntSetWrapper>(addSetWrapper: addSetWrapperA, removeSetWrapper: removeSetWrapperA)
		
		let addArrayB = generateRecordArray(start: 21, end: 30)
		let removeArrayB = generateRecordArray(start: 21, end: 30)
		
		let addSetB = Set(addArrayB)
		let removeSetB = Set(removeArrayB)
		let addSetWrapperB = IntSetWrapper(set: addSetB)
		let removeSetWrapperB = IntSetWrapper(set: removeSetB)
		let lwwSetB = LWWElementSet<IntSetWrapper>(addSetWrapper: addSetWrapperB, removeSetWrapper: removeSetWrapperB)
		
		// 2: When
		let mergedLWWElementSet = LWWElementSet<IntSetWrapper>.merge(lwwSetA: lwwSetA, lwwSetB: lwwSetB)
		
		// 3: Then
		var mergedAddArray = addArrayA
		mergedAddArray.append(contentsOf: addArrayB)
		
		var mergedRemoveArray = removeArrayA
		mergedRemoveArray.append(contentsOf: removeArrayB)
		
		let expectedMergedSet = LWWElementSet(addSetWrapper: IntSetWrapper(set: Set<Record<Int>>(mergedAddArray)), removeSetWrapper: IntSetWrapper(set:  Set<Record<Int>>(mergedRemoveArray)))
		XCTAssertTrue(mergedLWWElementSet == expectedMergedSet)
	}
	
	private func generateRecordArray(start: Int, end: Int) -> [Record<Int>] {
		guard start <= end else { return [] }
		var array = [Record<Int>]()
		for i in start...end {
			array.append(Record<Int>(value: i, timestamp: Date().timeIntervalSince1970))
		}
		return array
	}
}
