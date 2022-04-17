import UIKit
import LBTATools
import MapKit

class RouteStepHeader: UIView {
    private let routeLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15 * getHScale()), textColor: .black, textAlignment: .left, numberOfLines: 1)
    private let distanceLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15 * getHScale()), textColor: .black, textAlignment: .left, numberOfLines: 1)
    private let estimateTimeLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15 * getHScale()), textColor: .black, textAlignment: .left, numberOfLines: 1)

    var route: MKRoute? {
        didSet {
            routeLabel.text = "路線:\(route!.name)"
            
            let mile = (route!.distance ) * 0.00062137
            let mileString = String(format: "%.2f 公里", mile)
            distanceLabel.text = "距離:\(mileString)"
            
            let travelTime = route!.expectedTravelTime //秒為單位
            if travelTime > 3600 {
                let h = Int(travelTime / 60 / 60)
                let m = Int((travelTime.truncatingRemainder(dividingBy: 60 * 60)) / 60)
                estimateTimeLabel.text = "預計時間:\(h)小時\(m)分鐘"
            } else {
                let m = Int(travelTime / 60)
                estimateTimeLabel.text = "預計時間:\(m)分鐘"
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(distanceLabel)
        distanceLabel.centerYToSuperview()
        distanceLabel.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 5 * getHScale(), bottom: 0, right: 10 * getHScale()), size: .zero)
        
        addSubview(routeLabel)
        routeLabel.anchor(top: nil, leading: leadingAnchor, bottom: distanceLabel.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 5 * getHScale(), bottom: 5 * getVScale(), right: 10 * getHScale()), size: .zero)
        
        addSubview(estimateTimeLabel)
        estimateTimeLabel.anchor(top: distanceLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 9, left: 5 * getHScale(), bottom: 0, right: 10 * getHScale()), size: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
