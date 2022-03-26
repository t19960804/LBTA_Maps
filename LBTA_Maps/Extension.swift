import Foundation
import MapKit

extension MKPlacemark {
    var addressString: String {
        var addressString = ""
        if let subThoroughfare = subThoroughfare {
            addressString = subThoroughfare + " "
        }
        if let thoroughfare = thoroughfare {
            addressString += thoroughfare + ", "
        }
        if let postalCode = postalCode {
            addressString += postalCode + " "
        }
        if let locality = locality {
            addressString += locality + ", "
        }
        if let administrativeArea = administrativeArea {
            addressString += administrativeArea + " "
        }
        if let country = country {
            addressString += country
        }
        return addressString
    }
}
