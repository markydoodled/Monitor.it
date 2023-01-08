//
//  SessionPagingView.swift
//  Monitor.it Watch App
//
//  Created by Mark Howard on 02/01/2023.
//

import SwiftUI
import HealthKit
import WatchKit

//Pages During Workout
struct SessionPagingView: View {
    //Add Workout Manager
    @EnvironmentObject var workoutManager: WorkoutManager
    //Detect Display Sleep
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    //State Default Tab
    @State private var selection: Tab = .metrics
    //State Tabs In Workout
    enum Tab {
        case controls, metrics, nowPlaying
    }
    var body: some View {
        TabView(selection: $selection) {
            WorkoutControlsView()
                .tag(Tab.controls)
            MetricsView()
                .tag(Tab.metrics)
            NowPlayingView()
                .tag(Tab.nowPlaying)
        }
        .navigationTitle(workoutManager.selectedWorkout?.name ?? "")
        .onChange(of: workoutManager.waterLock) { _ in
            displayMetricsView()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(selection == .nowPlaying)
        .onChange(of: workoutManager.running) { _ in
            displayMetricsView()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .onChange(of: isLuminanceReduced) { _ in
            displayMetricsView()
        }
    }
    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}
