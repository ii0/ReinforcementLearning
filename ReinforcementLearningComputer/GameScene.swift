//
//  GameScene.swift
//  ReinforcementLearningComputer
//
//  Created by Adnan Zahid on 12/29/16.
//  Copyright © 2016 Adnan Zahid. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, GridDelegate, AIDelegate {
    
    var aiSolver: AISolver?
    
    var grid: Grid?
    var gridView: GridView?
    
    var boxNodeArray: [[BoxNode?]] = [[BoxNode?]](repeating: [BoxNode?](repeating: nil, count: maxY + 1), count: maxX + 1)
    
    override func didMove(to view: SKView) {
        
        grid = Grid()
        grid?.gridDelegate = self
        
        gridView = GridView(blockSize: kBlockSize, rows: kNumberOfRows, columns: kNumberOfColumns)
        gridView?.position = CGPoint(x: 0.0, y: 0.0)
        addChild(gridView!)
        
        grid?.placeBoxArray()
        grid?.redrawBoxArray()
        
        aiSolver = AISolver()
        aiSolver?.delegate = self
        
        selectQueueAndRun(DispatchQueue.global(qos: DispatchQoS.QoSClass.default), action: { self.aiSolver?.calculateNextMove(grid: self.grid!) })
    }
    
    func didCalculateNextMove(box: Box) {
        
        self.selectQueueAndRun(DispatchQueue.main, action: {
            
            var direction: Direction?
            
            if box.x < self.grid!.selectedBox!.x {
                
                direction = Direction.Left
                
            } else if box.x > self.grid!.selectedBox!.x {
                
                direction = Direction.Right
                
            } else if box.y < self.grid!.selectedBox!.y {
                
                direction = Direction.Up
                
            } else if box.y > self.grid!.selectedBox!.y {
                
                direction = Direction.Down
            }
            
            let _ = self.grid?.takeTurn(direction: direction!)
            
            self.selectQueueAndRun(DispatchQueue.global(qos: DispatchQoS.QoSClass.default), action: { self.aiSolver?.calculateNextMove(grid: self.grid!) })
        })
    }
    
    func gameOver() {
        
        grid?.markEveryBoxUntraversed()
        
        selectQueueAndRun(DispatchQueue.global(qos: DispatchQoS.QoSClass.default), action: { self.aiSolver?.calculateNextMove(grid: self.grid!) })
    }
    
    func placeBox(box: Box) {
        
        let boxNode: BoxNode = BoxNode(blockSize: kBlockSize/3)
        boxNode.position = gridView!.gridPosition(row: box.y, column: box.x)
        gridView?.addChild(boxNode)
        
        boxNodeArray[box.x][box.y] = boxNode
    }
    
    func redrawBox(box: Box) {
        
        boxNodeArray[box.x][box.y]?.redraw(box: box)
    }
    
    func selectQueueAndRun(_ queue: DispatchQueue, action: @escaping () -> ()) {
        
        // Run on the following queue
        queue.async {
            
            // Run action
            action()
        }
    }
}













