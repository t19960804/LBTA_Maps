import UIKit
import MapKit
import LBTATools
import Combine

class MapController: UIViewController {
    private let mapView = MKMapView()
    private let searchTextField = UITextField(placeholder: "Search Query")

    private let initialCoordinate = CLLocationCoordinate2D(latitude: 25.036151, longitude: 121.452080)

    private var searchTextFieldSubscriber: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRegion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchTextFieldSubscriber()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        findNearbyLandmark(term: "國中")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextFieldSubscriber?.cancel()
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.fillSuperview()
        
        let searchContainer = UIView(backgroundColor: .white)
        searchContainer.layer.cornerRadius = 5
        searchContainer.layer.shadowOffset = .init(width: 0, height: 2)
        searchContainer.layer.shadowColor = UIColor.black.cgColor
        searchContainer.layer.shadowOpacity = 0.5
        searchContainer.layer.shadowRadius = 0.5
        view.addSubview(searchContainer)
        searchContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 50))
        
        searchContainer.addSubview(searchTextField)
        searchTextField.anchor(top: searchContainer.topAnchor, leading: searchContainer.leadingAnchor, bottom: searchContainer.bottomAnchor, trailing: searchContainer.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8), size: .init(width: 0, height: 0))
    }
    
    private func setupSearchTextFieldSubscriber() {
        //Debounce > Publishes elements only after a specified time interval elapses between events. 若接收到的element之間的間隔超過指定時間,才會將element往下游傳
        //Throttle > Publishes either the most-recent or first element in the specified time interval. 往下游傳在指定時間內的第一個或最後的element
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
        searchTextFieldSubscriber = publisher
            .map { ($0.object as? UITextField)?.text ?? "" }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates() //若0.5秒過後,element還是跟上一次一樣,就不往下傳element
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.findNearbyLandmark(term: $0)
            }
    }
    
    private func setupRegion() {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) //值越小, 地圖可以顯示越精細
        let region = MKCoordinateRegion(center: initialCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func findNearbyLandmark(term: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
        request.region = mapView.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            if let error = error {
                print("Error - Find Nearby LandMark Fail:\(error)")
                return
            }
            self.mapView.removeAnnotations(self.mapView.annotations) // Remove Previous Annotations
            response?.mapItems.forEach { item in
                let placemark = item.placemark
                print(placemark.addressString)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
            self.searchTextField.resignFirstResponder()
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
