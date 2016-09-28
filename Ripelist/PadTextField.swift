
import UIKit

class PadTextField: UITextField {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        layer.cornerRadius = 3
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: frame.height))
        textColor = UIColor.darkGray
        leftViewMode = .always
        font = UIFont(name: "ArialRoundedMTBold", size: 20)
        backgroundColor = UIColor.white
        autocorrectionType = .no
        spellCheckingType = .no
    }
    
    func fadePlaceholder(_ duration: CFTimeInterval, text: String) {
        
        let animation: CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        
        self.layer.add(animation, forKey: kCATransitionFade)
        self.placeholder = text
    }
}
