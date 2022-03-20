import UIKit
import MapKit
import LBTATools

class MapController: UIViewController {
    let mapView = MKMapView()
    let initialCoordinate = CLLocationCoordinate2D(latitude: 25.036151, longitude: 121.452080)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRegion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        findNearbyLandMark(term: "國中")
    }
    
    func setupUI() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.fillSuperview()
    }
    
    func setupRegion() {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) //值越小, 地圖可以顯示越精細
        let region = MKCoordinateRegion(center: initialCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func findNearbyLandMark(term: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
        request.region = mapView.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            if let error = error {
                print("Error - Find Nearby LandMark Fail:\(error)")
                return
            }
            response?.mapItems.forEach { item in
                let placemark = item.placemark
                print(placemark.addressString)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        view.canShowCallout = true
//        view.image = UIImage(named: "tourist")
        return view
    }
}

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
