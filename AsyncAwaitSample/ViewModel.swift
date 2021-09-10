import Foundation
import Combine

extension Task {
    func store(in cancellables: inout Set<Task<Success, Failure>>) {
        cancellables.insert(self)
    }
}

class ViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var searchPosts: [QiitaResponse] = []
    @Published var isLoading: Bool = false
    
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
    
    func apply(_ input: Input) {
        switch input {
        case .appear:
            isLoading = true
            Task {
                await searchQiitaPost(word: "Swift")
            }
            .store(in: &cancellables)
            
        case .search:
            isLoading = true
            Task {
                await searchQiitaPost(word: searchText)
            }
            .store(in: &cancellables)
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

extension ViewModel {
    enum Error: Swift.Error {
        case emptyQuery
    }
    
    enum Input {
        case appear
        case search
    }
}
