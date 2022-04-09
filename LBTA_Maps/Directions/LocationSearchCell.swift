import UIKit
import MapKit
import LBTATools

class LocationSearchCell: UITableViewCell {
    static let cellId = "LocationSearchCell"
    
    var item: MKMapItem? {
        didSet {
            titleLabel.text = item?.name
            subTitleLabel.text = item?.placemark.addressString
        }
    }
    
    let titleLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15 * getHScale()), textColor: .black, textAlignment: .left, numberOfLines: 1)
    let subTitleLabel = UILabel(text: "", font: .systemFont(ofSize: 12 * getHScale()), textColor: .darkGray, textAlignment: .left, numberOfLines: 1)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10 * getVScale()),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10 * getHScale()),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10 * getHScale())
        ])
        
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subTitleLabel)
        NSLayoutConstraint.activate([
            subTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10 * getVScale()),
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10 * getHScale()),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10 * getHScale())
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
