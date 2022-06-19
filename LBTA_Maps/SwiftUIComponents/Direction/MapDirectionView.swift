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
                            MapItemView(isSelecting: $environment.isSelectingSource, imageName: "start_location_circles", title: environment.sourceMapItem?.name ?? "起點")
                            MapItemView(isSelecting: $environment.isSelectingDestination, imageName: "annotation_icon", title: environment.destinationMapItem?.name ?? "終點")
                        }
                        .padding()
                        .background(Color.blue)
                        MapViewContainer_Direction()
                            .edgesIgnoringSafeArea(.bottom)
                    }
                    TopSafeAreaView()
                    ShowRoutesButton()
                    LoadingHud()
                }
                .navigationBarHidden(true)
            }
        }
    }
}

struct MapItemView: View {
    @Binding var isSelecting: Bool
    var imageName: String
    var title: String
    
    var body: some View {
        HStack(spacing: 16 * getHScale()) {
            Image(imageName)
                .renderingMode(.template)
                .foregroundColor(Color.white)
                .frame(width: 24 * getHScale(), height: 24 * getVScale())
            NavigationLink(destination: SelectLocationView(), isActive: $isSelecting) {
                HStack {
                    Text(title)
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(3 * getHScale())
            }
            .foregroundColor(Color.black)
        }

    }
}

struct TopSafeAreaView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                    .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top)
                    .background(Color.blue)
                    .edgesIgnoringSafeArea(.top)
                Spacer()
            }
        }
    }
}

struct LoadingHud: View {
    @EnvironmentObject var environment: DirectionEnvironment

    var body: some View {
        VStack(spacing: 15 * getVScale()) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.headline)
                .foregroundColor(Color.white)
        }
        .frame(width: 100, height: 100)
        .background(Color.black)
        .cornerRadius(8 * getHScale())
        .opacity(environment.isCalculatingRoute ? 1 : 0)
    }
}

struct ShowRoutesButton: View {
    @EnvironmentObject var environment: DirectionEnvironment
    @State var isShowingSheet = false
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                self.isShowingSheet = true
            } label: {
                Text("Show Route")
                    .foregroundColor(Color.white)
                    .frame(width: 300 * getHScale(), height: 50 * getVScale())
            .background(Color.black)
                    .cornerRadius(5 * getHScale())
            }
            Spacer()
                .frame(width: 25 * getHScale(), height: 25 * getVScale())
        }
        .sheet(isPresented: $isShowingSheet) { // Present VC In UIKit
            RouteInfoView(route: self.environment.route)
        }
    }
}

struct RouteInfoView: View {
    // route變數是RouteInfoView的dependency
    // 何謂dependency?
    // 車子依賴輪子才能上路, 如果一台車的設計太特殊, 特殊到只能用某廠牌的輪胎, 此時這台車子就會比較難維護
    // RouteInfoView則依賴route變數來運作
    // 換到軟體也是同樣的概念, 只是我們稱呼這種依賴叫做耦合, 耦合越高就會越難維護
    // A類別不應該直接依賴B類別, 而是使用protocol或class來實作多型, 降低依賴的程度
    // https://ithelp.ithome.com.tw/articles/10216539
    // https://stackoverflow.com/questions/2832017/what-is-the-difference-between-loose-coupling-and-tight-coupling-in-the-object-o
    //依賴注入透過外部控制dependency, 增加可測試性
    var route: MKRoute?
    var body: some View {
        ScrollView { // ScrollView + ForEach實作TableView比使用List簡單
            VStack {
                Text("Routes")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                ForEach(route?.steps ?? [], id: \.self) { step in
                    HStack {
                        Text("\(step.instructions)")
                        Spacer()
                        Text("\(String(format: "%.2f mi", step.distance * 0.00062137))")
                    }
                    .padding(.init(top: 15, leading: 15, bottom: 15, trailing: 15))
                }
            }
        }
    }
}
