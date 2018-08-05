//
//  ShowHKActivityRingViewController.swift
//  Swift-Sample-HealthKit
//
//  Created by A10 Lab Inc. nobuy on 2018/08/03.
//  Copyright © 2018年 A10 Lab Inc. nobuy. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI

class ShowHKActivityRingViewController: UIViewController {

    private lazy var healthStore = HKHealthStore()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()

    private let activityRingView = HKActivityRingView()

    private let convertToImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("save image", for: UIControlState())
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 5
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        convertToImageButton.addTarget(self, action: #selector(self.saveImage(_:)), for: .touchUpInside)

        view.addSubview(containerView)
        containerView.addSubview(activityRingView)
        view.addSubview(convertToImageButton)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 240).isActive = true

        activityRingView.translatesAutoresizingMaskIntoConstraints = false
        activityRingView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30).isActive = true
        activityRingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30).isActive = true
        activityRingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30).isActive = true
        activityRingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30).isActive = true

        convertToImageButton.translatesAutoresizingMaskIntoConstraints = false
        convertToImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        convertToImageButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10).isActive = true
        convertToImageButton.widthAnchor.constraint(equalToConstant: 240).isActive = true
        convertToImageButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let summary = HKActivitySummary()
        activityRingView.setActivitySummary(summary, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //setActivitySummaryForTest()
        updateActivitySummaries()
    }

    private func setActivitySummaryForTest() {
        let summary = HKActivitySummary()
        let calorie = HKUnit.largeCalorie()
        summary.activeEnergyBurned = HKQuantity(unit: calorie, doubleValue: 1000.0)
        summary.activeEnergyBurnedGoal = HKQuantity(unit: calorie, doubleValue: 2000.0)
        let second = HKUnit.second()
        summary.appleExerciseTime = HKQuantity(unit: second, doubleValue: 1400.0)
        summary.appleExerciseTimeGoal = HKQuantity(unit: second, doubleValue: 3600.0)
        let standHours = HKUnit.count()
        summary.appleStandHours = HKQuantity(unit: standHours, doubleValue: 2800.0)
        summary.appleStandHoursGoal = HKQuantity(unit: standHours, doubleValue: 3000.0)
        activityRingView.setActivitySummary(summary, animated: true)
    }

    private func updateActivitySummaries() {
        // Create the date components for the predicate
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
            fatalError("*** This should never fail. ***")
        }
        let endDate = NSDate()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate as Date, options: []) else {
            fatalError("*** unable to calculate the start date ***")
        }

        let units: NSCalendar.Unit = [.day, .month, .year, .era]
        var startDateComponents = calendar.components(units, from: startDate)
        startDateComponents.calendar = calendar as Calendar
        var endDateComponents = calendar.components(units, from: endDate as Date)
        endDateComponents.calendar = calendar as Calendar

        // Create the predicate for the query
        let summariesWithinRange = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)

        // Build the query
        let query = HKActivitySummaryQuery(predicate: summariesWithinRange) { (query, summaries, error) -> Void in
            guard let activitySummaries = summaries else {
                guard let _ = error else {
                    fatalError("*** Did not return a valid error object. ***")
                }
                // Handle the error here...
                return
            }
            self.activityRingView.setActivitySummary(activitySummaries.first, animated: true)
        }

        // Run the query
        healthStore.execute(query)
    }

    @objc func saveImage(_ sender: UIButton) {
        let image : UIImage = viewToImage(containerView)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didFinishSavingImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    private func viewToImage(_ view : UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        return image
    }

    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        var title = "保存完了"
        var message = "カメラロールに保存しました"
        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
