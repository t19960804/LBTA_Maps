import Foundation
import MapKit
import GooglePlaces

class PlaceAnnotation: MKPointAnnotation {
    var place: GMSPlace!
    
    init(place: GMSPlace) {
        self.place = place
    }
}
