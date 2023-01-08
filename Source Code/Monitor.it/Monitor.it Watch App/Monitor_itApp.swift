//
//  Monitor_itApp.swift
//  Monitor.it Watch App
//
//  Created by Mark Howard on 02/01/2023.
//

import SwiftUI
import HealthKit

@main
struct Monitor_it_Watch_AppApp: App {
    @StateObject var workoutManager = WorkoutManager()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            //Show End Workout Summary View
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            //.environment(workoutManager)
            .environmentObject(workoutManager)
        }
    }
}

//Watch Workout Functions And Processing Manager
class WorkoutManager: NSObject, ObservableObject {
    //Declare Health Store
    let healthStore = HKHealthStore()
    
    //Get Selected Workout And Start
    var selectedWorkout: HKWorkoutActivityType? {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            startWorkout(workoutType: selectedWorkout)
        }
    }
    
    //Shows Summary And Resets On Disappear
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    //Declare Workout Session
    var session: HKWorkoutSession?
    
    //Declare Workout Builder
    var builder: HKLiveWorkoutBuilder?
    
    //Start Workout
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            return
        }

        session?.delegate = self
        builder?.delegate = self

        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            
        }
    }
    
    //Is Workout Running
    @Published var running = false
    
    //Is Water Lock On
    @Published var waterLock = false

    //Toggle Pause Workout
    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }

    //Pause Workout
    func pause() {
        session?.pause()
    }

    //Resume Workout
    func resume() {
        session?.resume()
    }

    //Stop Workout
    func endWorkout() {
        session?.end()
        showingSummaryView = true
    }
    
    //Declare Stats
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?

    //Update Stats
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }

    //Reset Workout And Stats
    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        workout = nil
        session = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }
    
    //Request HealthKit Use
    func requestAuthorisation() {
        if HKHealthStore.isHealthDataAvailable() {
            let typesToShare: Set = [
                HKQuantityType.workoutType(),
                HKObjectType.categoryType(forIdentifier: .mindfulSession)!
            ]
        
            let typesToRead: Set = [
                HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
                HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
                HKQuantityType.quantityType(forIdentifier: .appleStandTime)!,
                HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
                HKObjectType.activitySummaryType()
            ]
        
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                if !success {
                    print("Can't Authorise")
                }
            }
        } else {
            print("Can't Init HealthKit")
        }
    }
}

//Workout Delegate Extension
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {

    }
}

//Workout Builder Delegate Extension
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }

            let statistics = workoutBuilder.statistics(for: quantityType)
            updateForStatistics(statistics)
        }
    }
}
