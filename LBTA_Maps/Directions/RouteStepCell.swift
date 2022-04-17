import UIKit
import MapKit

class RouteStepCell: UITableViewCell {
    static let cellId = "RouteStepCell"
    
    private let titleLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15 * getHScale()), textColor: .black, textAlignment: .left, numberOfLines: 0)
    private let distanceLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15 * getHScale()), textColor: .lightGray, textAlignment: .right, numberOfLines: 2)
    
    var step: MKRoute.Step? {
        didSet {
            titleLabel.text = step?.instructions
            let mile = (step?.distance ?? 0) * 0.00062137
            distanceLabel.text = String(format: "%.2f 公里", mile)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        distanceLabel.adjustsFontSizeToFitWidth = true
        addSubview(distanceLabel)
        distanceLabel.anchor(top: topAnchor, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 8 * getVScale(), left: 0, bottom: 8 * getVScale(), right: 8 * getHScale()), size: .init(width: 80 * getHScale(), height: 0))
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: distanceLabel.leadingAnchor, padding: .init(top: 8 * getVScale(), left: 8 * getHScale(), bottom: 8 * getVScale(), right: 10 * getHScale()))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
