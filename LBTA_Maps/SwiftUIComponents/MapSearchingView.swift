import SwiftUI
import MapKit

// UIViewRepresentable > 將UIKit的View做包裝, 讓這個View可以放在SwiftUI裡面
struct MapViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    typealias UIViewType = MKMapView
}
struct MapSearchingView: View {
    var body: some View {
        ZStack(alignment: .top){ // 後面產生的元件將疊在之前的元件身上
            MapViewContainer()
                .edgesIgnoringSafeArea(.all)
            HStack {
                Button {
                    print("123")
                } label: {
                    Text("Search for airports")
                        .padding()
                        .background(Color.white)
                }
                
                Button {
                    
                } label: {
                    Text("Clear Annotations")
                        .padding()
                        .background(Color.white)
                }
            }
            .shadow(radius: 3)
        }
    }
}

struct MapSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchingView()
    }
}
