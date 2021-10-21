//
//  WorkoutControlsView.swift
//  Monitor.it WatchKit Extension
//
//  Created by Mark Howard on 17/10/2021.
//

import SwiftUI

struct WorkoutControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var body: some View {
        HStack {
            VStack {
                Button {
                    workoutManager.endWorkout()
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
    }
}

struct WorkoutControlsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutControlsView()
    }
}
