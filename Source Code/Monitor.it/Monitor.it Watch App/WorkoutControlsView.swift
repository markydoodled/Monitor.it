//
//  WorkoutControlsView.swift
//  Monitor.it Watch App
//
//  Created by Mark Howard on 02/01/2023.
//

import SwiftUI
import WatchKit

//Workout Controls Page
struct WorkoutControlsView: View {
    //Add Workout Manager
    @EnvironmentObject var workoutManager: WorkoutManager
    var body: some View {
        VStack {
            HStack {
                VStack {
                    //Stops Workout
                    Button(action: {
                        workoutManager.endWorkout()
                        workoutManager.waterLock = false
                    }) {
                        Image(systemName: "xmark")
                    }
                    .tint(.red)
                    .font(.title2)
                    Text("End")
                }
                VStack {
                    //Pauses Workout
                    Button(action: {workoutManager.togglePause()}) {
                        Image(systemName: workoutManager.running ? "pause" : "play")
                    }
                    .tint(.yellow)
                    .font(.title2)
                    Text(workoutManager.running ? "Pause" : "Resume")
                }
            }
            HStack {
                VStack {
                    //Enables Water Lock
                    Button(action: {
                        if WKInterfaceDevice.current().waterResistanceRating == .wr50 {
                            WKInterfaceDevice.current().enableWaterLock()
                            workoutManager.waterLock = true
                        } else {
                            print("Not To Water Lock Standards")
                        }
                    }) {
                        Image(systemName: "drop.fill")
                    }
                    .tint(.blue)
                    .font(.title2)
                    Text("Lock")
                }
            }
        }
    }
}
