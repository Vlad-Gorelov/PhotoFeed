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
            accessKey: "gLkc8QG1UQq8IA3AlkD-O6dhMIyE3uU43gaNZ0aw6ME",
            secretKey: "6qbyN1WJcsECpQmC9W-qJ6PYvmi1wf2KIoFopXKmExU",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            defaultApiBaseURLString: ("https://api.unsplash.com"),
            unsplashAuthorizeURLString: "https://unsplash.com/oauth/authorize"
        )
    }
}
