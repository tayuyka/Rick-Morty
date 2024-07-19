import SwiftUI

struct CharacterView: View {
    @State private var episodeNames: [String] = []

    let character: Character
    var body: some View {
        ZStack{
            Color(red: 0.2, green: 0.2, blue: 0.2).edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    Text(character.name)
                        .font(.system(size: 32))
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    VStack(alignment: .leading){
                        AsyncImage(url: URL(string: character.image)){phase in phase.image?
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity, height: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        
                        Text(character.status)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(character.getStatusColor())
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .fontWeight(.bold)
                        infoLine(chapter: "Species", content: character.species)
                        infoLine(chapter: "Gender", content: character.gender)
                        infoLine(chapter: "Last known location", content: character.locationName)
                        Text("Episodes(\(episodeNames.count)):").fontWeight(.bold)
                        
                        ForEach(episodeNames, id: \.self) { episode in Text(episode)
                        }
                    }.frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .padding(.top, 0)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                }.frame(maxHeight: .infinity, alignment: .topLeading)
                    .onAppear {
                        getEpisodeNames(for: character) { names in
                            guard let names = names else {
                                print("Error: failed to get episode names")
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.episodeNames = names
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    func infoLine(chapter: String, content: String) -> some View {
        HStack{
            VStack{
                Text(chapter + ":").fontWeight(.bold)
            }
            Text(content)
        }
    }
}


