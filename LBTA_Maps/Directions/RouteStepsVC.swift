import UIKit
import MapKit

class RouteStepsVC: UITableViewController {
    private var route: MKRoute!
    
    init(route: MKRoute) {
        super.init(nibName: nil, bundle: nil)
        self.route = route
        print(route.steps.count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(RouteStepCell.self, forCellReuseIdentifier: RouteStepCell.cellId)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return route.steps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: RouteStepCell.cellId, for: indexPath) as! RouteStepCell
        let step = route.steps[indexPath.item]
        cell.step = step
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 * getVScale()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = RouteStepHeader()
        header.route = self.route
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80 * getVScale()
    }
}
