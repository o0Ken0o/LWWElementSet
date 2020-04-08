//
//  MockTimestampGeneratorAlwaysEqual.swift
//  CRDTTests
//
//  Created by Kam Hei Siu on 8/4/2020.
//  Copyright © 2020 Kam Hei Siu. All rights reserved.
//

import Foundation

struct MockTimestampGeneratorAlwaysEqual: TimestampGeneratorProtocol {
	private let date = Date()
	
	func now() -> TimeInterval {
		return date.timeIntervalSince1970
	}
}

class MockTimestampGeneratorWithTimestampList: TimestampGeneratorProtocol {
	private let date = Date()
	private(set) var timestampList: [TimeInterval] = []
	
	func now() -> TimeInterval {
		let newTimestamp = date.timeIntervalSince1970
		timestampList.append(newTimestamp)
		return newTimestamp
	}
}
