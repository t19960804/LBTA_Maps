import LBTATools
import MapKit
import GooglePlaces

class PlacesController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let client = GMSPlacesClient()

    private let mapView = MKMapView()
    private var previousCalloutView: UIView?
    // InfoView
    private let infoView = UIView(backgroundColor: .white)
    private let nameLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 17 * getHScale()), textColor: .black, textAlignment: .left, numberOfLines: 1)
    private let addressLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 17 * getHScale()), textColor: .lightGray, textAlignment: .left, numberOfLines: 2)
    private let typeLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 14 * getHScale()), textColor: .lightGray, textAlignment: .left, numberOfLines: 1)
    private let infoButton = UIButton(type: .infoLight)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupInfoView()
        requestForLocationAuthorization()
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.delegate = self
    }
    
    private func setupInfoView() {
        infoView.alpha = 0
        infoView.layer.cornerRadius = 5 * getHScale()
        infoView.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        view.addSubview(infoView)
        infoView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 10 * getHScale(), bottom: 5 * getVScale(), right: 10 * getHScale()), size: .init(width: 0, height: 125 * getVScale()))
        
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(addressLabel)
        NSLayoutConstraint.activate([
            addressLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 7 * getHScale())
        ])
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: addressLabel.topAnchor, constant: -4 * getVScale()),
            nameLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor)
        ])
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(typeLabel)
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4 * getVScale()),
            typeLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor)
        ])
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(infoButton)
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 8 * getVScale()),
            infoButton.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -8 * getVScale())
        ])
    }
    
    private func updateInfoView(place: GMSPlace) {
        infoView.alpha = 1
        nameLabel.text = place.name
        addressLabel.text = place.formattedAddress
        typeLabel.text = place.types?.joined(separator: ", ")
    }
    
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
        previousCalloutView?.removeFromSuperview()
        previousCalloutView = nil
        
        let customCalloutView = CustomCalloutView()
        customCalloutView.indicator.startAnimating()
        view.addSubview(customCalloutView)
        
        let widthAnchor = customCalloutView.widthAnchor.constraint(equalToConstant: 100 * getHScale())
        let heightAnchor =             customCalloutView.heightAnchor.constraint(equalToConstant: 100 * getVScale())
        NSLayoutConstraint.activate([
            customCalloutView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customCalloutView.bottomAnchor.constraint(equalTo: view.topAnchor),
            widthAnchor,
            heightAnchor
        ])
        
        previousCalloutView = customCalloutView
        
        guard let placeAnnotation = view.annotation as? PlaceAnnotation,
              let metaData = placeAnnotation.place.photos?.first else {
            return
        }
        client.loadPlacePhoto(metaData) { [weak self] image, error in
            if let error = error {
                print("Error - loadPlacePhoto failed:\(error)")
                return
            }
            guard let self = self,
                  let image = image else { return }
            // Resize customCallOutView
            let newSize = self.getOptimalCalloutViewSize(image: image)
            widthAnchor.constant = newSize.width
            heightAnchor.constant = newSize.height
            
            customCalloutView.imageView.image = image
            customCalloutView.indicator.stopAnimating()
            self.updateInfoView(place: placeAnnotation.place)
        }
    }
    
    private func getOptimalCalloutViewSize(image: UIImage) -> CGSize {
        var newWidth: CGFloat!
        var newHeight: CGFloat!
        
        if image.size.width > image.size.height {
            newWidth = 200 * getHScale()
            newHeight = newWidth * image.size.height / image.size.width * getVScale()
        } else {
            newHeight = 200 * getVScale()
            newWidth = newHeight * image.size.width / image.size.height * getHScale()
        }
        return .init(width: newWidth, height: newHeight)
    }
}
