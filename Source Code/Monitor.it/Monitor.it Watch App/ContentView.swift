//
//  ContentView.swift
//  Monitor.it Watch App
//
//  Created by Mark Howard on 02/01/2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    //Declare Tab Selection
    @State var tabSelection = 1
    //Add Activity Data
    @StateObject var data = ActivityData()
    //Add Workout Manager
    @EnvironmentObject var workoutManager: WorkoutManager
    //Declare HealthKit Health Store
    private var healthStore = HKHealthStore()
    //Declare Heart Rate Units Of Measurement
    let heartRateQuantity = HKUnit(from: "count/min")
    //Declare Starting Heart Rate Value
    @State private var value = 0
    //Is Showing Breathe Sheet
    @State var showingBreatheSheet = false
    //Declare Workout Types That Can Be Started
    var workoutTypes: [HKWorkoutActivityType] = [.americanFootball, .archery, .australianFootball, .badminton, .barre, .baseball, .basketball, .bowling, .boxing, .cardioDance, .climbing, .cooldown, .coreTraining, .cricket, .crossCountrySkiing, .crossTraining, .curling, .cycling, .discSports, .downhillSkiing, .elliptical, .equestrianSports, .fencing, .fishing, .fitnessGaming, .flexibility, .functionalStrengthTraining, .golf, .gymnastics, .handCycling, .handball, .highIntensityIntervalTraining, .hiking, .hockey, .hunting, .jumpRope, .kickboxing, .lacrosse, .martialArts, .mindAndBody, .mixedCardio, .other, .paddleSports, .pickleball, .pilates, .play, .preparationAndRecovery, .racquetball, .rowing, .rugby, .running, .sailing, .skatingSports, .snowSports, .snowboarding, .soccer, .socialDance, .softball, .squash, .stairClimbing, .stairs, .stepTraining, .surfingSports, .swimBikeRun, .swimming, .tableTennis, .taiChi, .tennis, .trackAndField, .traditionalStrengthTraining, .volleyball, .walking, .waterFitness, .waterPolo, .waterSports, .wheelchairRunPace, .wheelchairWalkPace, .wrestling, .yoga]
    //Is Breathe Cancelled
    @State var breathCancel = 0
    //Scale Of Breathe Animation
    @State var scale = false
    //Rotation Of Breathe Animation
    @State var rotate  = false
    //Cancel Breathe
    @State var val = 0
    //Remaining Breathe Time
    @State var remaining = 60.0
    //Tab Selection
    var body: some View {
        TabView(selection: $tabSelection) {
            activity
                .tag(1)
            heartRate
                .tag(2)
            workouts
                .tag(3)
            breathe
                .tag(4)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear() {
            workoutManager.requestAuthorisation()
        }
    }
    //Breathe View
    var breathe: some View {
        VStack {
            Image(systemName: "wind")
                .foregroundColor(.cyan)
                .font(Font.custom("Wind", size: CGFloat(60)))
                .padding()
            Button(action: {self.showingBreatheSheet = true}) {
                Text("Start - 1 Min")
            }
            .fullScreenCover(isPresented: $showingBreatheSheet) {
                //Breathe Animation
                breatheView
                //Cancel Button In The Toolbar
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(action: {
                                self.breathCancel = 1
                                self.showingBreatheSheet = false
                                self.val = 0
                                WKInterfaceDevice.current().play(.stop)
                            }) {
                                Text("Cancel")
                            }
                        }
                    }
                //Start Time Tracking On Showing View
                    .onReceive(Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()) { _ in
                        self.remaining -= 0.01
                        if self.remaining <= 0 {
                            self.breathCancel = 0
                            self.val = 0
                            self.showingBreatheSheet = false
                            WKInterfaceDevice.current().play(.success)
                            self.remaining = 60.0
                        }
                    }
                //Save Breathe Time If Finished, Print Canel If Not
                    .onDisappear() {
                        if breathCancel == 0 {
                            saveMeditation(startDate: Date(), minutes: UInt(1))
                        } else if breathCancel == 1 {
                            print("Cancel")
                        } else {
                            print("Error")
                        }
                    }
            }
        }
        .navigationBarTitle("Breathe")
    }
    //Activity View
    var activity: some View {
        VStack {
            //Activity Rings
            ActivityRings(data: data, healthStore: workoutManager.healthStore)
                .scaledToFit()
                Divider()
            //Current Move Amount
            Text("\(data.energyData)")
                .bold()
                .font(.system(.body, design: .rounded))
                .foregroundColor(.red)
                .privacySensitive()
            Divider()
            //Current Exercise Amount
            Text("\(data.exerciseData)")
                .bold()
                .font(.system(.body, design: .rounded))
                .foregroundColor(.green)
                .privacySensitive()
            Divider()
            //Current Stand Amount
            Text("\(data.standData)")
                .bold()
                .font(.system(.body, design: .rounded))
                .foregroundColor(.blue)
                .privacySensitive()
        }
        .navigationTitle("Activity")
    }
    //Workout Selector View
    var workouts: some View {
        //Iterate All Avaliable Workouts
        List(workoutTypes) { workoutType in
            NavigationLink(workoutType.name, value: workoutType)
                .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationDestination(for: HKWorkoutActivityType.self) { workoutType in
                SessionPagingView()
        }
        .navigationTitle("Workouts")
    }
    //Heart Rate Reader View
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
    //Breathe Graphic With Scale And Rotate Animation
    var breatheView: some View {
        ZStack {
            Group {
                ZStack {
                    Circle().frame(width: 80, height: 80)
                        .foregroundColor(Color(UIColor.cyan)).offset(y: -42)
                    Circle().frame(width: 80, height: 80)
                        .foregroundColor(Color(UIColor.cyan)).offset(y: 42)
                }
            }
            .opacity(1/3)
            Group {
                ZStack {
                    Circle().frame(width: 80, height: 80)
                        .foregroundColor(Color(UIColor.cyan)).offset(y: -42)
                    Circle().frame(width: 80, height: 80)
                        .foregroundColor(Color(UIColor.cyan)).offset(y: 42)
                }
            }
            .rotationEffect(.degrees(60)).opacity(1/4)
            Group {
                ZStack {
                    Circle().frame(width: 80, height: 80)
                        .foregroundColor(Color(UIColor.cyan)).offset(y: -42)
                    Circle().frame(width: 80, height: 80)
                        .foregroundColor(Color(UIColor.cyan)).offset(y: 42)
                }
            }
            .rotationEffect(.degrees(120)).opacity(1/2)
        }
        .rotationEffect(.degrees(rotate ? 180 : 0))
        .scaleEffect(scale ? 1 : 1/8)
        .animation(.easeInOut.repeatForever(autoreverses: true)
        .speed(1/8), value: val).onAppear() {
            self.rotate.toggle()
            self.scale.toggle()
            self.val = 1
        }
    }
    //Generate Heart Rate Query And Read Heart Rate
    func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { query, samples, deletedObjects, queryAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            self.process(samples, type: quantityTypeIdentifier)
            }
            
            let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
            
            query.updateHandler = updateHandler
            healthStore.execute(query)
    }
    //Process Heart Rate Data And Update UI
    func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
            
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
                
            self.value = Int(lastHeartRate)
        }
    }
    //Save Breathe Data To HealthKit Health Store
    func saveMeditation(startDate:Date, minutes:UInt) {
        let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession)
        let mindfulSample = HKCategorySample(type: mindfulType!, value: 0, start: Date.init(timeIntervalSinceNow: -(1*60)), end: Date())
        workoutManager.healthStore.save(mindfulSample) { success, error in
            if(error != nil) {
                abort()
            }
            if success {
                print("Success")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//Activity Rings Component
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
                data.energyData = "\(energy?.rounded(.towardZero) ?? Double(0.0))".dropLast(2) + " Kcal"
                data.exerciseData = "\(exercise?.rounded(.towardZero) ?? Double(0.0))".dropLast(2) + " Mins"
                data.standData = "\(stand?.rounded(.towardZero) ?? Double(0.0))".dropLast(2) + " Hours"
                rings.setActivitySummary(summaries?.first, animated: true)
            }
        }
        healthStore.execute(query)
        return rings
    }
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceObjectType, context: Context) {
        
    }
}

//Activity Data To Be Observed For Changes
class ActivityData: ObservableObject {
    @Published var energyData = ""
    @Published var exerciseData = ""
    @Published var standData = ""
}

//Add A Workout Name String To Supported Workout Types
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
            case .swimBikeRun: return "Swim, Bike, Run"
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
