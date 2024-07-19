import SwiftUI

struct ContentView: View {
    @StateObject var characterStore = CharacterStore()
    @State var showSplash = true
    @State private var searchText = ""
    @State private var showSheet = false
    @State private var statuses: [String] = ["alive", "dead" , "unknown"]
    
    
    
    var filteredCharacters: [Character] {
        if searchText.isEmpty {
            return characterStore.characters
        } else {
            return characterStore.characters.filter { character in
                character.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    
    var body: some View {
        ZStack{
            if showSplash {
                splash().transition(.opacity)
            } else {
                NavigationView {
                    
                    VStack {
                        Text("Characters")
                            .font(.system(size: 32))
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                        
                        HStack {
                            TextField("", text: $searchText)
                                .frame(maxHeight: 30)
                                .background(.white.opacity(0.1))
                                .cornerRadius(5)
                                .foregroundColor(.white)
                                .compositingGroup()
                                .overlay(
                                    ZStack {
                                        if searchText.isEmpty {
                                            HStack(spacing: 5){
                                                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                                                Text("Search")
                                                    .foregroundColor(.gray)
                                                
                                            }
                                        }
                                    } .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 5)
                                )
                            
                            Button(action: {
                                showSheet = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .frame(maxWidth: 25, maxHeight: 25)
                            }
                        }.padding(.bottom, 10)
                        
                        
                        ScrollView {
                            LazyVStack {
                                ForEach(filteredCharacters, id: \.id) { character in
                                    NavigationLink(destination: CharacterView(character: character), label: {
                                        block(character: character)
                                    })
                                }
                                if characterStore.isLoading {
                                    ProgressView()
                                        .padding()
                                } else if characterStore.characters.count > 0 {
                                    Rectangle()
                                        .frame(height: 50)
                                        .opacity(0.0)
                                        .task(id: characterStore.characters.count) {
                                            characterStore.fetchCharacters(page: characterStore.currentPage)
                                        }
                                }
                            }
                            .onAppear {
                                characterStore.fetchCharacters(page: characterStore.currentPage)
                            }
                        }
                    }
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2).edgesIgnoringSafeArea(.all))
                }
            }
        }.onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.interactiveSpring(duration: 1.5)) {
                    self.showSplash = false
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            SheetView(showSheet: $showSheet, statuses: $statuses)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
    
    
    
    struct SheetView: View {
        @Binding var showSheet: Bool
        @Binding var statuses: [String]
        var body: some View {
            VStack {
                HStack{
                    Button(action: {
                        showSheet = false
                    }) {
                        Image(systemName: "xmark").resizable()
                            .frame(maxWidth: 20, maxHeight: 20)
                    }
                    Spacer()
                    
                    Text("Filters").font(.system(size: 24))
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Text("Reset")
                    }
                    
                }.frame(maxWidth: .infinity)
                
                Spacer()
                
                VStack{
                    Text("Status")
                    filterParams()
                    
                    
                }.frame(alignment: .leading)
                    
                Spacer()
                
                VStack{
                    Text("Gender")
                    
                }.frame(alignment: .leading)
                Spacer()
                
                Button(action: {
                    showSheet = false
                }) {
                    Text("Apply").padding(5)
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                }
            }.foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .cornerRadius(20)
                .background(Color(red: 0.2, green: 0.2, blue: 0.2).edgesIgnoringSafeArea(.all))
            
        }
        
        
        struct CheckboxToggleStyle: ToggleStyle {
            func makeBody(configuration: Configuration) -> some View {
                Button {
                    configuration.isOn.toggle()
                } label: {
                    HStack {
                        Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                        configuration.label
                    }
                }
            }
        }
    
    
    @ViewBuilder
    func filterParams() -> some View{
        HStack{
        }
    }
}
    
    
    
    @ViewBuilder
    func splash() -> some View{
        VStack{
            Image("splashTitle").resizable()
                .aspectRatio(contentMode: .fit)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.7))
                        .frame(maxWidth: .infinity, maxHeight: .infinity
                              )
                        .edgesIgnoringSafeArea(.all)
                )
        )
    }

    @ViewBuilder
    func block(character: Character) -> some View {
        HStack(){
            AsyncImage(url: URL(string: character.image)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: .infinity)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: .infinity)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: .infinity)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            @unknown default:
                                EmptyView()
                            }
                        }

            VStack(alignment: .leading){
                Text(character.name)
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                HStack{
                    Text(character.status).foregroundColor(character.getStatusColor())
                    Text("•")
                    Text(character.species)
                }

                Text(character.gender)
            }.frame(maxHeight: .infinity)
                .padding(.leading, 15)
                .foregroundColor(.white)

        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .frame(width: .infinity)
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: .infinity)
    }
}
