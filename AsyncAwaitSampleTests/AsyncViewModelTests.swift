import XCTest
@testable import AsyncAwaitSample
import StubKit

extension AsyncViewModel {
    
    class MockedMiddleware: Middleware {
        
        init(
            expectActions: [AsyncViewModel.MockedMiddleware.Action],
            expectState: AsyncViewModel.MockedMiddleware.State,
            actualActions: [AsyncViewModel.MockedMiddleware.Action] = [],
            actualState: AsyncViewModel.MockedMiddleware.State = .init()
        ) {
            self.expectActions = expectActions
            self.expectState = expectState
            self.actualActions = actualActions
            self.actualState = actualState
        }
        
        
        var expectActions: [Action]
        var expectState: State
        
        private var actualActions: [Action]
        private var actualState: State
        
        override func middleware(action: Action, state: State, environment: Environment) async -> Effect {
            actualActions.append(action)
            actualState = state
            return .none
        }
        
        func assert(file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual(expectActions, actualActions, file: file, line: line)
            XCTAssertEqual(expectState, actualState, file: file, line: line)
        }
    }
    
}

class AsyncViewModelTests: XCTestCase {
    
    var target: AsyncViewModel!
    var useCase: UseCaseMock!

    override func setUpWithError() throws {
        useCase = UseCaseMock()
    }
    
    func test_search_middleware() async {
        let middleware = AsyncViewModel.Middleware()
        
        let state = AsyncViewModel.State()
        let useCaseMock = UseCaseMock()
        let posts = useCaseMock.searchQiitaPostReturn
        let environment = AsyncViewModel.Environment(useCase: useCaseMock)
        
        let effect = await middleware.middleware(action: .startSearch, state: state, environment: environment)
        switch effect {
        case .some(let nextAction as AsyncViewModel.Action):
            XCTAssertEqual(AsyncViewModel.Action.setPosts(posts), nextAction)
        default:
            XCTFail()
        }
    }
    
    @MainActor
    func test_search_reducer() {
        
        let useCaseMock = UseCaseMock()
        let posts = useCaseMock.searchQiitaPostReturn
        let environment = AsyncViewModel.Environment(useCase: useCaseMock)
        
        let viewModel = AsyncViewModel(environment: environment, middlewares: [])
        
        viewModel.reducer(action: .showLoading, state: &viewModel.state, environment: environment)
        
        XCTAssertTrue(viewModel.state.isLoading)
        
        viewModel.reducer(action: .setPosts(posts), state: &viewModel.state, environment: environment)
        
        XCTAssertFalse(viewModel.state.isLoading)
    }
}
