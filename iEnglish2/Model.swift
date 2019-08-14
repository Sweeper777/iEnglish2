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

