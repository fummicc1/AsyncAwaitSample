import Foundation

@testable import AsyncAwaitSample
import XCTest
import StubKit

class QiitaClientMock: QiitaClient {
    func fetch(query: String) async throws -> QiitaResponseList {
        let stub = try Stub.make(QiitaResponse.self)
        return [stub]
    }
}

class UseCaseTests: XCTestCase {
    
    func testFetch() async throws {
        let useCase = UseCaseImpl(client: QiitaClientMock())
        let posts = try await useCase.searchQiitaPost(word: "test")
        XCTAssertFalse(posts.isEmpty)
    }
    
    func testFetch_empty() async throws {
        let useCase = UseCaseImpl(client: QiitaClientMock())
        do {
            _ = try await useCase.searchQiitaPost(word: "")
            XCTFail()
        } catch let error as UseCaseImpl.Error {
            XCTAssertEqual(error, UseCaseImpl.Error.emptyQuery)
        } catch {
            XCTFail()
        }
    }
}
