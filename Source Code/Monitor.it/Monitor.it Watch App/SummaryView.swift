//
//  SummaryView.swift
//  Monitor.it Watch App
//
//  Created by Mark Howard on 02/01/2023.
//

import SwiftUI
import HealthKit
import WatchKit

//Workout Summary View
struct SummaryView: View {
    //Add Workout Manager
    @EnvironmentObject var workoutManager: WorkoutManager
    //Add Tracking Variable To Dismiss
    @Environment(\.dismiss) var dismiss
    //Declare Date Formatter For Duration
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    //Declare Activity Data
    @StateObject var data = ActivityData()
    var body: some View {
        if workoutManager.workout == nil {
            ProgressView("Saving Workout")
                .toolbar(.hidden)
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    //Workout Time Total
                    SummaryMetricView(title: "Total Time", value: durationFormatter.string(from: workoutManager.workout?.duration ?? 0.0) ?? "")
                        .foregroundColor(.yellow)
                    //Workout Distance Travelled Total
                    SummaryMetricView(title: "Total Distance", value: Measurement(value: workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0, unit: UnitLength.meters)
                            .formatted(.measurement(width: .abbreviated, usage: .road,numberFormatStyle: .number.precision(.fractionLength(2)))))
                        .foregroundColor(.green)
                    //Workout Total Energy Burned
                    SummaryMetricView(title: "Total Energy", value: Measurement(value: workoutManager.workout?.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0, unit: UnitEnergy.kilocalories)
                            .formatted(.measurement(width: .abbreviated, usage: .workout, numberFormatStyle: .number.precision(.fractionLength(0)))))
                        .foregroundColor(.pink)
                    //Workout Average Heart Rate
                    SummaryMetricView(title: "Avg. Heart Rate", value: workoutManager.averageHeartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
                        .foregroundColor(.red)
                    //Workout Current Activity Rings
                    Text("Activity Rings")
                    ActivityRings(data: data, healthStore: workoutManager.healthStore)
                        .frame(width: 50, height: 50)
                    //Dismiss Summary Button
                    Button(action: {dismiss()}) {
                        Text("Done")
                    }
                }
                .scenePadding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//Metric View To Iterate
struct SummaryMetricView: View {
    var title: String
    var value: String

    var body: some View {
        Text(title)
            .foregroundStyle(.foreground)
        Text(value)
            .privacySensitive()
            .font(.system(.title2, design: .rounded).lowercaseSmallCaps())
        Divider()
    }
}
