import RealmSwift

class UtteranceObject: Object {
    @objc dynamic var string = ""
}

class PlaylistObject: Object {
    let items = List<UtteranceObject>()
    @objc dynamic var name = ""
}

struct Utterance {
    let string: String
}

struct Playlist {
    let items: [Utterance]
    let name: String
}

extension UtteranceObject {
    var utterance: Utterance {
        return Utterance(string: string)
    }
    
    convenience init(from utterance: Utterance) {
        self.init()
        string = utterance.string
    }
}

extension PlaylistObject {
    var playlist: Playlist {
        return Playlist(items: items.map { $0.utterance }, name: name)
    }
    
    convenience init(from playlist: Playlist) {
        self.init()
        name = playlist.name
        items.append(objectsIn: playlist.items.map(UtteranceObject.init(from:)))
    }
}
