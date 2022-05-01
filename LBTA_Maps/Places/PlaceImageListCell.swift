import UIKit
import LBTATools

class PlaceImageListCell: UICollectionViewCell {
    static let cellId = "PlaceImageListCell"
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(imageView)
        imageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
