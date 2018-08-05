//
//  HKDataType.swift
//  Swift-Sample-HealthKit
//
//  Created by A10 Lab Inc. nobuy on 2018/08/04.
//  Copyright © 2018年 A10 Lab Inc. nobuy. All rights reserved.
//

import HealthKit

enum HealthKitSectionItem {
    case hkObject(items: [HealthKitRowItem])
}

extension HealthKitSectionItem {
    typealias Item = HealthKitRowItem

    var items: [HealthKitRowItem] {
        switch self {
        case .hkObject(items: let items):
            return items.map {$0}
        }
    }
    init(original: HealthKitSectionItem, items: [Item]) {
        switch original {
        case .hkObject(items: let items):
            self = .hkObject(items: items)
        }
    }
}

enum HealthKitRowItem {
    case hkObject(HealthKitObjectType)
}

enum HealthKitObjectType {
    case quantity(HealthKitQuantityType)
    case summary
}

enum HealthKitQuantityType {
    case stepCount
    case distanceWalkingRunning
    case activeEnergyBurned
}

extension HealthKitQuantityType {
    var title: String {
        switch self {
        case .stepCount:
            return "step count"
        case .distanceWalkingRunning:
            return "distance walking"
        case .activeEnergyBurned:
            return "active energy burned"
        }
    }
    var type: HKQuantityType {
        switch self {
        case .stepCount:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        case .distanceWalkingRunning:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        case .activeEnergyBurned:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        }
    }
}
