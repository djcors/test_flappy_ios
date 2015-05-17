//
//  GameScene.swift
//  test2
//
//  Created by Jonathan on 14/05/15.
//  Copyright (c) 2015 Jonathan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var personaje = SKSpriteNode()
    let monteYPos: CGFloat = 300
    let TotalPiezasFondo = 5
    var PiezasFondo = [SKSpriteNode]()
    
    let VelocidadSuelo: CGFloat = 3.5
    var AccionMoverFondo: SKAction!
    var AccionMoverFondoForever: SKAction!
    let ReiniciarFondo: CGFloat = -164
    
    var Tubo1 = SKTexture()
    var Tubo2 = SKTexture()
    var SeparacionTubos = 180.0
    
    var isJumping = false
    var touchDetected = false
    var jumpStartTime: CGFloat = 0.0
    var jumpCurrentTime: CGFloat = 0.0
    var jumpEndTime: CGFloat = 0.0
    let jumpDuration: CGFloat = 0.5
    let jumpVelocity: CGFloat = 600.0
    var currentVelocity: CGFloat = 0.0
    var jumpInertiaTime: CGFloat!
    var fallInertiaTime: CGFloat!
    var lastUpdateTimeInterval: CFTimeInterval = -1.0
    var deltaTime: CGFloat = 0.0
    let floor_distance: CGFloat = 72.0
    let FSBoundaryCategory: UInt32 = 1 << 0
    let FSPlayerCategory: UInt32   = 1 << 1
    let FSPipeCategory: UInt32     = 1 << 2
    let FSGapCategory: UInt32      = 1 << 3
    
    /* Construimos el fondo */
    func ConstructorEscenario(){
        //println("Ancho del dispositivo \(self.view!.frame.size.width)")
        var bg = SKSpriteNode(imageNamed: "fondo")
        bg.position = CGPointMake(bg.size.width / 2, bg.size.height / 2)
        
        self.addChild(bg)
        
        var monte = SKSpriteNode(imageNamed: "montes")
        monte.position = CGPointMake(monte.size.width / 2, monteYPos)
        
        self.addChild(monte)
        
        for var x = 0; x < TotalPiezasFondo; x++
        {
            var sprite = SKSpriteNode(imageNamed: "suelo")
            PiezasFondo.append(sprite)
            
            var wEspacio = sprite.size.width / 2
            var hEspacio = sprite.size.height / 2
            
            if x == 0
            {
                sprite.position = CGPointMake(wEspacio, hEspacio)
            }
            else
            {
                sprite.position = CGPointMake((wEspacio * 2) + PiezasFondo[x - 1].position.x,PiezasFondo[x - 1].position.y)
            }
            
            sprite.zPosition = 3
            var TopeSuelo = SKNode()
            TopeSuelo.position = CGPointMake(0, sprite.size.height/2)
            TopeSuelo.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake( self.frame.size.width, sprite.size.height) )
            TopeSuelo.physicsBody?.dynamic = false
            self.addChild(TopeSuelo)
            self.addChild(sprite)
        }
    
    }
    
    func initSetup()
    {
        jumpInertiaTime = CGFloat(jumpDuration) * 0.7
        fallInertiaTime = CGFloat(jumpDuration) * 0.3
        AccionMoverFondo = SKAction.moveByX(-VelocidadSuelo, y: 0, duration: 0.02)
        AccionMoverFondoForever = SKAction.repeatActionForever(SKAction.sequence([AccionMoverFondo]))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(6.0), SKAction.runBlock { self.SetupTubos()}])))
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0.0, y: floor_distance, width: size.width, height: size.height - floor_distance))
        physicsBody?.categoryBitMask = FSBoundaryCategory
        physicsBody?.collisionBitMask = FSPlayerCategory
    }
    
    func startGame()
    {
        for sprite in PiezasFondo
        {
            sprite.runAction(AccionMoverFondoForever)
        }
    }
    
    func groundMovement()
    {
        //println(PiezasFondo.count)
        for var x = 0; x < PiezasFondo.count; x++
        {
            if PiezasFondo[x].position.x <= ReiniciarFondo
            {
                if x != 0
                {
                    PiezasFondo[x].position = CGPointMake(PiezasFondo[x - 1].position.x + PiezasFondo[x].size.width,PiezasFondo[x].position.y)
                }
                else
                {
                    PiezasFondo[x].position = CGPointMake(PiezasFondo[PiezasFondo.count - 1].position.x + PiezasFondo[x].size.width,PiezasFondo[x].position.y)
                }
            }
        }
    }
    
    /* construye personaje */
    func SetupPersonaje(){
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)

        var TexturaPersonaje1 = SKTexture(imageNamed: "ave1")
        TexturaPersonaje1.filteringMode = SKTextureFilteringMode.Nearest
        var TexturaPersonaje2 = SKTexture(imageNamed: "ave2")
        TexturaPersonaje2.filteringMode = SKTextureFilteringMode.Nearest
        
        /* animación de las alas */
        var AnimacionAlas =
        SKAction.animateWithTextures([TexturaPersonaje1, TexturaPersonaje2], timePerFrame: 0.2)
        var vuelo = SKAction.repeatActionForever(AnimacionAlas)
        
        personaje = SKSpriteNode(texture: TexturaPersonaje1)
        personaje.position = CGPoint(x: self.frame.size.width / 3.8, y: CGRectGetMidY(self.frame))
        
        personaje.runAction(vuelo)
        personaje.physicsBody = SKPhysicsBody(circleOfRadius: personaje.size.height/2)
        personaje.physicsBody?.dynamic = true
        personaje.physicsBody?.allowsRotation = true
        personaje.zPosition = 3
        self.addChild(personaje)
    }
    
    func SetupTubos(){
        
        
        var Altura = UInt(self.frame.size.height / 3)
        var y = UInt(arc4random()) % Altura
        
        Tubo1 = SKTexture(imageNamed: "tubo1")
        Tubo1.filteringMode = SKTextureFilteringMode.Nearest
        
        Tubo2 = SKTexture(imageNamed: "tubo2")
        Tubo2.filteringMode = SKTextureFilteringMode.Nearest
        
        var ConjutoTubo = SKNode()
        ConjutoTubo.position = CGPointMake(self.frame.size.width + Tubo1.size().width * 2, 0)
        
        var tub1 = SKSpriteNode(texture: Tubo1)
        tub1.position = CGPointMake(0.0, CGFloat(y))
        tub1.physicsBody = SKPhysicsBody(rectangleOfSize: tub1.size)
        tub1.physicsBody?.dynamic = false
        
        ConjutoTubo.addChild(tub1)
        
        var tub2 = SKSpriteNode(texture: Tubo2)
        tub2.position = CGPointMake(0.0, CGFloat(y) + tub1.size.height + CGFloat(SeparacionTubos) )
        tub2.physicsBody = SKPhysicsBody(rectangleOfSize: tub2.size)
        tub2.physicsBody?.dynamic = false
        
        ConjutoTubo.addChild(tub2)
        
        var DistanciaMov = CGFloat(self.frame.size.width + Tubo1.size().width * 2.0 )
        var movimientoTubo = SKAction.moveByX(-DistanciaMov , y: 0.0, duration: NSTimeInterval(0.008 * DistanciaMov))
        
        var EliminarTubo = SKAction.removeFromParent()
        var CotrolTubo = SKAction.sequence([movimientoTubo, EliminarTubo])
        ConjutoTubo.runAction(CotrolTubo)
        ConjutoTubo.zPosition = 1
        
        self.addChild(ConjutoTubo)
    }

    
    override func didMoveToView(view: SKView) {
        
        ConstructorEscenario()
        initSetup()
        SetupPersonaje()
        startGame()
        SetupTubos()
        
        
        
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Activamos touch */
        personaje.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 25))
        touchDetected = true
        isJumping = true
        
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        groundMovement()
        deltaTime = CGFloat(currentTime - lastUpdateTimeInterval)
        lastUpdateTimeInterval = currentTime
        
        if deltaTime > 1
        {
            deltaTime = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }
        
        if touchDetected
        {
            touchDetected = false
            jumpStartTime = CGFloat(currentTime)
            currentVelocity = jumpVelocity
        }
        
        if isJumping
        {
            //How long we have been jumping
            var currentDuration = CGFloat(currentTime) - jumpStartTime
            
            //Time to end the jump
            if currentDuration >= jumpDuration
            {
                isJumping = false
                jumpEndTime = CGFloat(currentTime)
            }
            else
            {
                //Rotate the bird to a certain euler angle over a certain period of time
                if personaje.zRotation < 0.5
                {
                    personaje.zRotation += 2.0 * CGFloat(deltaTime)
                }
                
                //Move the bird up
                personaje.position = CGPointMake(personaje.position.x, personaje.position.y + (currentVelocity * CGFloat(deltaTime)))
                
                //We don't decrease velocity until after the initial jump inertia has taken place
                if CGFloat(currentDuration) > jumpInertiaTime
                {
                    currentVelocity -= (currentVelocity * CGFloat(deltaTime)) * 3
                }
                
            }
        }
        else //If we aren't jumping then we are falling
        {
            //Rotate the bird to a certain euler angle over a certain period of time
            if personaje.zRotation > -0.5
            {
                personaje.zRotation -= 2.0 * CGFloat(deltaTime)
            }
            
            //Move the bird down
            personaje.position = CGPointMake(personaje.position.x, personaje.position.y - (currentVelocity * CGFloat(deltaTime)))
            
            //Only start increasing velocity after floating for a little bit
            if CGFloat(currentTime) - jumpEndTime > fallInertiaTime
            {
                currentVelocity += currentVelocity * CGFloat(deltaTime)
            }
        }
    }
}
