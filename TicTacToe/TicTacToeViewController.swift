//
//  ViewController.swift
//  TicTacToe
//
//  Created by Aaron Boswell on 5/19/16.
//  Copyright © 2016 Aaron Boswell. All rights reserved.
//

import UIKit
import GameKit
class TicTacToeViewController: UIViewController,GKLocalPlayerListener {

    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    var game = TicTacToeGame()
    
    var computerControlled = false
    
    var match:GKTurnBasedMatch?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        GKLocalPlayer.localPlayer().registerListener(self)
        for label in labels{
            
            //put borders between the labels
            if !(label.tag % 3 == 2){
                label.setBorder(.Right, width: 5, color: UIColor.blackColor())
            }
            if !(label.tag % 3 == 0){
                label.setBorder(.Left, width: 5, color: UIColor.blackColor())
            }
            if !(label.tag < 3){
                label.setBorder(.Top, width: 5, color: UIColor.blackColor())
            }
            if !(label.tag > 5){
                label.setBorder(.Bottom, width: 5, color: UIColor.blackColor())
            }
            
            //add gesture recognizer to each label
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TicTacToeViewController.spotTapped(_:)))
            gestureRecognizer.numberOfTouchesRequired = 1
            label.addGestureRecognizer(gestureRecognizer)
        }
        refreshMatch()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func player(player: GKPlayer, receivedTurnEventForMatch match: GKTurnBasedMatch, didBecomeActive: Bool) {
        print("matchUpdate")
        refreshMatch()
        
    }
    func player(player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        refreshMatch()
    }
    func refreshMatch(){
        print("refreshing match")
        if let m = match{
            print("match exists")
            
            m.loadMatchDataWithCompletionHandler({ (data:NSData?, error:NSError?) in
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    var stuff = json as! [String]
                    self.game.turn = stuff.last!
                    stuff.removeLast()
                    self.game.board = stuff
                    if self.match!.status == .Ended{
                        self.game.turn = (self.game.turn == "X") ? "O" : "X"
                    }
                    self.game.checkWin()
                    self.refreshDisplay()
                    print("loaded")
                }catch{
                    print("Error")
                }
                
                }
            )
        }
    }
    func spotTapped(gestureRecognizer:UITapGestureRecognizer){
        if let m = match{
            print("in match")
            print(m.currentParticipant?.player?.playerID)
            print(GKLocalPlayer.localPlayer().playerID)
            if m.currentParticipant?.player?.playerID == GKLocalPlayer.localPlayer().playerID {
                print("currentPlayer")

                let label = gestureRecognizer.view as! UILabel
                let turn = game.turn
                game.play(label.tag)
                
                refreshDisplay()
                if game.gameOver{
                    print("sendGameOver")
                    do{
                        var board = game.board
                        board.append(game.turn)
                        if let win = game.winner{
                            m.currentParticipant?.matchOutcome = .Won
                            var other = m.participants!
                            other.removeAtIndex(other.indexOf(m.currentParticipant!)!)
                            other.first!.matchOutcome = .Lost
                        }else{
                            m.currentParticipant?.matchOutcome = .Tied
                            var other = m.participants!
                            other.removeAtIndex(other.indexOf(m.currentParticipant!)!)
                            other.first!.matchOutcome = .Tied
                        }
                        let data =  try NSJSONSerialization.dataWithJSONObject(board, options: .PrettyPrinted)
                        m.endMatchInTurnWithMatchData(data, completionHandler: nil)
                        
                        print("commited data")
                        
                    }catch{
                        print("ERROR")
                    }
                }else
                    if game.turn != turn {
                    print("turn happened")
                    do{
                        var board = game.board
                        board.append(game.turn)
                         let data =  try NSJSONSerialization.dataWithJSONObject(board, options: .PrettyPrinted)
                        
                        var ordered = m.participants!
                        ordered.removeAtIndex(ordered.indexOf(m.currentParticipant!)!)
                        ordered.append(m.currentParticipant!)
                        
                        m.endTurnWithNextParticipants(ordered, turnTimeout:1000 , matchData: data, completionHandler:nil)
                        
                        print("commited data")
                        
                    }catch{
                        print("ERROR")
                    }
                    
                }
            }
            return
        }
        //disable interaction while computer is taking their turn
        if game.turn == "O" && computerControlled{
            return
        }
        
        let label = gestureRecognizer.view as! UILabel
        game.play(label.tag)
        refreshDisplay()
        
        
        //if its time for the computer's turn, take it
        if game.turn == "O" && computerControlled{
            takeComputerTurn()
        }
        print(computerControlled)
    }
    func takeComputerTurn(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[unowned self] in
            let bestMove = self.game.bestMove()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                self.game.play(bestMove)
                self.refreshDisplay()
            })
        }
    }

    @IBAction func Restart(sender: AnyObject) {
        if let m = match{
            m.rematchWithCompletionHandler({ (newMatch:GKTurnBasedMatch?, error:NSError?) in
                self.match = newMatch
                self.refreshMatch()
            })
        }
        game = TicTacToeGame()
        refreshDisplay()
        
    }
    func refreshDisplay(){
        for (index,spot) in game.board.enumerate(){
            labels[index].text = spot
        }
        if game.gameOver {
            if let winner = game.winner{
                messageLabel.text = "\(winner) has won!"
            } else{
                messageLabel.text = "The game is a draw."

            }
        }else{
            if computerControlled{
                if game.turn == "O"{
                    messageLabel.text = "The computer is taking its turn."
                }else{
                    messageLabel.text = "Your turn."
                }
            }else{
                messageLabel.text = "\(game.turn)'s turn."
            }
        }
        tryAgainButton.hidden = !game.gameOver
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//following code moddified from http://stackoverflow.com/a/36460855 thatjuan's response. Allows for borders on any side of a UILabel
enum UILabelBorder {
    case Left
    case Right
    case Top
    case Bottom
}

extension UILabel {
    
    func setBorder( border: UILabelBorder, width: Float, color: UIColor ){
        
        let lineView: UIView
        
        lineView = UIView()
        self.addSubview(lineView)
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        
        switch border {
            
        case .Left:
            lineView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 0).active = true
            lineView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 0).active = true
            lineView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 0).active = true
            lineView.widthAnchor.constraintEqualToConstant(CGFloat(width)).active = true
            break
            
        case .Right:
            lineView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 0).active = true
            lineView.leftAnchor.constraintEqualToAnchor(self.rightAnchor, constant: 0).active = true
            lineView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 0).active = true
            lineView.widthAnchor.constraintEqualToConstant(CGFloat(width)).active = true
            
            break
            
        case .Top:
            lineView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 0).active = true
            lineView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 0).active = true
            lineView.widthAnchor.constraintEqualToAnchor(self.widthAnchor, constant: 0).active = true
            lineView.heightAnchor.constraintEqualToConstant(CGFloat(width)).active = true
            
            break
            
        case .Bottom:
            lineView.topAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 0).active = true
            lineView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 0).active = true
            lineView.widthAnchor.constraintEqualToAnchor(self.widthAnchor, constant: 0).active = true
            lineView.heightAnchor.constraintEqualToConstant(CGFloat(width)).active = true
            break
            
        }
        
        
        
    }
    
}