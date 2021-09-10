import Foundation

// MARK: - QiitaResponse
struct QiitaResponse: Codable, Identifiable, Hashable {
    let renderedBody, body: String
    let coediting: Bool
    let commentsCount: Int
    let group: Group?
    let id: String
    let likesCount: Int
    let welcomePrivate: Bool
    let reactionsCount: Int
    let tags: [Tag]
    let title: String
    let url: String
    let user: User
    let pageViewsCount: Int?
    let teamMembership: TeamMembership?

    enum CodingKeys: String, CodingKey {
        case renderedBody = "rendered_body"
        case body, coediting
        case commentsCount = "comments_count"
        case group, id
        case likesCount = "likes_count"
        case welcomePrivate = "private"
        case reactionsCount = "reactions_count"
        case tags, title
        case url, user
        case pageViewsCount = "page_views_count"
        case teamMembership = "team_membership"
    }
}

// MARK: - Group
struct Group: Codable, Hashable {
    let groupDescription: String?
    let name: String
    let groupPrivate: Bool
    let urlName: String?

    enum CodingKeys: String, CodingKey {
        case groupDescription = "description"
        case name
        case groupPrivate = "private"
        case urlName = "url_name"
    }
}

// MARK: - Tag
struct Tag: Codable, Hashable {
    let name: String
    let versions: [String]
}

// MARK: - TeamMembership
struct TeamMembership: Codable, Hashable {
    let name: String
}

// MARK: - User
struct User: Codable, Hashable {
    let userDescription, facebookID: String?
    let followeesCount, followersCount: Int
    let githubLoginName: String?
    let id: String
    let itemsCount: Int
    let linkedinID, location, name, organization: String?
    let permanentID: Int
    let profileImageURL: String
    let teamOnly: Bool
    let twitterScreenName: String?
    let websiteURL: String?

    enum CodingKeys: String, CodingKey {
        case userDescription = "description"
        case facebookID = "facebook_id"
        case followeesCount = "followees_count"
        case followersCount = "followers_count"
        case githubLoginName = "github_login_name"
        case id
        case itemsCount = "items_count"
        case linkedinID = "linkedin_id"
        case location, name, organization
        case permanentID = "permanent_id"
        case profileImageURL = "profile_image_url"
        case teamOnly = "team_only"
        case twitterScreenName = "twitter_screen_name"
        case websiteURL = "website_url"
    }
}

typealias QiitaResponseList = [QiitaResponse]
