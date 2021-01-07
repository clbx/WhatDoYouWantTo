//
//  ContentView.swift
//  PickMe
//
//  Created by Clay Buxton on 1/5/21.
//

import SwiftUI
import MapKit
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
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            if error == nil {
                self.placemark = places?[0]
            } else {
                self.placemark = nil
            }
       })
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
    

    var placemark: String { return("\(lm.placemark?.name ?? "XXX")") }
    
    
    var latitude: Double {lm.location?.coordinate.latitude ?? 0}
    
    
    var longitude: Double {lm.location?.coordinate.longitude ?? 0}
    
    
    @State var alertIsVisible: Bool = false
    @State var locationData: String = ""
    
    
    @State var locations: [String] = []

    
    var body: some View {
        
        
        VStack {
            Text("Search for Shit")
                .padding()
                    
            
            TextField("Enter Location", text: $locationData)
            
            Button(action: {
                locations.removeAll()
                locations.append(contentsOf:  getLocations(loc: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
                print(locations)
                buttonPress(location: locationData)
                self.alertIsVisible = true
            }) {
                Text("Go!")
            }
            
            
            
            List{
                ForEach(locations, id: \.self) { location in
                                Text(location)
                            }
            }

            
            
            Text("Latitude: \(self.latitude)")
            Text("Longitude: \(self.longitude)")
            Text("Placemark: \(self.placemark)")
                        
            
            
            Spacer()
        }
    }
    
}


func getLocations(loc: CLLocationCoordinate2D ) -> [String] {
    
    var locationNames: [String] = []
    
    let searchRequest = MKLocalSearch.Request()
    searchRequest.region = MKCoordinateRegion(
        center: loc,
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )
    
    searchRequest.naturalLanguageQuery = "food"
    
    let search = MKLocalSearch(request: searchRequest)
    search.start{ (response, error) in
        guard let response = response else{
            print(error?.localizedDescription)
            return
        }
        /*
        for item in response.mapItems{
            if let name = item.name,
               let location = item.placemark.location{
                print("\(name): \(location.coordinate.latitude),\(location.coordinate.longitude)")
            }
        }*/
        for item in response.mapItems{
            if let name = item.name{
                locationNames.append(name)
            }
        }
    }
    print(locationNames)
    
    return locationNames
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
