import UIKit
import MapKit
import LBTATools

class MapController: UIViewController {
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.fillSuperview()
        setupRegion()
    }
    
    func setupRegion() {
        let center = CLLocationCoordinate2D(latitude: 25.036365, longitude: 121.453625)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) //值越小, 地圖可以顯示越精細
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }

}

