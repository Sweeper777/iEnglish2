import RealmSwift

final class RealmWrapper {
    let playlists: Results<PlaylistObject>!
    let realm: Realm!
    
    private init() {
        do {
            realm = try Realm()
            playlists = realm.objects(PlaylistObject.self)
        } catch let error {
            print(error)
            fatalError()
        }
    }
    
    private static var _shared: RealmWrapper?
    
    static var shared: RealmWrapper {
        _shared = _shared ?? RealmWrapper()
        return _shared!
    }
}
