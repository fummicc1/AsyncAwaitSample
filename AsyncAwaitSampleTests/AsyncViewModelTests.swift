import XCTest
@testable import AsyncAwaitSample
import StubKit

class AsyncViewModelTests: XCTestCase {
    
    var target: AsyncViewModel!
    var useCase: UseCaseMock!

    override func setUpWithError() throws {
        useCase = UseCaseMock()
    }
    
    @MainActor
    func test_search() async {
        
        let mockUseCase = UseCaseMock()
        let posts = mockUseCase.searchQiitaPostReturn
        
        let viewModel = AsyncViewModel(environment: AsyncViewModel.Environment(useCase: mockUseCase))
        let task = viewModel.apply(action: .onAppear)
        
        XCTAssertTrue(viewModel.state.isLoading)
        
        // 処理を待つ
        await task.get()
        
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertEqual(posts, viewModel.state.posts)
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
