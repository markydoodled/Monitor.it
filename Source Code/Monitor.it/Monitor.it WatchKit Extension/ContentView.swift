//
//  ContentView.swift
//  Monitor.it WatchKit Extension
//
//  Created by Mark Howard on 26/09/2021.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State var tabSelection = 1
    @StateObject var data = ActivityData()
    @EnvironmentObject var workoutManager: WorkoutManager
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    @State private var value = 0
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]
    var body: some View {
        TabView(selection: $tabSelection) {
            activity
                .tag(1)
            heartRate
                .tag(2)
            workouts
                .tag(3)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear() {
            workoutManager.requestAuthorisation()
        }
    }
    var activity: some View {
            VStack {
                ActivityRings(data: data, healthStore: workoutManager.healthStore)
                    Divider()
                Text("\(data.energyData)")
                    .bold()
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.red)
                    .privacySensitive()
                Divider()
                Text("\(data.exerciseData)")
                    .bold()
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.green)
                    .privacySensitive()
                Divider()
                Text("\(data.standData)")
                    .bold()
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.blue)
                    .privacySensitive()
                /*HStack {
                    Spacer()
                    Text("\(data.energyData)")
                        .bold()
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.red)
                    Spacer()
                    Text("\(data.exerciseData)")
                        .bold()
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(data.standData)")
                        .bold()
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.blue)
                    Spacer()
                }*/
            }
            .navigationTitle("Activity")
    }
    var workouts: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(destination: SessionPagingView(), tag: workoutType, selection: $workoutManager.selectedWorkout) {
                Text(workoutType.name)
                    .bold()
                //Image(uiImage: UIImage(contentsOfFile: workoutType.url?.path) ?? UIImage())
            }
                .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
            .navigationTitle("Workouts")
        }
    var heartRate: some View {
        VStack {
            HStack {
                Button(action: {startHeartRateQuery(quantityTypeIdentifier: .heartRate)}) {
                    Image(systemName: "arrow.clockwise.heart.fill")
                        .foregroundColor(.red)
                        .font(Font.custom("Heart", size: CGFloat(60)))
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
                Spacer()
        }
            HStack {
                Text("\(value) BPM")
                    .bold()
                    .font(.system(.title, design: .rounded))
                    .padding()
                    .privacySensitive()
                Spacer()
            }
            .padding(.bottom)
            Spacer()
        }
            .navigationTitle("Heart Rate")
    }
    func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
            
            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
            let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                query, samples, deletedObjects, queryAnchor, error in
                
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
                
            self.process(samples, type: quantityTypeIdentifier)

            }
            
            let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
            
            query.updateHandler = updateHandler
            healthStore.execute(query)
        }
    func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
            var lastHeartRate = 0.0
            
            for sample in samples {
                if type == .heartRate {
                    lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
                }
                
                self.value = Int(lastHeartRate)
            }
        }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ActivityRings: WKInterfaceObjectRepresentable {
    @ObservedObject var data: ActivityData
    let healthStore: HKHealthStore
    func makeWKInterfaceObject(context: Context) -> some WKInterfaceObject {
        let rings = WKInterfaceActivityRing()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.era, .year, .month, .day], from: Date())
        components.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: components)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { query, summaries, error in
            DispatchQueue.main.async {
                let standUnit = HKUnit.count()
                let exerciseUnit = HKUnit.minute()
                let energyUnit = HKUnit.kilocalorie()
                let energy = summaries?.first?.activeEnergyBurned.doubleValue(for: energyUnit)
                let stand = summaries?.first?.appleStandHours.doubleValue(for: standUnit)
                let exercise = summaries?.first?.appleExerciseTime.doubleValue(for: exerciseUnit)
                data.energyData = "\(energy?.rounded(.towardZero) ?? Double(0.0)) \(energyUnit)"
                data.exerciseData = "\(exercise?.rounded(.towardZero) ?? Double(0.0)) \(exerciseUnit)"
                data.standData = "\(stand?.rounded(.towardZero) ?? Double(0.0)) \(standUnit)"
                rings.setActivitySummary(summaries?.first, animated: true)
            }
        }
        healthStore.execute(query)
        return rings
    }
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceObjectType, context: Context) {
        
    }
}

