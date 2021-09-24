## async/await sample

### 設計

### AsyncViewModelについて

Reduxのようなデータフローになっています。
まず、コアな概念としてReduxにもある`Action` `State` `Reducer` `Effect` `Middleware`を問い入れており、以下のような感じで使います。

- コア概念の定義

```swift
protocol ActionType { }
protocol StateType { }
protocol EnvironmentType { }

enum Effect {
    case none // 副作用なし
    case some(ActionType) // 副作用あり
}

protocol Reducer {
    associatedtype Action
    associatedtype State
    @MainActor func reducer(action: Action, state: inout State)
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
```

```swift

class AsyncViewModel: ObservableObject, Reducer {
    // Stateは一つの構造体で一括管理します
    @MainActor @Published var state: State = State()
    
    // asyncを用いる際にTaskを生成する必要がありますが、念のためTaskを保持して、deinitで解放するようにしています
    private var cancellables: Set<Task<Void, Never>> = []
    // Environmentは副作用を実行するためのモジュールです
    private let environment: Environment
    // Middleware（複数可）
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
    
    // View→ViewModelのデータフローを担っています
    @MainActor
    func apply(action: Action) {

        // 最初にReducerを実行した後に、Middleware→Reducer→Middlewareを繰り返して、複雑な処理ができるようにしています

        // Reducerの実行をします
        reducer(action: action, state: &state)
        
        let task: Task<Void, Never> = Task {
            for m in middlewares {
                // Middlewareは返り値にEffectを返します
                let effect = await m.middleware(action: action, state: state, environment: environment)        
                // もし、Actionが存在し、処理可能であればreducerで状態を更新します        
                if case let Effect.some(action as Action) = effect {
                    reducer(action: action, state: &state)
                }
            }
        }
        task.store(in: &cancellables)        
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

```

