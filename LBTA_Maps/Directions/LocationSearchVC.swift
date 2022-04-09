import UIKit
import LBTATools
import MapKit

class LocationSearchVC: UIViewController {
    var selectLocationHandler: ((MKMapItem) -> Void)?
    
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.register(LocationSearchCell.self, forCellReuseIdentifier: LocationSearchCell.cellId)
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    var mapItems = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        searchLocation()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    private func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Apple"
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            if let error = error {
                print("Error - Find Nearby LandMark Fail:\(error)")
                return
            }
            self.mapItems = response?.mapItems ?? []
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationSearchCell.cellId, for: indexPath) as! LocationSearchCell
        let item = mapItems[indexPath.item]
        cell.item = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 * getVScale()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = mapItems[indexPath.item]
        selectLocationHandler?(item)
        navigationController?.popViewController(animated: true)
    }
}
