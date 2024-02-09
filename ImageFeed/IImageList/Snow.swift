import UIKit

class SnowView: UIView {

    let snowflakeEmitter = CAEmitterLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupSnowfall() {
        snowflakeEmitter.emitterPosition = CGPoint(x: bounds.width, y: 0)
        snowflakeEmitter.emitterSize = CGSize(width: bounds.width, height: 1)
        snowflakeEmitter.emitterShape = .circle
        snowflakeEmitter.emitterCells = generateSnowflakes()
        snowflakeEmitter.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(snowflakeEmitter)
    }

    func animateSnowfall() {
        snowflakeEmitter.emitterCells = generateSnowflakes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.snowflakeEmitter.birthRate = 0 // Прекращаем генерацию новых снежинок
        }
    }

    private func generateSnowflakes() -> [CAEmitterCell] {
        var snowflakes = [CAEmitterCell]()

        let snowflake = CAEmitterCell()
        snowflake.birthRate = 2
        snowflake.lifetime = 120
        snowflake.velocity = 10
        snowflake.velocityRange = 20
        snowflake.yAcceleration = 10
        snowflake.emissionRange = .pi
        snowflake.spin = 1
        snowflake.spinRange = 1.0
        snowflake.scale = CGFloat.random(in: 0.5...2)
        snowflake.contents = UIImage(named: "Active")?.cgImage
        snowflake.color = UIColor.white.withAlphaComponent(0.5).cgColor
        
        let snowflakeTwo = CAEmitterCell()
        snowflakeTwo.birthRate = 2
        snowflakeTwo.lifetime = 120
        snowflakeTwo.velocity = 10
        snowflakeTwo.velocityRange = 20
        snowflakeTwo.yAcceleration = 10
        snowflakeTwo.emissionRange = .pi
        snowflakeTwo.spin = 1
        snowflakeTwo.spinRange = 1.0
        snowflake.scale = CGFloat.random(in: 0.5...2)
        snowflakeTwo.contents = UIImage(named: "NoActive")?.cgImage
        snowflakeTwo.color = UIColor.white.withAlphaComponent(0.5).cgColor

        snowflakes.append(snowflake)
        snowflakes.append(snowflakeTwo)

        return snowflakes
    }
}
