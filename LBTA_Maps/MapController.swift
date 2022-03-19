import UIKit
import MapKit
import LBTATools

class MapController: UIViewController {
    let mapView = MKMapView()
    let coordinate_SanFrancisco = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRegion()
        setupAnnotations()
    }
    
    func setupUI() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.fillSuperview()
    }
    
    func setupRegion() {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) //值越小, 地圖可以顯示越精細
        let region = MKCoordinateRegion(center: coordinate_SanFrancisco, span: span)
        mapView.setRegion(region, animated: true)
    }

    func setupAnnotations() {
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate = coordinate_SanFrancisco
        annotation1.title = "San Francisco"
        annotation1.subtitle = "CA"
        
        let coordinate_AppleCampus = CLLocationCoordinate2D(latitude: 37.3326, longitude: -122.030024)
        let annotation2 = MKPointAnnotation()
        annotation2.coordinate = coordinate_AppleCampus
        annotation2.title = "Apple Campus"
        annotation2.subtitle = "CA"
        
        mapView.addAnnotations([annotation1, annotation2])
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        view.canShowCallout = true
        view.image = UIImage(named: "tourist")
        return view
    }
}
