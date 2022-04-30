import UIKit
import LBTATools

class CustomCalloutView: UIView {
    let indicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 2 * getHScale()
        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        layer.cornerRadius = 5
        clipsToBounds = true
        
        indicator.color = .black
        addSubview(indicator)
        indicator.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
