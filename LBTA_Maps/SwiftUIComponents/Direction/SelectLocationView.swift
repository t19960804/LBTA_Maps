import SwiftUI
import MapKit
import Combine

struct SelectLocationView: View {
    @State var mapItems = [MKMapItem]()
    @State var searchQuery = ""
    @EnvironmentObject var environment: DirectionEnvironment
    
    var body: some View {
        VStack {
            HStack(spacing: 16 * getHScale()) {
                Button {
                    backButtonPressed()
                } label: {
                    Text("Back")
                }
                TextField("Enter search term", text: $searchQuery)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)
                        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)) { _ in
                            let request = MKLocalSearch.Request()
                            request.naturalLanguageQuery = searchQuery
                            let search = MKLocalSearch(request: request)
                            search.start { response, error in
                                if let error = error {
                                    print("Error - Search Failed:\(error)")
                                    return
                                }
                                self.mapItems = response?.mapItems ?? []
                            }
                    }
            }
            .padding()

            //當參數 data 傳入 array 時，我們需要額外設定型別 KeyPath 的參數 id。此 id 將設定 array 成員的 id，到時候 ForEach 將利用 id 區分 array 裡的成員。
            //在此我們傳入 \.self，表示 array 成員自己就是 id
            //\.self > Swift KeyPath
            //https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/swiftui-%E7%9A%84-foreach-7ccd426e53ac
            ScrollView {
                ForEach(mapItems, id: \.self) { item in
                    Button {
                        if environment.isSelectingSource {
                            environment.sourceMapItem = item
                        } else {
                            environment.destinationMapItem = item
                        }
                        backButtonPressed()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(item.name ?? "")")
                                    .font(.headline)
                                Text("\(item.placemark.addressString)")
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .foregroundColor(Color.black)
                }
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
    
    func backButtonPressed() {
        environment.isSelectingSource = false
        environment.isSelectingDestination = false
    }
}

class DirectionEnvironment: ObservableObject { // View之間的Share Data, 一邊改動, 另一邊讀取
    @Published var sourceMapItem: MKMapItem?
    @Published var destinationMapItem: MKMapItem?
    @Published var isSelectingSource = false
    @Published var isSelectingDestination = false
    @Published var route: MKRoute?
    @Published var isCalculatingRoute = false
    
    var routeSubscriber: AnyCancellable?
    
    init() {
        // 監聽sourceMapItem / destinationMapItem的改變
        // CombineLatest > 一旦所有Publisher發佈過後, 才會發佈第一次, 而後續只要任一Publisher發佈, 就會將所有Publisher最新的元素組合發佈.
        //https://developer.apple.com/documentation/combine/publisher/combinelatest(_:_:)-5crqg
        routeSubscriber = Publishers.CombineLatest($sourceMapItem, $destinationMapItem)
            .sink { [weak self] items in
                guard let self = self,
                      let source = items.0,
                      let destination = items.1 else { return }
                self.requestRoute(source, destination)
            }
    }
    
    deinit {
        routeSubscriber?.cancel()
    }
    
    private func requestRoute(_ source: MKMapItem, _ destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        let directions = MKDirections(request: request)
        isCalculatingRoute = true
        route = nil
        directions.calculate { response, error in
            self.isCalculatingRoute = false
            if let error = error {
                print("Error - Calculate directions failed:\(error)")
                return
            }
            print("Info - Success calculate routes")
            self.route = response?.routes.first
        }
    }
}
