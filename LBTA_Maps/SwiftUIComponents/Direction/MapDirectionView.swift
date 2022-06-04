import SwiftUI
import MapKit

struct MapViewContainer_Direction: UIViewRepresentable {
    @EnvironmentObject var environment: DirectionEnvironment
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.lineWidth = 5
            return renderer
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let coordinate = CLLocationCoordinate2D(latitude: 25.051484378425634, longitude: 121.45624489204845)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        mapView.region = MKCoordinateRegion(center: coordinate, span: span)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        // compactMap > 去除陣列中的nil
        let noNilItems = [environment.sourceMapItem, environment.destinationMapItem].compactMap {$0}
        noNilItems.forEach { item in
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            uiView.addAnnotation(annotation)
        }
        uiView.showAnnotations(uiView.annotations, animated: true)
        if let route = environment.route {
            uiView.addOverlay(route.polyline)
        }
    }
    
    typealias UIViewType = MKMapView
    
    
}

struct MapDirectionView: View {
    @EnvironmentObject var environment: DirectionEnvironment
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    VStack(spacing: 0) {
                        VStack {
                            HStack(spacing: 16 * getHScale()) {
                                Image("start_location_circles")
                                    .frame(width: 24 * getHScale(), height: 24 * getVScale())
                                NavigationLink(destination: SelectLocationView(), isActive: $environment.isSelectingSource) {
                                    HStack {
                                        Text(environment.sourceMapItem?.name ?? "起點")
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(3 * getHScale())
                                }
                                .foregroundColor(Color.black)
                            }
                            HStack(spacing: 16 * getHScale()) {
                                Image("annotation_icon")
                                    .renderingMode(.template)
                                    .foregroundColor(Color.white)
                                    .frame(width: 24 * getHScale(), height: 24 * getVScale())
                                NavigationLink(destination: SelectLocationView(), isActive: $environment.isSelectingDestination) {
                                    HStack {
                                        Text(environment.destinationMapItem?.name ?? "終點")
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(3 * getHScale())
                                }
                                .foregroundColor(Color.black)
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        MapViewContainer_Direction()
                            .edgesIgnoringSafeArea(.bottom)
                    }
                    //Safe Area Top View
                    VStack {
                        Spacer()
                            .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top)
                            .background(Color.blue)
                            .edgesIgnoringSafeArea(.top)
                        Spacer()
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}
