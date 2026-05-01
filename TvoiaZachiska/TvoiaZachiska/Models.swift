import SwiftUI
import Combine

// MARK: - Enums

enum AppScreen: String, Hashable, CaseIterable {
    case splash, onboard, permission, home
    case capture, gender, hairquiz, gallery
    case preview, analyzing, result
    case saved, profile
}

enum HairGender: String, Hashable {
    case woman = "woman"
    case man = "man"
}

enum GalleryLayout: String {
    case grid, carousel, list
}

enum AnalysisStyle: String {
    case minimal, detailed
}

enum HairLength: String {
    case bald = "Лисе"
    case short = "Коротке"
    case medium = "Середнє"
    case long = "Довге"
}

enum NavigationDirection {
    case forward, backward
}

// MARK: - Data models

struct HairstyleItem: Identifiable, Hashable {
    let id: String
    let name: String
    let length: HairLength
    let vibe: String
    let match: Int
    let hue: String      // hex color
    let shape: HairShape
    var gender: HairGender = .woman
}

struct SavedItem: Identifiable {
    let id = UUID()
    let styleId: String
    let date: String
}

struct HairProfile {
    var texture: String? = nil    // straight/wavy/curly/coily
    var thickness: String? = nil  // thin/medium/thick
    var porosity: String? = nil   // low/normal/high
    var faceShape: String? = nil  // oval/round/square/heart/long
    var timeStyling: String? = nil // <5 / 5-15 / 15-30 / 30+
}

// MARK: - AppState

class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .splash
    @Published var navDirection: NavigationDirection = .forward
    private var history: [AppScreen] = [.splash]

    @Published var gender: HairGender? = nil
    @Published var photoTaken = false
    @Published var selectedStyle: HairstyleItem? = nil
    @Published var favorites: Set<String> = ["w4", "m5"]
    @Published var saved: [SavedItem] = [SavedItem(styleId: "w15", date: "Сьогодні")]
    @Published var hairProfile = HairProfile()
    @Published var galleryLayout: GalleryLayout = .grid
    @Published var analysisStyle: AnalysisStyle = .detailed

    func navigate(to screen: AppScreen) {
        navDirection = .forward
        history.append(screen)
        withAnimation(.easeInOut(duration: 0.26)) {
            currentScreen = screen
        }
    }

    func back() {
        guard history.count > 1 else { return }
        navDirection = .backward
        history.removeLast()
        withAnimation(.easeInOut(duration: 0.26)) {
            currentScreen = history.last ?? .splash
        }
    }

    func toggleFavorite(_ id: String) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if favorites.contains(id) {
                favorites.remove(id)
            } else {
                favorites.insert(id)
            }
        }
    }
}

// MARK: - Hairstyle data

let womenHairstyles: [HairstyleItem] = [
    // Коротке
    HairstyleItem(id: "w1",  name: "Класичний піксі",    length: .short,  vibe: "Сміливе",      match: 78,  hue: "1F1812", shape: .pixie),
    HairstyleItem(id: "w2",  name: "Піксі з чубкою",     length: .short,  vibe: "Грайливе",     match: 82,  hue: "2A1F18", shape: .pixieFringe),
    HairstyleItem(id: "w3",  name: "Бікси (bixie)",      length: .short,  vibe: "Сучасне",      match: 86,  hue: "3D2B1F", shape: .bixie),
    HairstyleItem(id: "w4",  name: "Текстурний боб",     length: .short,  vibe: "Класика",      match: 94,  hue: "2A1F18", shape: .bob),
    HairstyleItem(id: "w5",  name: "Тупий боб",          length: .short,  vibe: "Мінімал",      match: 87,  hue: "1A120C", shape: .bluntBob),
    HairstyleItem(id: "w6",  name: "Боб А-силует",       length: .short,  vibe: "Класика",      match: 84,  hue: "5B4030", shape: .aBob),
    HairstyleItem(id: "w7",  name: "Французький боб",    length: .short,  vibe: "Романтичне",   match: 80,  hue: "3D2B1F", shape: .frenchBob),
    // Середнє
    HairstyleItem(id: "w8",  name: "Лоб (long bob)",     length: .medium, vibe: "Універсальне", match: 91,  hue: "5B4030", shape: .lob),
    HairstyleItem(id: "w9",  name: "Кучері-ліб",         length: .medium, vibe: "Романтичне",   match: 81,  hue: "8B6342", shape: .curlyLob),
    HairstyleItem(id: "w10", name: "Пряма чубка",        length: .medium, vibe: "Сучасне",      match: 76,  hue: "1A120C", shape: .fringe),
    HairstyleItem(id: "w11", name: "Шеґ",                length: .medium, vibe: "Бунтарське",   match: 84,  hue: "3D2B1F", shape: .shag),
    HairstyleItem(id: "w12", name: "Каскад",             length: .medium, vibe: "Природне",     match: 88,  hue: "5B4030", shape: .layered),
    HairstyleItem(id: "w13", name: "Хвилясте каре",      length: .medium, vibe: "Невимушене",   match: 83,  hue: "A88563", shape: .wavyBob),
    // Довге
    HairstyleItem(id: "w14", name: "Довгі шари",         length: .long,   vibe: "Природне",     match: 88,  hue: "5B4030", shape: .longLayers),
    HairstyleItem(id: "w15", name: "Балаяж-хвилі",       length: .long,   vibe: "Сонячне",      match: 91,  hue: "A88563", shape: .longWavy),
    HairstyleItem(id: "w16", name: "Прямі довгі",        length: .long,   vibe: "Мінімал",      match: 85,  hue: "2D1F16", shape: .longStraight),
    HairstyleItem(id: "w17", name: "Завитки спіралькою", length: .long,   vibe: "Грайливе",     match: 82,  hue: "3D2B1F", shape: .longCurly),
    HairstyleItem(id: "w18", name: "Низький пучок",      length: .long,   vibe: "Мінімал",      match: 79,  hue: "2D1F16", shape: .bun),
    HairstyleItem(id: "w19", name: "Хвіст високий",      length: .long,   vibe: "Спортивне",    match: 77,  hue: "1A120C", shape: .ponytail),
]

