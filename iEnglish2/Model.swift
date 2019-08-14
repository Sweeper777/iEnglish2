import RealmSwift

class UtteranceObject: Object {
    @objc dynamic var string = ""
}

class PlaylistObject: Object {
    let items = List<UtteranceObject>()
    @objc dynamic var name = ""
}

