import SwiftUI
import Combine
import MapKit

// Brian > Keep track of properties that your view needs to render
// ViewModel > 將fetch資料的code從SwiftUI View抽離出來, 因為SwiftUI View只負責"呈現"以及提供使用者"操作"
class MapSearchingViewModel: NSObject, ObservableObject {
    // @State > 只要變數被改變, SwiftUI就會自動更新有使用到此變數的UI
    @Published var mapItems = [MKMapItem]()
    @Published var annotations = [MKPointAnnotation]()
    @Published var isSearching = false
    @Published var searchQuery = ""
    @Published var selectedMapItem: MKMapItem?
    @Published var currentUserCoordinate: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()

    private var searQuerySubscription: AnyCancellable?
    
    override init() {
        super.init()
        getUserLocation()
        searQuerySubscription = $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchTerm in
                guard let self = self else { return }
                self.performSearch(term: searchTerm)
            }
    }
    
    deinit {
        searQuerySubscription?.cancel()
    }
    
    fileprivate func performSearch(term: String) {
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            self.isSearching = false
            if let error = error {
                print("Error - Find Nearby LandMark Fail:\(error)")
                return
            }
            var airportAnnotations = [MKPointAnnotation]()
            response?.mapItems.forEach {
                let annotaion = MKPointAnnotation()
                annotaion.title = $0.name
                annotaion.coordinate = $0.placemark.coordinate
                airportAnnotations.append(annotaion)
            }
            self.mapItems = response?.mapItems ?? []
            self.annotations = airportAnnotations
        }
    }
    
    private func getUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
}

extension MapSearchingViewModel: CLLocationManagerDelegate {
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
        currentUserCoordinate = firstLocation.coordinate
        locationManager.stopUpdatingLocation() // Save Battrey Power
    }
}
