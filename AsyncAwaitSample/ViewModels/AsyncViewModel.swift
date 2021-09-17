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
        middlewares: [Middleware] = [Middleware()]
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
    @discardableResult
    func apply(action: Action) -> Task<Void, Never> {
        
        reducer(action: action, state: &state)
        
        let task: Task<Void, Never> = Task {
            for m in middlewares {
                let effect = await m.middleware(action: action, state: state, environment: environment)
                if case let Effect.some(action as Action) = effect {
                    reducer(action: action, state: &state)
                }
            }
        }
        
        task.store(in: &cancellables)
        
        return task
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
        case startSearch
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
    func reducer(action: Action, state: inout State) {
        switch action {
            
        case .showLoading, .onAppear, .startSearch:
            state.isLoading = true
            
        case .hideLoading:
            state.isLoading = false
            
        case .setPosts(let posts):
            state.posts = posts
            state.isLoading = false
            
        case .hideError:
            state.errorMessage = nil
            
        case .showError(let message):
            state.errorMessage = message
            state.isLoading = false
        }
    }
    
    static let middleware = Middleware()
    
    class Middleware: MiddlewareType {
        func middleware(action: Action, state: State, environment: Environment) async -> Effect {
            switch action {
            case .startSearch:
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
}
