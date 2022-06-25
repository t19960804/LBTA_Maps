import SwiftUI
import MapKit

struct SlideMenuMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    typealias UIViewType = MKMapView
}

struct SlideMenuView: View {
    @State var isMenuShowing = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                SlideMenuMapView()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button {
                            self.isMenuShowing.toggle()
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle.fill")
                                .font(.system(size: 34 * getHScale()))
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
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
                            Text("Menu")
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
