import SwiftUI
import MapKit

struct SelectLocationView: View {
    //@Binding > 參考Parent View的資料源, 以及將Child View內部對資料源的操作反饋到Parent View, 避免Parent and Child之間的資料不同步
    //以後看到某個View要傳入的參數為Binding類別, 就代表內部有屬性使用 @Binding, 目的是要讓資料同步
    @Binding var isSelecting: Bool
    @State var mapItems = [MKMapItem]()
    @State var searchQuery = ""
    
    var body: some View {
        VStack {
            HStack(spacing: 16 * getHScale()) {
                Button {
                    isSelecting = false
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
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
}
