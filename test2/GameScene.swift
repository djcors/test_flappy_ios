//
//  GameScene.swift
//  test2
//
//  Created by Jonathan on 14/05/15.
//  Copyright (c) 2015 Jonathan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var personaje = SKSpriteNode()
    
    let TotalPiezasFondo = 5
    var PiezasFondo = [SKSpriteNode]()
    
    let VelocidadSuelo: CGFloat = 3.5
    var AccionMoverFondo: SKAction!
    var AccionMoverFondoForever: SKAction!
    let ReiniciarFondo: CGFloat = -242.2
    
    /* Construimos el fondo */
    func ConstructorEscenario(){
        //println("Ancho del dispositivo \(self.view!.frame.size.width)")
        var bg = SKSpriteNode(imageNamed: "fondo")
        bg.position = CGPointMake(bg.size.width / 2, bg.size.height / 2)
        
        self.addChild(bg)
        
        var monte = SKSpriteNode(imageNamed: "montes")
        monte.position = CGPointMake(monte.size.width / 2, 350)
        
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
            
            self.addChild(sprite)
        }
    
    }
    
    func initSetup()
    {
        AccionMoverFondo = SKAction.moveByX(-VelocidadSuelo, y: 0, duration: 0.02)
        AccionMoverFondoForever = SKAction.repeatActionForever(SKAction.sequence([AccionMoverFondo]))
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
        self.addChild(personaje)
    }
    
    override func didMoveToView(view: SKView) {
        ConstructorEscenario()
        initSetup()
        SetupPersonaje()
        startGame()
        
        
        
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
            }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        groundMovement()
    }
}
