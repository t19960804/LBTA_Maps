import UIKit
import MapKit
import LBTATools

class MapController: UIViewController {
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.fillSuperview()
    }


}

