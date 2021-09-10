import Foundation

protocol UseCase {
    func searchQiitaPost(word: String) async throws -> QiitaResponseList
}

class UseCaseImpl: UseCase {
    
    enum Error: Swift.Error {
        case emptyQuery
    }
    
    let client: QiitaClient
    
    init(client: QiitaClient = APIClient()) {
        self.client = client
    }
    
    func searchQiitaPost(word: String) async throws -> QiitaResponseList {
        if word.isEmpty {
            throw Error.emptyQuery
        }
        let list = try await client.fetch(query: word)
        return list
    }
}
