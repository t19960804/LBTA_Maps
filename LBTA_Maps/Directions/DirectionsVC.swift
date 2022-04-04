import UIKit
import SwiftUI
import MapKit
import LBTATools

class DirectionsVC: UIViewController {
    private let locationManager = CLLocationManager()

    private let navBarView = UIView()
    private let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
        setupNavBar()
        setupMapView()
        setupStartEndAnnotations()
        requestRoute()
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
    }
    
    private func setupMapView() {
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.anchor(top: navBarView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    private func setupStartEndAnnotations() {
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = .init(latitude: 25.03624844630123, longitude: 121.45272364546625)
        startAnnotation.title = "新莊國中"
        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = .init(latitude: 25.051814842654544, longitude: 121.45680279149116)
        endAnnotation.title = "昌隆國小"
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
        mapView.showAnnotations(mapView.annotations, animated: true) //如果span值太小, 導致地圖太精細, showAnnotations會沒作用, 因為無法要求地圖在精細的情況下又要顯示所有Annotations
    }
    
    private func requestRoute() {
        let request = MKDirections.Request()
        
        let startPlacemark = MKPlacemark(coordinate: .init(latitude: 25.03624844630123, longitude: 121.45272364546625))
        request.source = MKMapItem(placemark: startPlacemark)
        
        let endPlacemark = MKPlacemark(coordinate: .init(latitude: 25.051814842654544, longitude: 121.45680279149116))
        request.destination = MKMapItem(placemark: endPlacemark)
        
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Error - Calculate directions failed:\(error)")
                return
            }
            print("Info - Success calculate routes")
//            guard let route = response?.routes.first else { return }
//            print(route.expectedTravelTime / 3600)
            response?.routes.forEach{ route in
                self.mapView.addOverlay(route.polyline)
            }
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
