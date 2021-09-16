import Foundation
import Combine

actor Store: ObservableObject {
    
    static let shared = Store()
    
    @Published private(set) var appState: AppState = .init()
    
    private var reducer: Reducer = AsyncViewModel()
    
    func dispatch(action: ActionType, middlewares: [Middleware]) {
        
        switch action {
        case let action as AsyncViewModel.Action:
            appState.searchState =
        }
        
        for m in middlewares {
            m.middleware(action: action, state: <#T##StateType#>, environment: <#T##EnvironmentType#>)
        }
        
    }
}

protocol ActionType { }

protocol StateType { }

protocol EnvironmentType { }

protocol Reducer {
    @MainActor func reducer<Action: ActionType, State: StateType>(action: Action, state: State) -> State
}

protocol Middleware {
    func middleware<Action: ActionType, State: StateType, Environment: EnvironmentType>(action: Action, state: State, environment: Environment) async -> Action
}

struct AppState {
    var searchState: AsyncViewModel.State = .init()
}
