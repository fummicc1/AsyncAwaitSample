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
            await MainActor.run {
                isLoading = true
            }
            await searchQiitaPost(word: "Swift")
            
        case .search:
            await MainActor.run {
                isLoading = true
            }
            await searchQiitaPost(word: searchText)
        }
    }
    
    private func searchQiitaPost(word: String) async {
        do {
            let posts = try await useCase.searchQiitaPost(word: word)
            await MainActor.run {
                self.searchPosts = posts
            }
        } catch {
            print(error)
        }
        await MainActor.run {
            isLoading = false
        }
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

