//
//  AsyncViewModelTests.swift
//  AsyncViewModelTests
//
//  Created by Fumiya Tanaka on 2021/09/13.
//

import XCTest
@testable import AsyncAwaitSample

class AsyncViewModelTests: XCTestCase {
    
    var target: AsyncViewModel!
    var useCase: UseCaseMock!

    override func setUpWithError() throws {
        useCase = UseCaseMock()
        target = AsyncViewModel(useCase: useCase)
    }
    
    func test_search() async {
        
    }

}
