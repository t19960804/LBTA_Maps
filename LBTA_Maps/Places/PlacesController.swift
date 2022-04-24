import LBTATools
import MapKit
import GooglePlaces

class PlacesController: UIViewController, CLLocationManagerDelegate {
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private var previousCallOutView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        mapView.delegate = self
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
                
                let annotation = PlaceAnnotation()
                annotation.title = place.name
                annotation.coordinate = place.coordinate
                annotation.types = place.types ?? []
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
        locationManager.stopUpdatingLocation()
    }
}

extension PlacesController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let placeAnnotation = annotation as? PlaceAnnotation else {
            return nil
        }
        let view = MKPinAnnotationView(annotation: placeAnnotation, reuseIdentifier: "id")
        //view.canShowCallout = true
        if let firstType = placeAnnotation.types.first {
            if firstType == "bar" {
                view.image = UIImage(named: "bar")
            } else if firstType == "restaurant" {
                view.image = UIImage(named: "restaurant")
            } else {
                view.image = UIImage(named: "tourist")
            }
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        previousCallOutView?.removeFromSuperview()
        previousCallOutView = nil
        
        let customCallOutView = UIView()
        customCallOutView.translatesAutoresizingMaskIntoConstraints = false
        customCallOutView.backgroundColor = .red
        view.addSubview(customCallOutView)
        NSLayoutConstraint.activate([
            customCallOutView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customCallOutView.bottomAnchor.constraint(equalTo: view.topAnchor),
            customCallOutView.widthAnchor.constraint(equalToConstant: 100 * getHScale()),
            customCallOutView.heightAnchor.constraint(equalToConstant: 100 * getVScale())
        ])
        
        previousCallOutView = customCallOutView
    }
}
