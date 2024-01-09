import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultApiBaseURLString: String
    let unsplashAuthorizeURLString: String

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: "Jmods55jjhRuFYwagFjtRvfo3qLSxh_rHBuvz4Ac6zI",
            secretKey: "KEa0oXTCNndFSr4euPnq2-qIgcnTBD3a_V1bFZVUT7Q",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            defaultApiBaseURLString: ("https://api.unsplash.com"),
            unsplashAuthorizeURLString: "https://unsplash.com/oauth/authorize"
        )
    }
}
