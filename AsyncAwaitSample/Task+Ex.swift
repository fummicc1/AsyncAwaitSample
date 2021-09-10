import Foundation

extension Task {
    func store(in cancellables: inout Set<Task<Success, Failure>>) {
        cancellables.insert(self)
    }
}
