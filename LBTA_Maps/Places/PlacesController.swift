import LBTATools
import MapKit
import GooglePlaces

class PlacesController: UIViewController, CLLocationManagerDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        locationManager.delegate = self
        
        requestForLocationAuthorization()
    }
    
    let client = GMSPlacesClient()
    
    fileprivate func findNearbyPlaces() {
        client.currentPlace { [weak self] (likelihoodList, err) in
            if let err = err {
                print("Failed to find current place:", err)
                return
            }
            
            likelihoodList?.likelihoods.forEach({  (likelihood) in
                print(likelihood.place.name ?? "")
                
                let place = likelihood.place
                
                let annotation = MKPointAnnotation()
                annotation.title = place.name
                annotation.coordinate = place.coordinate
                
                self?.mapView.addAnnotation(annotation)
            })
            
            self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
        }
    }
    
    fileprivate func requestForLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: first.coordinate, span: span)
        mapView.setRegion(region, animated: false)
        
        findNearbyPlaces()
    }
}
