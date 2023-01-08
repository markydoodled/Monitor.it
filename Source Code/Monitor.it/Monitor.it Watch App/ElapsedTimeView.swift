//
//  ElapsedTimeView.swift
//  Monitor.it Watch App
//
//  Created by Mark Howard on 02/01/2023.
//

import SwiftUI

//Current Workout Live Updating Time Duration
struct ElapsedTimeView: View {
    //Store Time
    var elapsedTime: TimeInterval = 0
    //Is Subseconds Used
    var showSubseconds: Bool = true
    //Add Time Formatter
    @State private var timeFormatter = ElapsedTimeFormatter()
    var body: some View {
        Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
            .fontWeight(.semibold)
            .onChange(of: showSubseconds) {
                timeFormatter.showSubseconds = $0
        }
    }
}

//Declare Time Formatter
class ElapsedTimeFormatter: Formatter {
    //Declate Date Formatter For Seconds And Minutes
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    //Is Showing Subseconds
    var showSubseconds = true

    //Generate And Return Formatted String H:M:S:MS
    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        if showSubseconds {
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }
}
