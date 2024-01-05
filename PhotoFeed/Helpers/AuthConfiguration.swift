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
            accessKey: "34t2lwoXiAZTkh02Po-8--STfbitLRFKgNdS7Tyegvo",
            secretKey: "wvngSda4iX5Yt5R-OxkFDZ2knqDxARAVdCpucDhS5qQ",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            defaultApiBaseURLString: ("https://api.unsplash.com"),
            unsplashAuthorizeURLString: "https://unsplash.com/oauth/authorize"
        )
    }
}