let menHairstyles: [HairstyleItem] = [
    // Лисе
    HairstyleItem(id: "m1",  name: "Гладко поголене",    length: .bald,   vibe: "Мінімал",      match: 84,  hue: "0F0F0E", shape: .bald,      gender: .man),
    HairstyleItem(id: "m2",  name: "Бузз-кат №0",        length: .bald,   vibe: "Сміливе",      match: 80,  hue: "2A1F18", shape: .buzzZero,  gender: .man),
    // Коротке
    HairstyleItem(id: "m3",  name: "Бузз-кат",           length: .short,  vibe: "Мінімал",      match: 71,  hue: "2A1F18", shape: .buzz,      gender: .man),
    HairstyleItem(id: "m4",  name: "Кру-кат",            length: .short,  vibe: "Класика",      match: 81,  hue: "1F1812", shape: .crew,      gender: .man),
    HairstyleItem(id: "m5",  name: "Текстурний кроп",    length: .short,  vibe: "Сучасне",      match: 92,  hue: "1A140F", shape: .crop,      gender: .man),
    HairstyleItem(id: "m6",  name: "Айві ліг",           length: .short,  vibe: "Класика",      match: 85,  hue: "3D2B1F", shape: .ivy,       gender: .man),
    HairstyleItem(id: "m7",  name: "Цезар",              length: .short,  vibe: "Класика",      match: 79,  hue: "2A1F18", shape: .caesar,    gender: .man),
    // Середнє
    HairstyleItem(id: "m8",  name: "Бахрома",            length: .medium, vibe: "Природне",     match: 86,  hue: "3D2B1F", shape: .fringeM,   gender: .man),
    HairstyleItem(id: "m9",  name: "Слік-бек",           length: .medium, vibe: "Класика",      match: 89,  hue: "1F1812", shape: .slick,     gender: .man),
    HairstyleItem(id: "m10", name: "Помпадур",           length: .medium, vibe: "Класика",      match: 78,  hue: "1A120C", shape: .pomp,      gender: .man),
    HairstyleItem(id: "m11", name: "Квіф",               length: .medium, vibe: "Сучасне",      match: 87,  hue: "5B4030", shape: .quiff,     gender: .man),
    HairstyleItem(id: "m12", name: "Розкуйовджене",      length: .medium, vibe: "Невимушене",   match: 88,  hue: "3D2B1F", shape: .tousled,   gender: .man),
    HairstyleItem(id: "m13", name: "Середній проділ",    length: .medium, vibe: "Ретро",        match: 76,  hue: "5B4030", shape: .curtain,   gender: .man),
    // Довге
    HairstyleItem(id: "m14", name: "Лонг-флоу",          length: .long,   vibe: "Бунтарське",   match: 74,  hue: "5B4030", shape: .longFlow,  gender: .man),
    HairstyleItem(id: "m15", name: "Чоловічий пучок",    length: .long,   vibe: "Сучасне",      match: 81,  hue: "3D2B1F", shape: .manBun,    gender: .man),
    HairstyleItem(id: "m16", name: "Хвилясті до плечей", length: .long,   vibe: "Природне",     match: 78,  hue: "5B4030", shape: .longWavyM, gender: .man),
]

func hairstyles(for gender: HairGender) -> [HairstyleItem] {
    gender == .woman ? womenHairstyles : menHairstyles
}

func hairstyleById(_ id: String) -> HairstyleItem? {
    (womenHairstyles + menHairstyles).first { $0.id == id }
}

// MARK: - HairShape enum

enum HairShape: String {
    // Bald
    case bald, buzzZero
    // Women short
    case pixie, pixieFringe, bixie, bob, bluntBob, aBob, frenchBob
    // Women medium
    case lob, curlyLob, fringe, shag, layered, wavyBob
    // Women long
    case longLayers, longWavy, longStraight, longCurly, bun, ponytail
    // Men short
    case buzz, crew, crop, ivy, caesar
    // Men medium
    case fringeM, slick, pomp, quiff, tousled, curtain
    // Men long
    case longFlow, manBun, longWavyM
}
