//
//  AsyncViewModelTests.swift
//  AsyncViewModelTests
//
//  Created by Fumiya Tanaka on 2021/09/13.
//

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
            XCTAssertEqual(expectState, actualState, file: file, line: line)
            XCTAssertEqual(expectActions, actualActions, file: file, line: line)
        }
    }
    
}

class AsyncViewModelTests: XCTestCase {
    
    var target: AsyncViewModel!
    var useCase: UseCaseMock!

    override func setUpWithError() throws {
        useCase = UseCaseMock()
    }
    
    @MainActor
    func test_search() async {
        let posts = useCase.searchQiitaPostReturn
        let expectState = AsyncViewModel.State(
            posts: posts,
            searchText: "Test",
            isLoading: false,
            errorMessage: nil
        )
        
        let mocked = AsyncViewModel.MockedMiddleware(
            expectActions: [.startQuery, .showLoading, .setPosts(posts), .hideLoading],
            expectState: expectState
        )
        
        target = AsyncViewModel(middlewares: AsyncViewModel.middlewares + [mocked])
        
        target.state.searchText = "Test"
        target.apply(action: .startQuery)
        
        let exp = expectation(description: "\(#function)")
        wait(for: [exp], timeout: 1)
        
        mocked.assert()
    }

}
