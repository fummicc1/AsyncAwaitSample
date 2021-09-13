import Foundation
import Combine

class AsyncViewModel: ObservableObject {
    
    @MainActor @Published var state: State = State()
    let environment: Environment = .init(useCase: UseCaseImpl())
    
    deinit {
        print("deinit \(Self.self)")
    }
}

extension AsyncViewModel {
    enum Error: Swift.Error {
        case emptyQuery
    }
    
    enum Input {
        case appear
        case search
    }
}

extension AsyncViewModel {
    struct State {
        var posts: [QiitaResponse] = []
        var searchText: String = ""
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }
    
    enum Action {
        case showLoading
        case hideLoading
        case changeQuery(query: String)
        case setPosts([QiitaResponse])
        case startQuery
        case hideError
        case showError(message: String)
    }
    
    struct Environment {
        let useCase: UseCase
    }
    
    @MainActor
    func reducer(action: Action, state: inout State, environment: Environment) async {
        switch action {
            
        case .showLoading:
            state.isLoading = true
            
        case .hideLoading:
            state.isLoading = false
            
        case .setPosts(let posts):
            state.posts = posts
            
        case .changeQuery(let query):
            state.searchText = query
            
        case .startQuery:
            let query = state.searchText
            do {
                let posts = try await environment.useCase.searchQiitaPost(word: query)
                await reducer(action: .setPosts(posts), state: &state, environment: environment)
            } catch {
                await reducer(action: .showError(message: "\(error)"), state: &state, environment: environment)
            }
            await reducer(action: .hideLoading, state: &state, environment: environment)
            
        case .hideError:
            state.errorMessage = nil
            
        case .showError(let message):
            state.errorMessage = message
        }
    }
}
