//
//  ContentView.swift
//  PickMe
//
//  Created by Clay Buxton on 1/5/21.
//

import SwiftUI
import Combine
import Foundation
import CoreLocation


class LocationManager: NSObject, ObservableObject {
  private let locationManager = CLLocationManager()
  let objectWillChange = PassthroughSubject<Void, Never>()
    private let geocoder = CLGeocoder();
    
    
  @Published var status: CLAuthorizationStatus? {
    willSet { objectWillChange.send() }
  }

  @Published var location: CLLocation? {
    willSet { objectWillChange.send() }
  }

  override init() {
    super.init()

    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
  }

    
  @Published var placemark: CLPlacemark? {
    willSet { objectWillChange.send() }
  }

  private func geocode() {
    guard let location = self.location else { return }    

  }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.geocode()
    }
}

struct ContentView: View {
    
    @ObservedObject var lm = LocationManager()
    
    
    @State var alertIsVisible: Bool = false
    @State var locationData: String = ""
    
    var body: some View {
        VStack {
            Text("Search for Shit")
                .padding()
                    
            
            TextField("Enter Location", text: $locationData)
            
            Button(action: {
                buttonPress(location: locationData)
                self.alertIsVisible = true
            }) {
                Text("Go!")
            }
            Spacer()
        }
    }
}

func buttonPress(location: String){
    print ("Button Pressed")
    print (location)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
