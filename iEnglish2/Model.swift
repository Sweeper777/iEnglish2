import RealmSwift
import AVFoundation

class UtteranceObject: Object {
    @objc dynamic var string = ""
    @objc dynamic var rate: Float = 0.5
    @objc dynamic var pitch: Float = 1
    @objc dynamic var volume: Float = 0.0
    @objc dynamic var language = "en-GB"
}

class PlaylistObject: Object {
    let items = List<UtteranceObject>()
    @objc dynamic var name = ""
}

struct Utterance {
    let string: String
    let rate: Float
    let pitch: Float
    let volume: Float
    let language: String
}

struct UtteranceSettings : Equatable {
    let rate: Float
    let pitch: Float
    let volume: Float
    let language: String
}

struct Playlist {
    let items: [Utterance]
    let name: String
}

extension UtteranceObject {
    var utterance: Utterance {
        return Utterance(
            string: string,
            rate: rate,
            pitch: pitch,
            volume: volume,
            language: language)
    }
    
    convenience init(from utterance: Utterance) {
        self.init()
        string = utterance.string
        rate = utterance.rate
        pitch = utterance.pitch
        volume = utterance.volume
        language = utterance.language
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

extension Utterance {
    var avUtterance: AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: string)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        return utterance
    }
    
    init(string: String, settings: UtteranceSettings) {
        self.init(string: string, rate: settings.rate, pitch: settings.pitch, volume: settings.volume, language: settings.language)
    }
}
