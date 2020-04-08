//
//  LWWElementSet.swift
//  CRDT
//
//  Created by Kam Hei Siu on 6/4/2020.
//  Copyright © 2020 Kam Hei Siu. All rights reserved.
//

import Foundation

// TODO: add access modifier
// TODO: add protocols
// TODO: compare -> static
// TODO: merge -> static
// TODO: break long lines into serveral lines
// TODO: Check if the size of the set is equal to the array size in unit test

struct Record<T: Hashable>: Hashable {
	let value: T
	let timestamp: TimeInterval
}

protocol TimestampGeneratorProtocol {
	func now() -> TimeInterval
}

struct TimestampGenerator: TimestampGeneratorProtocol {
	func now() -> TimeInterval {
		return Date().timeIntervalSince1970
	}
}

class SetWrapper<T: Hashable> {
	
	var set: Set<T>
	
	init(set: Set<T>) {
		self.set = set
	}
}

class LWWElementSet<T: Hashable> {
	
	enum Ops: CaseIterable {
		case add, remove
	}
	
	private var addSetWrapper: SetWrapper<Record<T>>
	private var removeSetWrapper: SetWrapper<Record<T>>
	private let timestampGenerator: TimestampGeneratorProtocol
	
	init(addSetWrapper: SetWrapper<Record<T>> = SetWrapper(set: Set<Record<T>>()), removeSetWrapper: SetWrapper<Record<T>> = SetWrapper(set: Set<Record<T>>()), timestampGenerator: TimestampGeneratorProtocol = TimestampGenerator()) {
		self.addSetWrapper = addSetWrapper
		self.removeSetWrapper = removeSetWrapper
		self.timestampGenerator = timestampGenerator
	}
	
	func lookup(target: T) -> Bool {
		guard let addLatestTimestamp = getTimestamp(target: target, ops: .add) else { return false }
		guard let removeLatestTimestamp = getTimestamp(target: target, ops: .remove) else { return true }
		return addLatestTimestamp >= removeLatestTimestamp
	}
	
	func add(newValue: T) {
		let time = timestampGenerator.now()
		addSetWrapper.set.insert(Record(value: newValue, timestamp: time))
	}
	
	func remove(oldValue: T) {
		guard let _ = getTimestamp(target: oldValue, ops: .add) else { return }
		let time = timestampGenerator.now()
		removeSetWrapper.set.insert(Record(value: oldValue, timestamp: time))
	}
	
	func compare(lwwSetA: LWWElementSet<T>, lwwSetB: LWWElementSet<T>) -> Bool {
		return lwwSetA.addSetWrapper.set.isSubset(of: lwwSetB.addSetWrapper.set) && lwwSetA.removeSetWrapper.set.isSubset(of: lwwSetB.removeSetWrapper.set)
	}
	
	func merge(lwwSetA: LWWElementSet<T>, lwwSetB: LWWElementSet<T>) -> LWWElementSet<T> {
		let newAddSet = lwwSetA.addSetWrapper.set.union(lwwSetB.addSetWrapper.set)
		let newRemoveSet = lwwSetA.removeSetWrapper.set.union(lwwSetB.removeSetWrapper.set)
		return LWWElementSet<T>(addSetWrapper: SetWrapper<Record<T>>(set: newAddSet), removeSetWrapper: SetWrapper<Record<T>>(set: newRemoveSet))
	}
	
	private func getTimestamp(target: T, ops: Ops) -> TimeInterval? {
		let setWrapper = ops == .add ? addSetWrapper : removeSetWrapper
		var latestTimestamp: TimeInterval?
		
		for record in setWrapper.set {
			if record.value == target {
				guard let currentFoundTimestamp = latestTimestamp else {
					latestTimestamp = record.timestamp
					continue
				}
				latestTimestamp = max(currentFoundTimestamp , record.timestamp)
			}
		}
		
		return latestTimestamp
	}
}
