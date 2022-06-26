import SwiftUI
import MapKit

struct MenuItem {
    let id = UUID() // If you have custom types in your array, you should use id with whatever property inside your type identifies it uniquely.
    let title: String
    let imageName: String
    let mapType: MKMapType
}

struct SlideMenuMapView: UIViewRepresentable {
    var mapType: MKMapType!
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = self.mapType
    }
    
    typealias UIViewType = MKMapView
}

struct SlideMenuView: View {
    @State var isMenuShowing = false
    @State var mapType = MKMapType.standard
    let items = [MenuItem(title: "Standard", imageName: "car", mapType: .standard),
                 MenuItem(title: "Hybrid", imageName: "antenna.radiowaves.left.and.right", mapType: .hybrid),
                 MenuItem(title: "Globe", imageName: "safari", mapType: .satelliteFlyover)]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                SlideMenuMapView(mapType: self.mapType)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button {
                            self.isMenuShowing.toggle()
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle.fill")
                                .font(.system(size: 34 * getHScale()))
                                .foregroundColor(Color.white)
                                .shadow(radius: 5 * getHScale())
                                .padding()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                
                Color(.init(white: 0, alpha: self.isMenuShowing ? 0.5 : 0))
                    .edgesIgnoringSafeArea(.all)
                    .animation(.spring())
                
                HStack {
                    ZStack { //用ZStack將Text置於Background View的中間
                        Color.white
                            .edgesIgnoringSafeArea(.all) //可以用Color當Background View
                        VStack {
                            HStack {
                                Text("Menu")
                                    .font(.system(size: 26 * getHScale(), weight: .bold))
                                    .padding()
                                Spacer()
                            }
                            HStack {
                                VStack(alignment: .leading, spacing: 30 * getVScale()) {
                                    ForEach(items, id: \.id) { item in
                                        Button {
                                            self.mapType = item.mapType
                                            self.isMenuShowing.toggle()
                                        } label: {
                                            HStack {
                                                Image(systemName: item.imageName)
                                                    .foregroundColor(Color.black)
                                                    .frame(width: 35 * getHScale(), height: 35 * getVScale())
                                                Text("\(item.title)")
                                                    .foregroundColor(Color.black)
                                                    .font(.system(size: 20 * getHScale()))
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            Spacer()
                        }
                    }
                    .frame(width: width / 2)
                    Spacer()
                }
                .offset(x: self.isMenuShowing ? 0 : -width / 2) //控制SlideMenu的位置
                .animation(.spring())
                .onTapGesture {
                    self.isMenuShowing.toggle()
                }
            }
        }
    }
}
