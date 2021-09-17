import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: AsyncViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.state.posts, id: \.self) { post in
                    HStack {
                        VStack {
                            AsyncImage(url: URL(string: post.user.profileImageURL)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                case .failure:
                                    // Error Indicator
                                    Color.red.frame(width: 80, height: 80)
                                case .empty:
                                    // Placeholder
                                    Color.gray.frame(width: 80, height: 80)
                                @unknown default:
                                    fatalError()
                                }
                            }
                            Text(post.user.githubLoginName ?? "")
                        }
                        .frame(width: 80)
                        Text(post.body).truncationMode(.head)
                    }
                    .frame(height: 120)
                }
            }
            .showLoading(loading: $viewModel.state.isLoading)
            .navigationTitle("List")
        }
        .onAppear(perform: {
            viewModel.apply(action: .onAppear)
        })
        .searchable(text: $viewModel.state.searchText)
        .onSubmit(of: .search) {
            viewModel.apply(action: .startSearch)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: AsyncViewModel())
    }
}

extension View {
    @ViewBuilder
    func showLoading(loading: Binding<Bool>) -> some View {
        let value = loading.wrappedValue
        if value {
            ZStack {
                self
                ProgressView()
                    .scaleEffect(2)
            }.background(Color.gray)
        } else {
            self
        }
    }
}
