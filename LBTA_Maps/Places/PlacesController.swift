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
                
                let annotation = PlaceAnnotation(place: place)
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
        if let firstType = placeAnnotation.place.types?.first {
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
        customCallOutView.backgroundColor = .white
        customCallOutView.translatesAutoresizingMaskIntoConstraints = false
        customCallOutView.layer.borderColor = UIColor.darkGray.cgColor
        customCallOutView.layer.borderWidth = 2 * getHScale()
        customCallOutView.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        customCallOutView.layer.cornerRadius = 5
        customCallOutView.clipsToBounds = true
        view.addSubview(customCallOutView)
        
        let widthAnchor = customCallOutView.widthAnchor.constraint(equalToConstant: 100 * getHScale())
        let heightAnchor =             customCallOutView.heightAnchor.constraint(equalToConstant: 100 * getVScale())
        NSLayoutConstraint.activate([
            customCallOutView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customCallOutView.bottomAnchor.constraint(equalTo: view.topAnchor),
            widthAnchor,
            heightAnchor
        ])
        
        previousCallOutView = customCallOutView
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        customCallOutView.addSubview(indicator)
        indicator.fillSuperview()
        indicator.startAnimating()
        
        guard let placeAnnotation = view.annotation as? PlaceAnnotation,
              let placeId = placeAnnotation.place.placeID else { return }
        client.lookUpPhotos(forPlaceID: placeId) { [weak self] list, error in
            if let error = error {
                print("Error - lookUpPhotos failed:\(error)")
                return
            }
            guard let data = list?.results.first else { return }
            self?.client.loadPlacePhoto(data) { image, error in
                if let error = error {
                    print("Error - loadPlacePhoto failed:\(error)")
                    return
                }
                guard let image = image else { return }
                // Resize customCallOutView
                if image.size.width > image.size.height {
                    let newWidth: CGFloat = 200 * getHScale()
                    let newHeight: CGFloat = newWidth * image.size.height / image.size.width * getVScale()
                    widthAnchor.constant = newWidth
                    heightAnchor.constant = newHeight
                } else {
                    let newHeight: CGFloat = 200 * getVScale()
                    let newWidth: CGFloat = newHeight * image.size.width / image.size.height * getHScale()
                    widthAnchor.constant = newWidth
                    heightAnchor.constant = newHeight
                }
                
                let imageView = UIImageView(image: image)
                customCallOutView.addSubview(imageView)
                imageView.fillSuperview()
                
                indicator.stopAnimating()
            }
        }
    }
}
