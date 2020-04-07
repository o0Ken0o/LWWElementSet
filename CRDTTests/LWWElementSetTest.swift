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
}

struct MockTimestampGeneratorAlwaysEqual: TimestampGeneratorProtocol {
	private let date = Date()
	
	func now() -> TimeInterval {
		return date.timeIntervalSince1970
	}
}
