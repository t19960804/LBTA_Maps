import UIKit
import LBTATools
import MapKit
import SwiftUI
import Combine

class LocationSearchVC: UIViewController {
    var selectLocationHandler: ((MKMapItem) -> Void)?
    
    private let headerContainer = UIView(backgroundColor: .white)
    private let searchTextField = IndentedTextField(placeholder: "Search Query", padding: 12 * getHScale(), cornerRadius: 5)
    private lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.register(LocationSearchCell.self, forCellReuseIdentifier: LocationSearchCell.cellId)
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    private var mapItems = [MKMapItem]()
    private var searchTextFieldSubscriber: AnyCancellable?
    private var term = ""
    
    init(term: String) {
        super.init(nibName: nil, bundle: nil)
        self.term = term
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupTableView()
        searchLocation(term: term)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchTextFieldSubscriber()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextFieldSubscriber?.cancel()
    }
    
    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)
        headerContainer.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -60 * getVScale(), right: 0))
        
        let backButton = UIButton(title: "Back", titleColor: .black)
        backButton.titleLabel?.font = .systemFont(ofSize: 18 * getHScale())
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        headerContainer.addSubview(backButton)
        backButton.anchor(top: nil, leading: headerContainer.leadingAnchor, bottom: headerContainer.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 14 * getHScale(), bottom: 15 * getVScale(), right: 0), size: .init(width: 60, height: 0))
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.text = term
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.becomeFirstResponder()
        headerContainer.addSubview(searchTextField)
        NSLayoutConstraint.activate([
            searchTextField.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10 * getHScale()),
            searchTextField.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -10 * getHScale()),
            searchTextField.heightAnchor.constraint(equalToConstant: 50 * getVScale())
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.anchor(top: headerContainer.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .zero, size: .zero)
    }
    
    private func setupSearchTextFieldSubscriber() {
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
        searchTextFieldSubscriber = publisher
            .map { ($0.object as? UITextField)?.text ?? "" }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.searchLocation(term: $0)
            }
    }
    
    private func searchLocation(term: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
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
    
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
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
