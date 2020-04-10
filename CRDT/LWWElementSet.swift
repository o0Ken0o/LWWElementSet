//
//  LWWElementSet.swift
//  CRDT
//
//  Created by Kam Hei Siu on 6/4/2020.
//  Copyright © 2020 Kam Hei Siu. All rights reserved.
//

import Foundation

public struct Record<T: Hashable>: Hashable {
	let value: T
	let timestamp: TimeInterval
}

public protocol TimestampGeneratorProtocol {
	func now() -> TimeInterval
}

public struct TimestampGenerator: TimestampGeneratorProtocol {
	public func now() -> TimeInterval {
		return Date().timeIntervalSince1970
	}
}

public protocol SetWrapper: AnyObject {
	associatedtype SetElement: Hashable
	var set: Set<Record<SetElement>> { get set }
	init(set: Set<Record<SetElement>>)
	init()
}

public class IntRecordSetWrapper: SetWrapper {
	public typealias SetElement = Int
	public var set: Set<Record<SetElement>>
	
	public required init() {
		set = []
	}
	
	public required init(set: Set<Record<Int>>) {
		self.set = set
	}
}

public protocol LWWElementSetProtocol {
	associatedtype T: Hashable
	
	func lookup(target: T) -> Bool
	func add(newValue: T)
	func remove(oldValue: T)
	static func compare(lwwSetA: Self, lwwSetB: Self) -> Bool
	static func merge(lwwSetA: Self, lwwSetB: Self) -> Self
}

public final class LWWElementSet<T: SetWrapper>: LWWElementSetProtocol {
	
	enum Ops: CaseIterable {
		case add, remove
	}
	
	private var addSetWrapper: T
	private var removeSetWrapper: T
	private let timestampGenerator: TimestampGeneratorProtocol
	
	init(addSetWrapper: T,
		 removeSetWrapper: T,
		 timestampGenerator: TimestampGeneratorProtocol = TimestampGenerator()) {
		self.addSetWrapper = addSetWrapper
		self.removeSetWrapper = removeSetWrapper
		self.timestampGenerator = timestampGenerator
	}
	
	convenience init() {
		let addSetWrapper = IntRecordSetWrapper() as! T
		let removeSetWrapper = IntRecordSetWrapper() as! T
		self.init(addSetWrapper: addSetWrapper, removeSetWrapper: removeSetWrapper)
	}
	
	convenience init(addSetWrapper: T) {
		let removeSetWrapper = IntRecordSetWrapper() as! T
		self.init(addSetWrapper: addSetWrapper, removeSetWrapper: removeSetWrapper)
	}
	
	convenience init(removeSetWrapper: T) {
		let addSetWrapper = IntRecordSetWrapper() as! T
		self.init(addSetWrapper: addSetWrapper, removeSetWrapper: removeSetWrapper)
	}
	
	convenience init(timestampGenerator: TimestampGeneratorProtocol) {
		let addSetWrapper = IntRecordSetWrapper() as! T
		let removeSetWrapper = IntRecordSetWrapper() as! T
		self.init(addSetWrapper: addSetWrapper, removeSetWrapper: removeSetWrapper, timestampGenerator: timestampGenerator)
	}
	
	convenience init(addSetWrapper: T, timestampGenerator: TimestampGeneratorProtocol) {
		let removeSetWrapper = IntRecordSetWrapper() as! T
		self.init(addSetWrapper: addSetWrapper, removeSetWrapper: removeSetWrapper, timestampGenerator: timestampGenerator)
	}
	
	public func lookup(target: T.SetElement) -> Bool {
		guard let addLatestTimestamp = getTimestamp(target: target, ops: .add) else { return false }
		guard let removeLatestTimestamp = getTimestamp(target: target, ops: .remove) else { return true }
		return addLatestTimestamp >= removeLatestTimestamp
	}
	
	public func add(newValue: T.SetElement) {
		let time = timestampGenerator.now()
		addSetWrapper.set.insert(Record(value: newValue, timestamp: time))
	}
	
	public func remove(oldValue: T.SetElement) {
		guard let _ = getTimestamp(target: oldValue, ops: .add) else { return }
		let time = timestampGenerator.now()
		removeSetWrapper.set.insert(Record(value: oldValue, timestamp: time))
	}
	
	public static func compare(lwwSetA: LWWElementSet<T>, lwwSetB: LWWElementSet<T>) -> Bool {
		return lwwSetA.addSetWrapper.set.isSubset(of: lwwSetB.addSetWrapper.set)
			&& lwwSetA.removeSetWrapper.set.isSubset(of: lwwSetB.removeSetWrapper.set)
	}
	
	public static func merge(lwwSetA: LWWElementSet<T>, lwwSetB: LWWElementSet<T>) -> LWWElementSet<T> {
		let newAddSet = lwwSetA.addSetWrapper.set.union(lwwSetB.addSetWrapper.set)
		let newRemoveSet = lwwSetA.removeSetWrapper.set.union(lwwSetB.removeSetWrapper.set)
		let mergedSet = LWWElementSet(addSetWrapper: T(set: newAddSet), removeSetWrapper: T(set: newRemoveSet))
		return mergedSet
	}
	
	private func getTimestamp(target: T.SetElement, ops: Ops) -> TimeInterval? {
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

extension LWWElementSet: Equatable {
	public static func == (lhs: LWWElementSet<T>, rhs: LWWElementSet<T>) -> Bool {
		return lhs.addSetWrapper.set == rhs.addSetWrapper.set && lhs.removeSetWrapper.set == rhs.removeSetWrapper.set
	}
}
