import Foundation
import Combine

protocol ActionType { }
protocol StateType { }
protocol EnvironmentType { }

enum Effect {
    case none
    case some(ActionType)
}

protocol MiddlewareType {
    associatedtype Action: ActionType
    associatedtype State: StateType
    associatedtype Environment: EnvironmentType
    func middleware(
        action: Action,
        state: State,
        environment: Environment
    ) async -> Effect
}

class AsyncViewModel: ObservableObject {
    @MainActor @Published var state: State = State()
    
    private var cancellables: Set<Task<Void, Never>> = []
    private let environment: Environment
    private let middlewares: [Middleware]
    
    init(
        environment: Environment = Environment(),
        middlewares: [Middleware] = []
    ) {
        self.environment = environment
        self.middlewares = middlewares
    }
    
    deinit {
        cancellables.forEach({
            $0.cancel()
        })
        print("deinit \(Self.self)")
    }
    
    @MainActor
    func apply(action: Action) {
        
        reducer(action: action, state: &state, environment: environment)
        
        Task {
            for m in middlewares {
                let effect = await m.middleware(action: action, state: state, environment: environment)
                if case let Effect.some(action as Action) = effect {
                    apply(action: action)
                }
            }
        }.store(in: &cancellables)
        
    }
}

extension AsyncViewModel {
    struct State: StateType, Equatable {
        var posts: [QiitaResponse] = []
        var searchText: String = ""
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }
    
    enum Action: ActionType, Equatable {
        case onAppear
        case showLoading
        case hideLoading
        case setPosts([QiitaResponse])
        case startQuery
        case hideError
        case showError(message: String)
    }
    
    struct Environment: EnvironmentType {
        init(useCase: UseCase = UseCaseImpl()) {
            self.useCase = useCase
        }
        
        let useCase: UseCase
    }
    
    @MainActor
    func reducer(action: Action, state: inout State, environment: Environment) {
        switch action {
            
        case .showLoading:
            state.isLoading = true
            
        case .hideLoading:
            state.isLoading = false
            
        case .setPosts(let posts):
            state.posts = posts
            
        case .hideError:
            state.errorMessage = nil
            
        case .showError(let message):
            state.errorMessage = message
            
        case .onAppear, .startQuery:
            reducer(action: .showLoading, state: &state, environment: environment)
        }
    }
    
    static let middlewares: [Middleware] = [SearchMiddleware(), LoadingMiddleware()]
    
    class Middleware: MiddlewareType {
        func middleware(action: Action, state: State, environment: Environment) async -> Effect {
            .none
        }
    }
    
    class SearchMiddleware: Middleware {
        override func middleware(action: Action, state: State, environment: Environment) async -> Effect {
            switch action {
            case .startQuery:
                let query = state.searchText
                do {
                    let posts = try await environment.useCase.searchQiitaPost(word: query)
                    return .some(Action.setPosts(posts))
                    
                } catch {
                    return .some(Action.showError(message: error.localizedDescription))
                }
                
            case .onAppear:
                do {
                    let posts = try await environment.useCase.searchQiitaPost(word: "Swift")
                    return .some(Action.setPosts(posts))
                    
                } catch {
                    return .some(Action.showError(message: error.localizedDescription))
                }
                
            default:
                break
            }
            return .none
        }
    }
    
    class LoadingMiddleware: Middleware {
        override func middleware(action: Action, state: State, environment: Environment) async -> Effect {
            switch action {
            case .startQuery, .onAppear:
                return .some(Action.showLoading)
                
            case .setPosts:
                return .some(Action.hideLoading)
                
            case .showError:
                return .some(Action.hideLoading)
            default:
                break
            }
            return .none
        }
    }
}
