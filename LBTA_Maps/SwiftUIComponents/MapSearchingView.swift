import SwiftUI
import MapKit

// UIViewRepresentable > 將UIKit的View做包裝, 讓這個View可以放在SwiftUI裡面
struct MapViewContainer: UIViewRepresentable {
    var annotations = [MKPointAnnotation]()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
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
    }
    
    typealias UIViewType = MKMapView
}
struct MapSearchingView: View {
    // 只要 @State變數 被改變, SwiftUI就會自動更新有使用到此變數的UI
    // 若沒有這個機制, 很有可能變數更新了, 但是忘記更新UI
    // 不然就是要額外的寫UI更新的function
    @State var annotations = [MKPointAnnotation]()
    
    var body: some View {
        ZStack(alignment: .top){ // 後面產生的元件將疊在之前的元件身上
            MapViewContainer(annotations: annotations)
                .edgesIgnoringSafeArea(.all)
            HStack {
                Button {
                    performSearch(term: "Airports")
                } label: {
                    Text("Search for airports")
                        .padding()
                        .background(Color.white)
                }
                
                Button {
                    annotations = []
                } label: {
                    Text("Clear Annotations")
                        .padding()
                        .background(Color.white)
                }
            }
            .shadow(radius: 3)
        }
    }
    
    private func performSearch(term: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
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
            annotations = airportAnnotations
        }
    }
}

struct MapSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchingView()
    }
}