class ActivityData: ObservableObject {
    @Published var energyData = ""
    @Published var exerciseData = ""
    @Published var standData = ""
}

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }
    var name: String {
            switch self {
            case .americanFootball: return "American Football"
            case .archery: return "Archery"
            case .australianFootball: return "Australian Football"
            case .badminton: return "Badminton"
            case .barre: return "Barre"
            case .baseball: return "Baseball"
            case .basketball: return "Basketball"
            case .bowling: return "Bowling"
            case .boxing: return "Boxing"
            case .cardioDance: return "Cardio Dance"
            case .climbing: return "Climbing"
            case .cooldown: return "Cooldown"
            case .coreTraining: return "Core Training"
            case .cricket: return "Cricket"
            case .crossCountrySkiing: return "Cross Country Skiing"
            case .crossTraining: return "Cross Training"
            case .curling: return "Curling"
            case .cycling: return "Cycling"
            case .dance: return "Dance"
            case .danceInspiredTraining: return "Dance Inspired Training"
            case .discSports: return "Disc Sports"
            case .downhillSkiing: return "Downhill Skiing"
            case .elliptical: return "Elliptical"
            case .equestrianSports: return "Equestrian Sports"
            case .fencing: return "Fencing"
            case .fishing: return "Fishing"
            case .fitnessGaming: return "Fitness Gaming"
            case .flexibility: return "Flexibility"
            case .functionalStrengthTraining: return "Functional Strength Training"
            case .golf: return "Golf"
            case .gymnastics: return "Gymnastics"
            case .handCycling: return "Hand Cycling"
            case .handball: return "Handball"
            case .highIntensityIntervalTraining: return "High Intensity Interval Training"
            case .hiking: return "Hiking"
            case .hockey: return "Hockey"
            case .hunting: return "Hunting"
            case .jumpRope: return "Jump Rope"
            case .kickboxing: return "Kickboxing"
            case .lacrosse: return "Lacrosse"
            case .martialArts: return "Martial Arts"
            case .mindAndBody: return "Mind and Body"
            case .mixedCardio: return "Mixed Cardio"
            case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
            case .other: return "Other"
            case .paddleSports: return "Paddle Sports"
            case .pickleball: return "Pickleball"
            case .pilates: return "Pilates"
            case .play: return "Play"
            case .preparationAndRecovery: return "Preparation and Recovery"
            case .racquetball: return "Racquetball"
            case .rowing: return "Rowing"
            case .rugby: return "Rugby"
            case .running: return "Running"
            case .sailing: return "Sailing"
            case .skatingSports: return "Skating Sports"
            case .snowSports: return "Snow Sports"
            case .snowboarding: return "Snowboarding"
            case .soccer: return "Soccer"
            case .socialDance: return "Social Dance"
            case .softball: return "Softball"
            case .squash: return "Squash"
            case .stairClimbing: return "Stair Climbing"
            case .stairs: return "Stairs"
            case .stepTraining: return "Step Training"
            case .surfingSports: return "Surfing Sports"
            case .swimming: return "Swimming"
            case .tableTennis: return "Table Tennis"
            case .taiChi: return "Tai Chi"
            case .tennis: return "Tennis"
            case .trackAndField: return "Track and Field"
            case .traditionalStrengthTraining: return "Traditional Strength Training"
            case .volleyball: return "Volleyball"
            case .walking: return "Walking"
            case .waterFitness: return "Water Fitness"
            case .waterPolo: return "Water Polo"
            case .waterSports: return "Water Sports"
            case .wheelchairRunPace: return "Wheelchair Run Pace"
            case .wheelchairWalkPace: return "Wheelchair Walk Pace"
            case .wrestling: return "Wrestling"
            case .yoga: return "Yoga"
            default: return "Unknown"
            }
        }
}
