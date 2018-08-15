//
//  HearthKitTool.swift
//  ZwqSwift
//
//  Created by zhangwenqiang on 2018/8/14.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit
import HealthKit
class HearthKitTool: UIView {
    static let share = HearthKitTool()
    var healthStore:HKHealthStore = HKHealthStore()
    var aryMutble = NSMutableArray.init()
    func getRight() {
        if HKHealthStore.isHealthDataAvailable() {
//            let allTypes = Set([HKObjectType.workoutType(),
//                                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//                                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
//                                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//                                HKObjectType.quantityType(forIdentifier: .heartRate)!])
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!])
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                }
            }
            // Add code to use HealthKit here.
        }
    }
    func getData(_ lable:UILabel)  {
        if HKHealthStore.isHealthDataAvailable(){
            let walkType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let authorState = healthStore.authorizationStatus(for: walkType)
            if authorState == .sharingAuthorized{
                let calendar = NSCalendar.current
                let now = NSDate()
                let comp = Calendar.Component.day
                let components =
                    calendar.dateComponents([.year, .month, .day], from: now as Date)
                
                guard let startDate = calendar.date(from: components)
                else {
                    fatalError("*** Unable to create the start date ***")
                }
                let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
                
                guard let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
                    fatalError("*** This method should never fail ***")
                }
                
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
                
                let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
                    query, results, error in
                    
                    guard let samples = results as? [HKQuantitySample] else {
                        print(error?.localizedDescription ?? "")
                         print(error.debugDescription)
                        return
                    }
                    
                    DispatchQueue.main.async() {
                        
//                        foodItems.removeAll()
                        var nStep = 0.0
                        for sample in samples {
                            
                             nStep +=  sample.quantity.doubleValue(for: HKUnit.count())
                            
//                            guard let foodName =
//                                sample.metadata?[HKMetadataKeyFoodType] as? String else {
//                                    // if the metadata doesn't record the food type, just skip it.
//                                    break
//                            }
//
//                            let joules = sample.quantity.doubleValueForUnit(HKUnit.jouleUnit())
//
//                            let foodItem = AAPLFoodItem.foodItemWithName(foodName, joules: joules)
//
//                            foodItems.append(foodItem)
                        }
                        lable.text = "\(nStep)"
//                        tableView.reloadData()
                    }
                }
                
                healthStore.execute(query)
            }
        }
       // return true
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
