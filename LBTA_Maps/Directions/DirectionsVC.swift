import UIKit
import SwiftUI
import MapKit
import LBTATools
import JGProgressHUD

class DirectionsVC: UIViewController {
    private let locationManager = CLLocationManager()

    private let navBarView = UIView()
    private let mapView = MKMapView()
    private let startTextField = IndentedTextField(placeholder: "", padding: 12 * getHScale(), cornerRadius: 5)
    private let endTextField = IndentedTextField(placeholder: "", padding: 12 * getHScale(), cornerRadius: 5)
    
    private var startMapItem: MKMapItem?
    private var endMapItem: MKMapItem?
    private var currentRoute: MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        getUserLocation()
        setupNavBar()
        setupMapView()
        setupRouteButton()
    }
    
    private func getUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    private func setupNavBar() {
        mapView.showsUserLocation = true
        view.addSubview(navBarView)
        navBarView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -100 * getVScale(), right: 0))
        navBarView.backgroundColor = UIColor(red: 51/255, green: 153/255, blue: 1, alpha: 1)
        navBarView.setupShadow(opacity: 0.5, radius: 5)
        
        let startImageView = UIImageView(image: UIImage(named: "start_location_circles"))
        startImageView.contentMode = .scaleAspectFit
        startImageView.translatesAutoresizingMaskIntoConstraints = false
        navBarView.addSubview(startImageView)
        NSLayoutConstraint.activate([
            startImageView.heightAnchor.constraint(equalToConstant: 20 * getVScale()),
            startImageView.widthAnchor.constraint(equalToConstant: 20 * getHScale()),
            startImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15 * getVScale()),
            startImageView.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 20 * getHScale())
        ])
        
        let startTap = UITapGestureRecognizer(target: self, action: #selector(handleTapStartTextField)) //不可以兩個TextField使用同一個Tap, 所以要分Start / EndTap
        startTextField.attributedPlaceholder = .init(string: "Start", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        startTextField.textColor = .white
        startTextField.translatesAutoresizingMaskIntoConstraints = false
        startTextField.backgroundColor = UIColor(white: 1, alpha: 0.3)
        startTextField.addGestureRecognizer(startTap)
        navBarView.addSubview(startTextField)
        NSLayoutConstraint.activate([
            startTextField.heightAnchor.constraint(equalToConstant: 34 * getVScale()),
            startTextField.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor, constant: -20 * getHScale()),
            startTextField.centerYAnchor.constraint(equalTo: startImageView.centerYAnchor),
            startTextField.leadingAnchor.constraint(equalTo: startImageView.trailingAnchor, constant: 20 * getHScale())
        ])
        
        let endImageView = UIImageView(image: UIImage(named: "annotation_icon")?.withRenderingMode(.alwaysTemplate))
        endImageView.tintColor = .white
        endImageView.contentMode = .scaleAspectFit
        endImageView.translatesAutoresizingMaskIntoConstraints = false
        navBarView.addSubview(endImageView)
        NSLayoutConstraint.activate([
            endImageView.heightAnchor.constraint(equalToConstant: 20 * getVScale()),
            endImageView.widthAnchor.constraint(equalToConstant: 20 * getHScale()),
            endImageView.topAnchor.constraint(equalTo: startImageView.bottomAnchor, constant: 25 * getVScale()),
            endImageView.leadingAnchor.constraint(equalTo: startImageView.leadingAnchor)
        ])
        
        let endTap = UITapGestureRecognizer(target: self, action: #selector(handleTapEndTextField))
        endTextField.attributedPlaceholder = .init(string: "End", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        endTextField.textColor = .white
        endTextField.translatesAutoresizingMaskIntoConstraints = false
        endTextField.backgroundColor = UIColor(white: 1, alpha: 0.3)
        endTextField.addGestureRecognizer(endTap)
        navBarView.addSubview(endTextField)
        NSLayoutConstraint.activate([
            endTextField.heightAnchor.constraint(equalTo: startTextField.heightAnchor),
            endTextField.trailingAnchor.constraint(equalTo: startTextField.trailingAnchor),
            endTextField.centerYAnchor.constraint(equalTo: endImageView.centerYAnchor),
            endTextField.leadingAnchor.constraint(equalTo: startTextField.leadingAnchor)
        ])
    }
    
    @objc private func handleTapStartTextField() {
        let vc = LocationSearchVC(term: startTextField.text ?? "")
        vc.selectLocationHandler = { mapItem in
            if let previousMapItem = self.startMapItem {
                self.removeAnnotationFromMap(item: previousMapItem)
            }
            self.startMapItem = mapItem
            self.startTextField.text = mapItem.name
            self.addAnnotationAndRequestRoute(item: self.startMapItem!)
        }
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc private func handleTapEndTextField() {
        let vc = LocationSearchVC(term: endTextField.text ?? "")
        vc.selectLocationHandler = { mapItem in
            if let previousMapItem = self.endMapItem {
                self.removeAnnotationFromMap(item: previousMapItem)
            }
            self.endMapItem = mapItem
            self.endTextField.text = mapItem.name
            self.addAnnotationAndRequestRoute(item: self.endMapItem!)
        }
        navigationController!.pushViewController(vc, animated: true)
    }
    
    private func removeAnnotationFromMap(item: MKMapItem) {
        for annotation in mapView.annotations {
            if annotation.title == item.name {
                mapView.removeAnnotation(annotation)
                mapView.removeOverlays(mapView.overlays)
                break
            }
        }
    }
    
    private func addAnnotationAndRequestRoute(item: MKMapItem) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        annotation.title = item.name
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
        requestRoute()
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupMapView() {
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.anchor(top: navBarView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    private func setupRouteButton() {
        let routeButton = UIButton(title: "Route", titleColor: .black, font: .boldSystemFont(ofSize: 15 * getHScale()), backgroundColor: .white, target: self, action: #selector(presentRouteStepsVC))
        mapView.addSubview(routeButton)
        routeButton.anchor(top: nil, leading: mapView.leadingAnchor, bottom: mapView.bottomAnchor, trailing: mapView.trailingAnchor, padding: .init(top: 0, left: 10 * getHScale(), bottom: 10 * getHScale(), right: 10 * getHScale()), size: .init(width: 0, height: 50))
    }
    
    @objc private func presentRouteStepsVC() {
        guard let currentRoute = currentRoute else {
            print("Error - currentRoute is nil")
            return
        }
        let vc = RouteStepsVC(route: currentRoute)
        present(vc, animated: true)
    }
    
    private func requestRoute() {
        guard let startMapItem = self.startMapItem,
              let endMapItem = self.endMapItem else {
            print("Error - There is no two locations to request route")
            return
        }
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Routing..."
        hud.show(in: view, animated: true)
        
        let request = MKDirections.Request()
        request.source = startMapItem
        request.destination = endMapItem
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Error - Calculate directions failed:\(error)")
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                hud.textLabel.text = "Routing Failed!"
                hud.detailTextLabel.text = error.localizedDescription
                hud.dismiss(afterDelay: 2, animated: true)
                return
            }
            print("Info - Success calculate routes")
            // Multiple Routes
//            response?.routes.forEach{ route in
//                self.mapView.addOverlay(route.polyline)
//            }
            // Single Route
            if let route = response?.routes.first {
                self.mapView.addOverlay(route.polyline)
                self.currentRoute = route
            }
            hud.dismiss(animated: true)
        }
    }
}

struct DirectionsVCPreview: PreviewProvider {
    static var previews: some View {
       ContainerView()
            .edgesIgnoringSafeArea(.all)
            .environment(\.colorScheme, .light)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> DirectionsVC {
            return DirectionsVC()
        }
        
        func updateUIViewController(_ uiViewController: DirectionsVC, context: Context) {
            
        }
        
        typealias UIViewControllerType = DirectionsVC
        
    }
}

extension DirectionsVC: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let accuracy = manager.accuracyAuthorization // iOS 14 為 CoreLocation 框架帶來了一點改變，使用者可以選擇要給予準確或大概的位置存取。
        print("Authorization DidChange accuracy:\(accuracy.rawValue), status:\(manager.authorizationStatus.rawValue)")
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .restricted:
            // Get Coordinate Of User
            locationManager.startUpdatingLocation()
        case .denied:
            break
        case .notDetermined:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else {
            return
        }
        //如果span值太小, 導致地圖太精細, showAnnotations會沒作用, 因為無法要求地圖在精細的情況下又要顯示所有Annotations
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation() // Save Battrey Power
    }
}

extension DirectionsVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 51/255, green: 153/255, blue: 1, alpha: 1)
        renderer.lineWidth = 5
        return renderer
    }
}
