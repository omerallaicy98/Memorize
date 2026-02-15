import SwiftUI
import Combine

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    @Published var screenWidth: CGFloat = 0
    @Published var ScreenHeight: CGFloat = 0
    @Published var circleButtonSize: CGFloat = 0
    @Published var geometrySet: CGFloat = 0
    
    @Published var loadingTime: CGFloat = 3
    @Published var loadingTransitionTime: CGFloat = 0.5
    
    @Published var themeType: ThemeType = .white
    @Published var mainColor: Color { didSet { saveThemeStatus() } }
    @Published var secondaryColor: Color { didSet { saveThemeStatus() } }
    @Published var isSoundOn: Bool { didSet { saveSoundStatus() } }
    @Published var isHapticsOn: Bool { didSet { saveHapticsStatus() } }
    
    @Published var currentOrderLevel: Int { didSet { saveOrderLevel() } }
    @Published var currentRushLevel: Int { didSet { saveRushLevel() } }
    @Published var currentForceLevel: Int { didSet { saveForceLevel() } }
    @Published var currentRecallLevel: Int { didSet { saveRecallLevel() } }
    @Published var currentEndlessHighscore: Int { didSet { saveEndlessHighScore() } }
    private let gridStages: [Int] = [2, 3, 4, 5, 6]
    
    init() {
        if let mainData = UserDefaults.standard.data(forKey: "themeMain"),
           let secondaryData = UserDefaults.standard.data(forKey: "themeSecondary"),
           let mainUIColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: mainData),
           let secondaryUIColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: secondaryData) {
            self.mainColor = Color(mainUIColor)
            self.secondaryColor = Color(secondaryUIColor)
        }
        else {
            self.mainColor = .white
            self.secondaryColor = .black
        }
        
        self.isSoundOn = UserDefaults.standard.object(forKey: "isSoundOn") as? Bool ?? true
        
        self.isHapticsOn = UserDefaults.standard.object(forKey: "isHapticsOn") as? Bool ?? true
        
        self.currentOrderLevel = UserDefaults.standard.object(forKey: "currentOrderLevel") as? Int ?? 1
        
        self.currentRushLevel = UserDefaults.standard.object(forKey: "currentRushLevel") as? Int ?? 1
        
        self.currentForceLevel = UserDefaults.standard.object(forKey: "currentForceLevel") as? Int ?? 1
        
        self.currentRecallLevel = UserDefaults.standard.object(forKey: "currentRecallLevel") as? Int ?? 1
        
        self.currentEndlessHighscore = UserDefaults.standard.object(forKey: "currentEndlessHighscore") as? Int ?? 0
    }
    
    private func saveThemeStatus() {
        let mainUIColor = UIColor(mainColor)
        let secondaryUIColor = UIColor(secondaryColor)
        if let mainData = try? NSKeyedArchiver.archivedData(withRootObject: mainUIColor, requiringSecureCoding: false),
           let secondaryData = try? NSKeyedArchiver.archivedData(withRootObject: secondaryUIColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(mainData, forKey: "themeMain")
            UserDefaults.standard.set(secondaryData, forKey: "themeSecondary")
        }
    }
    private func saveSoundStatus() {
        UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
    }
    private func saveHapticsStatus() {
        UserDefaults.standard.set(isHapticsOn, forKey: "isHapticsOn")
    }
    private func saveOrderLevel() {
        UserDefaults.standard.set(currentOrderLevel, forKey: "currentOrderLevel")
    }
    private func saveRushLevel() {
        UserDefaults.standard.set(currentRushLevel, forKey: "currentRushLevel")
    }
    private func saveForceLevel() {
        UserDefaults.standard.set(currentForceLevel, forKey: "currentForceLevel")
    }
    private func saveRecallLevel() {
        UserDefaults.standard.set(currentRecallLevel, forKey: "currentRecallLevel")
    }
    private func saveEndlessHighScore() {
        UserDefaults.standard.set(currentEndlessHighscore, forKey: "currentEndlessHighscore")
    }
    
    func toggleSound() {
        isSoundOn.toggle()
    }
    func toggleHaptics() {
        isHapticsOn.toggle()
    }
    func toggleTheme() {
        let temp = mainColor
        mainColor = secondaryColor
        secondaryColor = temp
    }
    func updateTheme(type: ThemeType) {
        themeType = type
        switch type {
            case .white:
                mainColor = .white
                secondaryColor = .black
            case .maroon:
                mainColor = .lightMaroon
                secondaryColor = .darkMaroon
            case .navy:
                mainColor = .lightNavy
                secondaryColor = .darkNavy
            case .olive:
                mainColor = .lightOlive
                secondaryColor = .darkOlive
        }
    }
    
    func incrementOrderLevel() {
        currentOrderLevel+=1
    }
    func incrementRushLevel() {
        currentRushLevel+=1
    }
    func incrementForceLevel() {
        currentForceLevel+=1
    }
    func incrementRecallLevel() {
        currentRecallLevel+=1
    }
    func incrementEndlessHighscore(newHighScore: Int) {
        currentEndlessHighscore = newHighScore
    }

    private func levelsInStage(for gridSize: Int) -> Int {
        let area = gridSize * gridSize
        return area * 4
    }
    func getGridSizeForLevel(_ level: Int) -> Int {
        var accumulated = 0
        
        for grid in gridStages {
            let stageLevels = levelsInStage(for: grid)
            accumulated += stageLevels
            
            if level <= accumulated {
                return grid
            }
        }
        
        return 6
    }
    func getStageStartLevel(for level: Int) -> Int {
        var accumulated = 0
        
        for grid in gridStages {
            let stageLevels = levelsInStage(for: grid)
            
            if level <= accumulated + stageLevels {
                return accumulated + 1
            }
            
            accumulated += stageLevels
        }
        
        return accumulated + 1
    }
    func getLevelInStage(for level: Int) -> Int {
        let start = getStageStartLevel(for: level)
        return level - start
    }
    func getStageProgress(for level: Int) -> Double {
        let grid = getGridSizeForLevel(level)
        let totalLevels = levelsInStage(for: grid)
        let levelInStage = getLevelInStage(for: level)
        
        return Double(levelInStage) / Double(max(totalLevels - 1, 1))
    }
    func getMatchingCards(for level: Int) -> Int {
        let grid = getGridSizeForLevel(level)
        let area = grid * grid
        let progress = getStageProgress(for: level)
        
        let density = 0.35 + progress * 0.6
        let matches = Int(Double(area) * density)
        
        return max(1, min(matches, area))
    }
    
    func computeGeometry(for geometry: GeometryProxy) {
        geometrySet = 1
        screenWidth = geometry.size.width
        ScreenHeight = geometry.size.height
        circleButtonSize = geometry.size.height / 18
    }
}

enum ThemeType {
    case white, maroon, navy, olive
}

extension Color {
    static let lightMaroon = Color(red: 0.82, green: 0.60, blue: 0.68)
    static let darkMaroon = Color(red: 0.45, green: 0.05, blue: 0.18)
    static let lightOlive = Color(red: 0.72, green: 0.76, blue: 0.55)
    static let darkOlive = Color(red: 0.35, green: 0.38, blue: 0.12)
    static let lightNavy = Color(red: 0.55, green: 0.62, blue: 0.78)
    static let darkNavy = Color(red: 0.05, green: 0.10, blue: 0.30)
}
