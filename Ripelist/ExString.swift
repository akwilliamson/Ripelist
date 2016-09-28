
import UIKit

extension String {
    
    public func validEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    public func validName() -> Bool {
        for char in characters {
            if (!(char >= "a" && char <= "z") && !(char >= "A" && char <= "Z")) {
                return false
            }
        }
        return true
    }
    
    public func validPassword() -> Bool {
        return self.characters.count >= 6 ? true : false
    }
    
}

extension NSMutableAttributedString {
    
    public func setAsLink(_ textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        
        return false
    }
    
}
