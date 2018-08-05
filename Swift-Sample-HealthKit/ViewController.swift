//
//  ViewController.swift
//  Swift-Sample-HealthKit
//
//  Created by A10 Lab Inc. nobuy on 2018/08/03.
//  Copyright © 2018年 A10 Lab Inc. nobuy. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    private let identifier = "cell"

    private lazy var healthStore = HKHealthStore()

    private let sectionItems: [HealthKitSectionItem] = [
        HealthKitSectionItem.hkObject(items: [
                HealthKitRowItem.hkObject(HealthKitObjectType.quantity(.stepCount)),
                HealthKitRowItem.hkObject(HealthKitObjectType.quantity(.distanceWalkingRunning)),
                HealthKitRowItem.hkObject(HealthKitObjectType.quantity(.activeEnergyBurned)),
                HealthKitRowItem.hkObject(HealthKitObjectType.summary)
            ])
    ]

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.rowHeight = 44
        tableView.sectionHeaderHeight = 5
        tableView.sectionFooterHeight = 5
        tableView.backgroundColor = UIColor.lightGray
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 5))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 5))
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.delegate = self
        tableView.dataSource = self

        initView()
    }

    private func initView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func requestAuthorization(type: HealthKitObjectType, completion: (()->Void)?, errorHandler: ((_ error: Error)->Void)?) {
        switch type {
        case .quantity(let hkQuantityType):
            healthStore.requestAuthorization(toShare: nil,
                                             read: Set([hkQuantityType.type]),
                                             completion: { success, error in
                                                if let error = error {
                                                    print(error.localizedDescription)
                                                    errorHandler?(error)
                                                    return
                                                }
                                                completion?()
            })
        case .summary:
            healthStore.requestAuthorization(toShare: nil,
                                             read: Set([HKObjectType.activitySummaryType()]),
                                             completion: { success, error in
                                                if let error = error {
                                                    print(error.localizedDescription)
                                                    errorHandler?(error)
                                                    return
                                                }
                                                completion?()
            })
        }
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == sectionItems.count {
            let vc = ShowHKActivityRingViewController()
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        switch sectionItems[indexPath.section] {
        case .hkObject(items: let items):
            switch items[indexPath.row] {
            case .hkObject(let hkObjectType):
                requestAuthorization(type: hkObjectType, completion: nil, errorHandler: nil)
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sectionItems.count {
            return 1
        }
        return sectionItems[section].items.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionItems.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if indexPath.section == sectionItems.count {
            cell.textLabel?.text = "show activity ring"
            return cell
        }
        switch sectionItems[indexPath.section] {
        case .hkObject(items: let items):
            switch items[indexPath.row] {
            case .hkObject(let hkObjectType):
                switch hkObjectType {
                case .quantity(let quantityType):
                    cell.textLabel?.text = quantityType.title
                case .summary:
                    cell.textLabel?.text = "activity summary"
                }
            }
        }
        return cell
    }
}
