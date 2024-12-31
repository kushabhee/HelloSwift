import SceneKit
import QuartzCore

// Physics Categories for collision detection
struct PhysicsCategory {
    static let glider: Int = 1
    static let star: Int = 2
    static let cloud: Int = 4
}

class GameViewController: NSViewController, SCNPhysicsContactDelegate {
    var glider: SCNNode! // Glider reference
    var score = 0        // To track score
    var scoreLabel: NSTextField! // UI Label for score

    override func viewDidLoad() {
        super.viewDidLoad()

        // Step 1: Create a new SceneKit scene
        let scene = SCNScene()

        // Step 2: Add a camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 5, 15)
        scene.rootNode.addChildNode(cameraNode)

        // Step 3: Add lighting
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(lightNode)

        // Step 4: Add the glider
        glider = SCNNode(geometry: SCNPyramid(width: 1, height: 0.5, length: 2))
        glider.geometry?.firstMaterial?.diffuse.contents = NSColor.red
        glider.position = SCNVector3(0, 0, -5)
        glider.name = "glider"
        glider.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        glider.physicsBody?.categoryBitMask = PhysicsCategory.glider
        glider.physicsBody?.contactTestBitMask = PhysicsCategory.star | PhysicsCategory.cloud
        scene.rootNode.addChildNode(glider)

        // Step 5: Add clouds (some moving)
        for _ in 0..<5 {
            let cloud = createCloud(position: SCNVector3(Float.random(in: -10...10), 5, Float.random(in: -10...10)))
            scene.rootNode.addChildNode(cloud)
        }

        // Step 6: Add stars (collectibles)
        for _ in 0..<10 {
            let star = createStar(position: SCNVector3(Float.random(in: -10...10), Float.random(in: 1...10), Float.random(in: -10...10)))
            scene.rootNode.addChildNode(star)
        }

        // Step 7: Add a score label
        scoreLabel = NSTextField(labelWithString: "Score: 0")
        scoreLabel.font = NSFont.systemFont(ofSize: 24)
        scoreLabel.textColor = .white
        scoreLabel.backgroundColor = .clear
        scoreLabel.frame = CGRect(x: 20, y: Int(view.frame.height) - 40, width: 200, height: 40)
        view.addSubview(scoreLabel)

        // Configure the SceneKit view
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.backgroundColor = NSColor.blue
        scnView.scene?.physicsWorld.contactDelegate = self
    }

    // Function to create clouds (some with movement)
    func createCloud(position: SCNVector3) -> SCNNode {
        let cloud = SCNNode(geometry: SCNSphere(radius: 2.0))
        cloud.geometry?.firstMaterial?.diffuse.contents = NSColor.white.withAlphaComponent(0.8)
        cloud.position = position
        cloud.name = "cloud"
        cloud.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        cloud.physicsBody?.categoryBitMask = PhysicsCategory.cloud

        // Add movement for some clouds
        let moveAction = SCNAction.moveBy(x: 0, y: -10, z: 0, duration: 5)
        cloud.runAction(SCNAction.repeatForever(moveAction))

        return cloud
    }

    // Function to create stars
    func createStar(position: SCNVector3) -> SCNNode {
        let star = SCNNode(geometry: SCNSphere(radius: 0.5))
        star.geometry?.firstMaterial?.diffuse.contents = NSColor.yellow
        star.position = position
        star.name = "star"
        star.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        star.physicsBody?.categoryBitMask = PhysicsCategory.star
        return star
    }

    // Function to handle keyboard input for glider movement
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 126: // Up arrow
            glider.position.y += 1
        case 125: // Down arrow
            glider.position.y -= 1
        case 123: // Left arrow
            glider.position.x -= 1
        case 124: // Right arrow
            glider.position.x += 1
        default:
            break
        }
    }

    // Function to update the score
    func updateScore(by points: Int) {
        score += points
        scoreLabel.stringValue = "Score: \(score)"
    }

    // Collision detection
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB

        if nodeA.name == "glider" && nodeB.name == "star" {
            nodeB.removeFromParentNode() // Remove the star
            updateScore(by: 10)         // Update score
        } else if nodeA.name == "star" && nodeB.name == "glider" {
            nodeA.removeFromParentNode() // Remove the star
            updateScore(by: 10)         // Update score
        }
    }
}

