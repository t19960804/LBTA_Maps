import UIKit
import MapKit
import LBTATools
import Combine

func getHScale() -> CGFloat {
    let screenSize = UIScreen.main.bounds
    let width = screenSize.width
    return width / 375
}
func getVScale() -> CGFloat {
    let screenSize = UIScreen.main.bounds
    let height = screenSize.height
    return height / 667
}

class MapController: UIViewController {
    private let mapView = MKMapView()
    private let searchTextField = UITextField(placeholder: "Search Query")

    private var searchTextFieldSubscriber: AnyCancellable?
    private var mapItems = [MKMapItem]()
    private lazy var caroselView: UICollectionView = {
        let layout = getCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
        setupMapView()
        setupSearchBar()
        setupCarouselView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchTextFieldSubscriber()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //findNearbyLandmark(term: "國中")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextFieldSubscriber?.cancel()
    }
    
    private func getUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.fillSuperview()
    }
    
    private func setupSearchBar() {
        let searchContainer = UIView(backgroundColor: .white)
        searchContainer.layer.cornerRadius = 5 * getHScale()
        view.addSubview(searchContainer)
        searchContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16 * getHScale(), bottom: 0, right: 16 * getHScale()), size: .init(width: 0, height: 50 * getVScale()))
        
        searchContainer.addSubview(searchTextField)
        searchTextField.anchor(top: searchContainer.topAnchor, leading: searchContainer.leadingAnchor, bottom: searchContainer.bottomAnchor, trailing: searchContainer.trailingAnchor, padding: .init(top: 8 * getVScale(), left: 8 * getHScale(), bottom: 8 * getVScale(), right: 8 * getHScale()), size: .init(width: 0, height: 0))
    }
    
    private func setupCarouselView() {
        view.addSubview(caroselView)
        caroselView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .zero, size: .init(width: 0, height: 150 * getVScale()))
    }
    
    private func getCompositionalLayout() -> UICollectionViewLayout {
        // NSCollectionLayoutDimension 的 absolute 可指定固定的大小 ; fractional可指定相對於外層Container的比例大小
        // NSCollectionLayoutGroup 的 horizontal 將讓 group 裡的 item 沿著水平方向排列
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                             heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 10 * getHScale())
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8),
                                              heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 0, leading: 16 * getHScale(), bottom: 0, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
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
            self.mapItems = response?.mapItems ?? []
            self.caroselView.reloadData()
            self.caroselView.scrollToItem(at: [0,0], at: .left, animated: true)
        }
    }
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            view.canShowCallout = true
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let title = view.annotation?.title
        if let index = mapItems.firstIndex(where: { $0.name == title }) {
            caroselView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
        }
    }
}

extension MapController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mapItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.cellId, for: indexPath) as! CarouselCell
        cell.mapItem = mapItems[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mapView.annotations.forEach {
            if $0.title == mapItems[indexPath.item].name {
                mapView.selectAnnotation($0, animated: true)
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                return
            }
        }
    }
}

extension MapController: CLLocationManagerDelegate {
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
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation() // Save Battrey Power
    }
}
