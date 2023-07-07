//
//  ContentView.swift
//  BetterRest
//
//  Created by Simphiwe Mbokazi on 2023/07/03.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var cofeeAmount = 1
    var cofeeRange = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")
                ){
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    
                }
               
                
                
                
                Section(header: Text("Desired amount of sleep")){
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section(header: Text("Daily cofee intake")){
                    
//                    Stepper(cofeeAmount == 1 ? "1 cup" : "\(cofeeAmount) cups", value: $cofeeAmount, in: 1...20)
                    
                    Picker("How much cofee did you drink?", selection: $cofeeAmount){
                        ForEach(cofeeRange, id: \.self){
                            Text(String($0))
                        }
                    }
                    Text(cofeeAmount == 1 ? "1 cup" : "\(cofeeAmount) cups")
                }
                
                Button("Calculate", action: calculateBedtime)
                
                Section{
                    Text("Your ideal bedtime is:")
                    Text("\(alertMessage)")
                        .font(.largeTitle)
                }
                
                
                
            }
            .navigationTitle("BetterRest")
           
        }
       
    }
    
    func calculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(cofeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
