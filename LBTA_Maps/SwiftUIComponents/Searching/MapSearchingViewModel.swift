import SwiftUI
import Combine
import MapKit

// Brian > Keep track of properties that your view needs to render
// ViewModel > 將fetch資料的code從SwiftUI View抽離出來, 因為SwiftUI View只負責"呈現"以及提供使用者"操作"
class MapSearchingViewModel: NSObject, ObservableObject {
    // @State / @Published> 只要變數被改變, SwiftUI就會自動更新有使用到此變數的UI
    // 如果要觀察的是基本型別, 例如Int, Bool..., 使用 @State
    // 如果要觀察的是一個class裡面的基本型別, 可以使用 @ObservedObject, 但是class要服從ObservableObject協議, 裡面基本型別要使用 @Published
    // 在iOS14時推出 @StateObject來取代 @ObservedObject, 因為 @ObservedObject有Bug
    // 詳情請見 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E6%95%99%E5%AE%A4/10-observedobject%E7%9A%84%E4%BD%BF%E7%94%A8-187eb99d86bb
    @Published var mapItems = [MKMapItem]()
    @Published var annotations = [MKPointAnnotation]()
    @Published var isSearching = false
    @Published var searchQuery = ""
    @Published var selectedMapItem: MKMapItem?
    @Published var currentUserCoordinate: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()

    private var searQuerySubscription: AnyCancellable?
    private var currentUserRegion: MKCoordinateRegion?
    
    override init() {
        super.init()
        getUserLocation()
        setupNotification()
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
        if let region = self.currentUserRegion {
            request.region = region
        }
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
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(forName: NotificationCenter.regionNotification, object: nil, queue: .main) { notification in
            if let region = notification.userInfo?["currentUserRegion"] as? MKCoordinateRegion {
                self.currentUserRegion = region
            }
        }
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
