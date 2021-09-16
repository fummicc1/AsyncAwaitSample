import Foundation
import Combine

@MainActor
class AsyncViewModel: ObservableObject {
    
    @Published var state: State = State()
    private let environment: Environment = .init(useCase: UseCaseImpl())
    private let store: Store = .shared
    
    deinit {
        print("deinit \(Self.self)")
    }
    
    func dispatch(action: Action) {
        store.dispatch(action: action)
    }
}

extension AsyncViewModel {
    enum Error: Swift.Error {
        case emptyQuery
    }
}

extension AsyncViewModel {
    struct State: StateType {
        var posts: [QiitaResponse] = []
        var searchText: String = ""
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }
    
    enum Action: ActionType {
        case showLoading
        case hideLoading
        case changeQuery(query: String)
        case setPosts([QiitaResponse])
        case startQuery(query: String)
        case hideError
        case showError(message: String)
    }
    
    struct Environment: EnvironmentType {
        let useCase: UseCase
    }
    
}

extension AsyncViewModel: Reducer, Middleware {
    
    @MainActor
    func reducer(action: ActionType, state: StateType) -> StateType {
        
        guard var state = state as? State, let action = action as? Action else {
            return state
        }
        
        switch action {
        case .showLoading:
            state.isLoading = true
            
        case .hideLoading:
            state.isLoading = false
            
        case .setPosts(let posts):
            state.posts = posts
            
        case .changeQuery(let query):
            state.searchText = query
            
        case .hideError:
            state.errorMessage = nil
            
        case .showError(let message):
            state.errorMessage = message
            
        default:
            break
        }
        
        return state
    }
    
    func middleware(action: ActionType, state: StateType, environment: EnvironmentType) async -> ActionType {
        
        guard
            var state = state as? State,
            let action = action as? Action,
            let environment = environment as? Environment
        else {
            return action
        }
        
        switch action {
        case .startQuery:
            let query = state.searchText
            do {
                let posts = try await environment.useCase.searchQiitaPost(word: query)
                return Action.setPosts(posts)
            } catch {
                return Action.showError(message: error.localizedDescription)
            }
            
        case .changeQuery(let query):
            return Action.startQuery(query: query)
        }
    }
}
