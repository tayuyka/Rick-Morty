import SwiftUI

class CharacterStore: ObservableObject {
    @Published var characters: [Character] = []
    @Published var currentPage = 1
    @Published var isLoading = false
    
    func fetchCharacters(page: Int) {
        print("page-" + String(page))
        isLoading = true
        let url = URL(string: "https://rickandmortyapi.com/api/character/?page=\(page)")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let charactersResponse = try JSONDecoder().decode(CharactersResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.characters += charactersResponse.results
                        self.currentPage += 1
                        self.isLoading = false
                    }
                } catch {
                    print("Error decoding characters: \(error)")
                    self.isLoading = false
                }
            } else {
                print("Error fetching characters: \(error?.localizedDescription ?? "Unknown error")")
                self.isLoading = false
            }
        }.resume()
    }
    
    func fetchFilteredCharacters(name: String? = nil, status: String? = nil, species: String? = nil, type: String? = nil, gender: String? = nil, page: Int) {
        var urlComponents = URLComponents(string: "https://rickandmortyapi.com/api/character")
        var queryItems: [URLQueryItem] = []

        if let name = name {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        if let species = species {
            queryItems.append(URLQueryItem(name: "species", value: species))
        }

        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }

        if let gender = gender {
            queryItems.append(URLQueryItem(name: "gender", value: gender))
        }

        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let charactersResponse = try JSONDecoder().decode(CharactersResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.characters += charactersResponse.results
                        self.currentPage += 1
                        self.isLoading = false
                    }
                } catch {
                    print("Error decoding characters: \(error)")
                    self.isLoading = false
                }
            } else {
                print("Error fetching characters: \(error?.localizedDescription ?? "Unknown error")")
                self.isLoading = false
            }
        }.resume()
    }

}

func getCharacterById(by id: Int, completion: @escaping (Character?) -> Void) {
    let url = URL(string: "https://rickandmortyapi.com/api/character/\(id)")!
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("Error: \(error)")
            completion(nil)
        } else if let data = data {
            do {
                let decoder = JSONDecoder()
                let character = try decoder.decode(Character.self, from: data)
                completion(character)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }
    }
    task.resume()
}

func getEpisodeNames(for character: Character, completion: @escaping ([String]?) -> Void) {
var episodeNames: [String] = []
let group = DispatchGroup()

for episodeURL in character.episode {
    group.enter()

    let url = URL(string: episodeURL)!
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        defer {
            group.leave()
        }

        if let error = error {
            print("Error: \(error)")
            completion(nil)
        } else if let data = data {
            do {
                let decoder = JSONDecoder()
                let episode = try decoder.decode(Character.Episode.self, from: data)
                episodeNames.append(episode.name)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }
    }
    task.resume()
}

group.notify(queue: .main) {
    completion(episodeNames)
}
}
