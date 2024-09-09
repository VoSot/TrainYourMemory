import UIKit

class ViewController: UIViewController {

    private var cards = [Card]()
    private var cardButtons = [UIButton]()
    private var firstFlippedCardIndex: Int?
    private var scoreLabel: UILabel!
    private var gameNameLabel: UILabel!
    private var score: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupGame()
    }

    private func setupGame() {
        setupCards()
        setupUI()
    }

    private func setupCards() {
        let imageNames = ["suitcase", "cards", "church", "teapot", "boat", "hat", "car", "watch"]
        cards = imageNames.flatMap { name in
            [Card(imageName: name), Card(imageName: name)]
        }
        cards.shuffle()
    }

    private func setupUI() {
        setupGrid()
        setupScoreLabel()
        setupResetButton()
        setupGameNameLabel()
    }

    private func setupGameNameLabel() {
        gameNameLabel = UILabel()
        gameNameLabel.text = "TrainYourMemory"
        gameNameLabel.font = UIFont.boldSystemFont(ofSize: 28)
        gameNameLabel.textColor = .black
        gameNameLabel.textAlignment = .center
        gameNameLabel.frame = CGRect(x: 0, y: 80, width: view.frame.width, height: 50)
        view.addSubview(gameNameLabel)
    }

    private func setupGrid() {
        let columns = 4
        let spacing: CGFloat = 15
        
        // Calculate the available width for the cards by subtracting the total spacing from the view's width
        let totalSpacing = spacing * CGFloat(columns + 1)
        let availableWidth = view.frame.width - totalSpacing
        
        // Calculate the card size by dividing the available width by the number of columns
        let cardSize = availableWidth / CGFloat(columns)
        
        // Calculate the number of rows based on the number of cards
        let rows = (cards.count + columns - 1) / columns
        
        // Calculate the vertical offset to center the grid vertically
        let totalSpacingY = spacing * CGFloat(rows + 1)
        let offsetY = (view.frame.height - (cardSize * CGFloat(rows)) - totalSpacingY) / 2 + 50

        for row in 0..<rows {
            for col in 0..<columns {
                let index = row * columns + col
                if index >= cards.count { break }

                let button = UIButton(type: .system)
                button.frame = CGRect(
                    x: spacing + CGFloat(col) * (cardSize + spacing),
                    y: offsetY + CGFloat(row) * (cardSize + spacing),
                    width: cardSize,
                    height: cardSize
                )
                button.backgroundColor = UIColor(hex: "295F98")
                button.setTitle("", for: .normal)
                button.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
                button.tag = index
                view.addSubview(button)
                cardButtons.append(button)
            }
        }
    }

    private func setupScoreLabel() {
        scoreLabel = UILabel()
        scoreLabel.frame = CGRect(x: 20, y: 40, width: 200, height: 40)
        scoreLabel.text = "Score: \(score)"
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(scoreLabel)
    }

    private func setupResetButton() {
        let resetButton = UIButton(type: .system)
        resetButton.frame = CGRect(x: view.frame.width - 120, y: 40, width: 100, height: 40)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(UIColor(hex: "295F98"), for: .normal)
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        resetButton.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        view.addSubview(resetButton)
    }



    @objc private func cardTapped(_ sender: UIButton) {
        let index = sender.tag

        guard !cards[index].isMatched, !cards[index].isFlipped else { return }

        flipCard(at: index)

        if let firstIndex = firstFlippedCardIndex {
            checkForMatch(at: firstIndex, with: index)
            firstFlippedCardIndex = nil
        } else {
            firstFlippedCardIndex = index
        }
    }

    private func flipCard(at index: Int) {
        cards[index].isFlipped = true
        let button = cardButtons[index]
        let imageName = cards[index].imageName
        button.setBackgroundImage(UIImage(named: imageName), for: .normal)
        UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            button.backgroundColor = .white
        }, completion: nil)
    }

    private func flipBackCards(at firstIndex: Int, _ secondIndex: Int) {
        cards[firstIndex].isFlipped = false
        cards[secondIndex].isFlipped = false

        let firstButton = cardButtons[firstIndex]
        let secondButton = cardButtons[secondIndex]

        UIView.transition(with: firstButton, duration: 0.3, options: .transitionFlipFromRight, animations: {
            firstButton.setBackgroundImage(nil, for: .normal)
            firstButton.backgroundColor = UIColor(hex: "295F98")
        }, completion: nil)

        UIView.transition(with: secondButton, duration: 0.3, options: .transitionFlipFromRight, animations: {
            secondButton.setBackgroundImage(nil, for: .normal)
            secondButton.backgroundColor = UIColor(hex: "295F98")
        }, completion: nil)
    }

    private func checkForMatch(at firstIndex: Int, with secondIndex: Int) {
        if cards[firstIndex].imageName == cards[secondIndex].imageName {
            cards[firstIndex].isMatched = true
            cards[secondIndex].isMatched = true
            score += 1
            scoreLabel.text = "Score: \(score)"
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.flipBackCards(at: firstIndex, secondIndex)
            }
        }
    }

    @objc private func resetGame() {
        cardButtons.forEach { $0.removeFromSuperview() }
        cardButtons.removeAll()
        cards.removeAll()
        score = 0
        scoreLabel.text = "Score: \(score)"
        firstFlippedCardIndex = nil
        setupGame()
    }
}

// Extension to create UIColor from hex code
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
