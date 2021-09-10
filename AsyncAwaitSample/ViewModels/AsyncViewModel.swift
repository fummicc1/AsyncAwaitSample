import Foundation
import Combine

class AsyncViewModel: ObservableObject {
    
    @MainActor @Published var searchText: String = ""
    @MainActor @Published var searchPosts: [QiitaResponse] = []
    @MainActor @Published var isLoading: Bool = false
    
    private var cancellables: Set<Task<Void, Never>> = []
    private let useCase: UseCase
    
    
    init(useCase: UseCase = UseCaseImpl()) {
        self.useCase = useCase
    }
    
    deinit {
        cancellables.forEach({
            $0.cancel()
        })
        print("deinit \(Self.self)")
    }
    
    func apply(_ input: Input) async {
        switch input {
        case .appear:
            isLoading = true
            await searchQiitaPost(word: "Swift")
            
        case .search:
            isLoading = true
            await searchQiitaPost(word: searchText)
        }
    }
    
    @MainActor
    private func searchQiitaPost(word: String) async {
        do {
            let posts = try await useCase.searchQiitaPost(word: word)
            searchPosts = posts
        } catch {
            print(error)
        }
        isLoading = false
    }
    
}

extension AsyncViewModel {
    enum Error: Swift.Error {
        case emptyQuery
    }
    
    enum Input {
        case appear
        case search
    }
}

