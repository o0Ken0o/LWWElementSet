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

struct Element<T: Hashable>: Hashable {
	let value: T
	let timestamp: TimeInterval
}

class LWWElementSet<T: Hashable> {
	
	enum Ops: CaseIterable {
		case add, remove
	}
	
	private var addSet: Set<Element<T>>
	private var removeSet: Set<Element<T>>
	
	init(addSet: Set<Element<T>> = [], removeSet: Set<Element<T>> = []) {
		self.addSet = addSet
		self.removeSet = removeSet
	}
	
	func lookup(target: T) -> Bool {
		guard let addLatestTimestamp = getTimestamp(target: target, ops: .add) else { return false }
		guard let removeLatestTimestamp = getTimestamp(target: target, ops: .remove) else { return true }
		return addLatestTimestamp >= removeLatestTimestamp
	}
	
	func add(newValue: T) {
		let time = Date().timeIntervalSince1970
		addSet.insert(Element(value: newValue, timestamp: time))
	}
	
	func remove(oldValue: T) {
		guard let _ = getTimestamp(target: oldValue, ops: .add) else { return }
		let time = Date().timeIntervalSince1970
		removeSet.insert(Element(value: oldValue, timestamp: time))
	}
	
	func compare(lwwSetA: LWWElementSet<T>, lwwSetB: LWWElementSet<T>) -> Bool {
		return lwwSetA.addSet.isSubset(of: lwwSetB.addSet) && lwwSetA.removeSet.isSubset(of: lwwSetB.removeSet)
	}
	
	func merge(lwwSetA: LWWElementSet<T>, lwwSetB: LWWElementSet<T>) -> LWWElementSet<T> {
		let newAddSet = lwwSetA.addSet.union(lwwSetB.addSet)
		let newRemoveSet = lwwSetA.removeSet.union(lwwSetB.removeSet)
		return LWWElementSet<T>(addSet: newAddSet, removeSet: newRemoveSet)
	}
	
	private func getTimestamp(target: T, ops: Ops) -> TimeInterval? {
		let set = ops == .add ? addSet : removeSet
		var latestTimestamp: TimeInterval?
		
		for element in set {
			if element.value == target {
				guard let currentFoundTimestamp = latestTimestamp else {
					latestTimestamp = element.timestamp
					continue
				}
				latestTimestamp = max(currentFoundTimestamp , element.timestamp)
			}
		}
		
		return latestTimestamp
	}
}
