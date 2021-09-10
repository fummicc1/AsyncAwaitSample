import Foundation

protocol QiitaClient {
    func fetch(query: String) async throws -> QiitaResponseList
}

let requestBaseURL: String = "https://qiita.com/api/v2/items"

class APIClient: QiitaClient {
    
    enum Error: Swift.Error {
        case apiError
    }
    
    private let session = URLSession.shared
    
    func fetch(query: String) async throws -> QiitaResponseList {
        
        var comp = URLComponents(string: requestBaseURL)!
        
        var items = comp.queryItems ?? []
        items.append(URLQueryItem(name: "query", value: query))
        comp.queryItems = items
        
        let request = URLRequest(url: comp.url!)
        
        let (data, response) = try await session.data(for: request, delegate: nil)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw Error.apiError
        }
        
        let result = try JSONDecoder().decode(QiitaResponseList.self, from: data)
        return result
    }
    
}
