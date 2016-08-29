
enum FBPermission: String {
    
    case PublicProfile = "public_profile"
    case Email         = "email"
}

enum Error {
    
    case InvalidCredentials
    case InvalidName
    case InvalidEmail
    case PasswordLength
    case SignUpFailure
    case NetworkError
    case GeneralError
    
    var string: String {
        switch self {
        case .InvalidCredentials:
            return "Invalid Credentials"
        case .InvalidName:
            return "Please enter a valid name"
        case .InvalidEmail:
            return "Please enter a valid email"
        case .PasswordLength:
            return "Password must be 6 or more characters"
        case .SignUpFailure:
            return "Sign up failed. Please try again"
        case .NetworkError:
            return "Network error, try again later"
        case .GeneralError:
            return "There was an error, try again"
        }
    }
}