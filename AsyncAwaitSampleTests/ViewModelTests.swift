import Foundation

@testable import AsyncAwaitSample
import XCTest
import StubKit

class UseCaseMock: UseCase {
    
    var searchQiitaPostCalled: Bool = false
    var searchQiitaPostReturn: QiitaResponseList = [try! Stub.make(QiitaResponse.self)]
    
    func searchQiitaPost(word: String) async throws -> QiitaResponseList {
        searchQiitaPostCalled = true
        return searchQiitaPostReturn
    }
    
}

class ViewModelTests: XCTestCase {
    
    @MainActor
    func waitForMain() async {
        await Task.sleep(1)
    }
    
//    @MainActor
    func test_appear() async throws {
        let useCase = UseCaseMock()
        let viewModel = ViewModel(useCase: useCase)
        viewModel.apply(.appear)
        XCTAssertTrue(viewModel.isLoading)
        await waitForMain()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(useCase.searchQiitaPostCalled)
        XCTAssertEqual(viewModel.searchPosts, useCase.searchQiitaPostReturn)
    }
    
    @MainActor func assert(viewModel: ViewModel, useCase: UseCaseMock) async {
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(useCase.searchQiitaPostCalled)
        XCTAssertEqual(viewModel.searchPosts, useCase.searchQiitaPostReturn)
    }
}

extension XCTestCase {
    func wait(timeout: UInt64) async {
        await Task.sleep(timeout)
    }
}
