import SwiftUI

struct MapPreview: PreviewProvider {
    static var previews: some View {
       ContainerView()
            .edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> MapController {
            return MapController()
        }
        
        func updateUIViewController(_ uiViewController: MapController, context: Context) {
            
        }
        
        typealias UIViewControllerType = MapController
        
    }
}
