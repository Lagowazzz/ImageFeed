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
        snowflakeEmitter.emitterPosition = CGPoint(x: bounds.width / 2, y: 0)
        snowflakeEmitter.emitterSize = CGSize(width: bounds.width, height: 1)
        snowflakeEmitter.emitterShape = .line
        snowflakeEmitter.emitterCells = generateSnowflakes()
        snowflakeEmitter.backgroundColor = UIColor.clear.cgColor  // Установите цвет фона в прозрачный
        layer.addSublayer(snowflakeEmitter)
    }


    func generateSnowflakes() -> [CAEmitterCell] {
        var snowflakes = [CAEmitterCell]()

        let snowflake = CAEmitterCell()
        snowflake.birthRate = 5
        snowflake.lifetime = 120
        snowflake.velocity = 10
        snowflake.velocityRange = 20
        snowflake.yAcceleration = 3
        snowflake.emissionRange = .pi
        snowflake.spin = 1
        snowflake.spinRange = 1.0
        snowflake.scale = 0.5
        snowflake.contents = UIImage(named: "Active")?.cgImage
        snowflake.color = UIColor.white.withAlphaComponent(0.5).cgColor
        
        let snowflakeTwo = CAEmitterCell()
        snowflakeTwo.birthRate = 5
        snowflakeTwo.lifetime = 120
        snowflakeTwo.velocity = 10
        snowflakeTwo.velocityRange = 20
        snowflakeTwo.yAcceleration = 3
        snowflakeTwo.emissionRange = .pi
        snowflakeTwo.spin = 1
        snowflakeTwo.spinRange = 1.0
        snowflakeTwo.scale = 0.5
        snowflakeTwo.contents = UIImage(named: "NoActive")?.cgImage
        snowflakeTwo.color = UIColor.white.withAlphaComponent(0.5).cgColor


        snowflakes.append(snowflake)
        snowflakes.append(snowflakeTwo)
        return snowflakes
    }
}

