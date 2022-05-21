import SwiftUI
import MapKit
import Combine

// UIViewRepresentable > 將UIKit的View做包裝, 讓這個View可以放在SwiftUI裡面
struct MapViewContainer: UIViewRepresentable {
    var annotations = [MKPointAnnotation]()
    var selectedMapItem: MKMapItem?
    
    //若要在SwiftUI實作UIKit當中的delegate, 需要使用Coordinator
    //Coordinator > 協調者, 協調SwiftUI與UIKit之間的delegate
    //僅建立Coordinator class還不夠, 還需要實作.makeCoordinator()
    //兩個條件完成後, SwiftUI才會自動呼叫.makeCoordinator()來使用Coordinator class
    //https://www.hackingwithswift.com/books/ios-swiftui/using-coordinators-to-manage-swiftui-view-controllers
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            view.canShowCallout = true
            return view
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let coordinate = CLLocationCoordinate2D(latitude: 25.0475613, longitude: 121.5173399)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        if annotations.isEmpty == false {
            uiView.addAnnotations(annotations)
            uiView.showAnnotations(annotations, animated: true)
        }
        if let item = selectedMapItem {
            annotations.forEach {
                if $0.title == item.name {
                    uiView.selectAnnotation($0, animated: true)
                }
            }
        }
    }
    
    typealias UIViewType = MKMapView
}

// Brian > Keep track of properties that your view needs to render
// ViewModel > 將fetch資料的code從SwiftUI View抽離出來, 因為SwiftUI View只負責"呈現"以及提供使用者"操作"
class MapSearchingViewModel: ObservableObject {
    // @State > 只要變數被改變, SwiftUI就會自動更新有使用到此變數的UI
    @Published var mapItems = [MKMapItem]()
    @Published var annotations = [MKPointAnnotation]()
    @Published var isSearching = false
    @Published var searchQuery = ""
    @Published var selectedMapItem: MKMapItem?
    
    private var searQuerySubscription: AnyCancellable?
    
    init() {
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

}
struct MapSearchingView: View {
    // 如果要觀察的是基本型別, 例如Int, Bool..., 可以使用 @State
    // 如果要觀察的是一個class裡面的基本型別, 可以使用 @ObservedObject, 但是class要服從ObservableObject協議, 且裡面基本型別的屬性要使用 @Published
    // 在iOS14時推出 @StateObject來取代 @ObservedObject, 因為 @ObservedObject有Bug
    // 詳情請見 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E6%95%99%E5%AE%A4/10-observedobject%E7%9A%84%E4%BD%BF%E7%94%A8-187eb99d86bb
    @StateObject var vm = MapSearchingViewModel()
    
    var body: some View {
        ZStack(alignment: .top){ // 後面產生的元件將疊在之前的元件身上
            MapViewContainer(annotations: vm.annotations, selectedMapItem: vm.selectedMapItem)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 12 * getHScale()) {
                HStack {
                    TextField("Search terms", text: $vm.searchQuery)
                        .padding()
                        .background(Color.white)
                }
                .padding()
                
                Text(vm.isSearching ? "Searching..." : "")
                
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 16 * getHScale()) {
                        ForEach(vm.mapItems, id: \.self) { item in
                            Button {
                                vm.selectedMapItem = item
                            } label: {
                                VStack(alignment: .leading, spacing: 4 * getVScale()) {
                                    Text(item.name ?? "")
                                        .font(.headline)
                                    Text(item.placemark.title ?? "")
                                }
                            }
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 200 * getHScale(), height: 100 * getVScale())
                            .background(Color.white)
                            .cornerRadius(5 * getHScale())
                        }
                    }
                    .padding(.horizontal, 16 * getHScale())
                }
                .shadow(radius: 5)
            }
            
        }
    }
}

struct MapSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchingView()
    }
}
