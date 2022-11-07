//
//  WorkoutControlsView.swift
//  Monitor.it WatchKit Extension
//
//  Created by Mark Howard on 17/10/2021.
//

import SwiftUI
import WatchKit

struct WorkoutControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var body: some View {
        VStack {
        HStack {
            VStack {
                Button {
                    workoutManager.endWorkout()
                    workoutManager.waterLock = false
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(.red)
                .font(.title2)
                Text("End")
            }
            VStack {
                Button {
                    workoutManager.togglePause()
                } label: {
                    Image(systemName: workoutManager.running ? "pause" : "play")
                }
                .tint(.yellow)
                .font(.title2)
                Text(workoutManager.running ? "Pause" : "Resume")
            }
        }
            HStack {
                VStack {
                    Button {
                        if WKInterfaceDevice.current().waterResistanceRating == .wr50 {
                            WKInterfaceDevice.current().enableWaterLock()
                        workoutManager.waterLock = true
                        } else {
                            print("Not To Water Lock Standards")
                        }
                    } label: {
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

struct WorkoutControlsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutControlsView()
    }
}
