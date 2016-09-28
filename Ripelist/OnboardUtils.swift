
enum FBPermission: String {
    
    case PublicProfile = "public_profile"
    case Email         = "email"
}

enum CustomError {
    
    case invalidCredentials
    case invalidName
    case invalidEmail
    case passwordLength
    case signUpFailure
    case networkError
    case generalError
    
    var string: String {
        switch self {
        case .invalidCredentials:
            return "Invalid Credentials"
        case .invalidName:
            return "Please enter a valid name"
        case .invalidEmail:
            return "Please enter a valid email"
        case .passwordLength:
            return "Password must be 6 or more characters"
        case .signUpFailure:
            return "Sign up failed. Please try again"
        case .networkError:
            return "Network error, try again later"
        case .generalError:
            return "There was an error, try again"
        }
    }
}
