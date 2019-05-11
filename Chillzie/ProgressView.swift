//
//  ProgressView.swift
//
//  This is a conversion of customer progress bar originally from the following link
// http://zappdesigntemplates.com/cashapelayer-to-create-a-custom-progressbar/
//

import UIKit

class ProgressView: UIView, CAAnimationDelegate {
    
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    
    private var progressLabel: UILabel
    
    required init?(coder aDecoder: NSCoder) {
        progressLabel = UILabel()
        super.init(coder: aDecoder)
        createProgressLayer()
        createLabel()
    }
    
    override init(frame: CGRect) {
        progressLabel = UILabel()
        super.init(frame: frame)
        createProgressLayer()
        createLabel()
    }
    
    func createLabel() {
        progressLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: 60.0))
        progressLabel.textColor = .black
        progressLabel.textAlignment = .center
        progressLabel.text = "Coolzie"
        progressLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40.0)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: progressLabel, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: progressLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    private func createProgressLayer() {
        let startAngle = CGFloat(Double.pi/2)
        let endAngle = CGFloat(Double.pi*2 + Double.pi/2)
        let centerPoint = CGPoint(x: frame.width/2 , y: frame.height/2)
        
        let gradientMaskLayer = gradientMask()
        progressLayer.path = UIBezierPath(arcCenter:centerPoint, radius: frame.width/2 - 30.0, startAngle:startAngle, endAngle:endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        
        gradientMaskLayer.mask = progressLayer
        layer.addSublayer(gradientMaskLayer)
    }
    
    private func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        gradientLayer.locations = [0.0, 1.0]
        
        let colorTop: AnyObject = UIColor(red: 255.0/255.0, green: 213.0/255.0, blue: 63.0/255.0, alpha: 1.0).cgColor
        let colorBottom: AnyObject = UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 5.0/255.0, alpha: 1.0).cgColor
        let arrayOfColors: [AnyObject] = [colorTop, colorBottom]
        gradientLayer.colors = arrayOfColors
        
        return gradientLayer
    }
    
    func hideProgressView() {
        progressLayer.strokeEnd = 0.0
        progressLayer.removeAllAnimations()
        progressLabel.text = "Load content"
    }
    
    func animateProgressView(from: Double, to: Double, text: String) {
//        progressLabel.text = "Loading..."
        progressLabel.text = text
        progressLayer.strokeEnd = 0.0
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(from)
        animation.toValue = CGFloat(to)
        animation.duration = 0.25
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        progressLayer.add(animation, forKey: "strokeEnd")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //progressLabel.text = "Done"
    }
}
