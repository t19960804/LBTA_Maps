import UIKit

class CarouselCell: UICollectionViewCell {
    static let cellId = "CarouselCell"

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 5 * getHScale()
        layer.shadowOffset = .init(width: 2, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
