import UIKit
import MapKit

class CarouselCell: UICollectionViewCell {
    static let cellId = "CarouselCell"
    
    private let nameLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15 * getHScale()), textColor: .black, textAlignment: .left, numberOfLines: 1)
    private let addressLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15 * getHScale()), textColor: .lightGray, textAlignment: .left, numberOfLines: 2)
    private let coordinateLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 11 * getHScale()), textColor: .lightGray, textAlignment: .left, numberOfLines: 1)
    
    var mapItem: MKMapItem! {
        didSet {
            nameLabel.text = mapItem.name
        
            let placemark = mapItem.placemark
            addressLabel.text = placemark.addressString
            
            coordinateLabel.text = "\(placemark.coordinate.longitude), \(placemark.coordinate.latitude)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 5 * getHScale()
        layer.shadowOffset = .init(width: 2, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
        
        nameLabel.adjustsFontSizeToFitWidth = true
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 15 * getVScale(), left: 12 * getHScale(), bottom: 0, right: 12 * getHScale()))
        
        addSubview(addressLabel)
        addressLabel.anchor(top: nameLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 15 * getVScale(), left: 12 * getHScale(), bottom: 0, right: 12 * getHScale()))
        
        coordinateLabel.adjustsFontSizeToFitWidth = true
        addSubview(coordinateLabel)
        coordinateLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 12 * getHScale(), bottom: 15 * getVScale(), right: 12 * getHScale()))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
