//
//  StartPageViewController.swift
//  TicTacToe
//
//  Created by Aaron Boswell on 5/21/16.
//  Copyright © 2016 Aaron Boswell. All rights reserved.
//

import UIKit
import GameKit
class StartPageViewController: UIViewController, GKTurnBasedMatchmakerViewControllerDelegate {
    @IBOutlet weak var gameCenterButton: UIButton!
    override func viewDidLoad() {
        authenticatePlayer()
    }
    var match:GKTurnBasedMatch?
    func authenticatePlayer(){
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = { (viewController : UIViewController?, error : NSError?) in
            if let vc = viewController{
                self.showViewController(vc, sender: self)
            } else if localPlayer.authenticated{
                
                self.gameCenterButton.enabled = true
                print("authenticated")
                
            }
        }
    }
    @IBAction func startGCGame(sender: AnyObject) {
        var request = GKMatchRequest()
        request.maxPlayers = 2
        request.minPlayers = 2
        request.defaultNumberOfPlayers = 2
        var vc = GKTurnBasedMatchmakerViewController.init(matchRequest: request)
        vc.turnBasedMatchmakerDelegate = self
        self.showViewController(vc, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "computer" {
            if let destination = segue.destinationViewController as? TicTacToeViewController{
                destination.computerControlled = true
            }
        }
        if segue.identifier == "gamecenter" {
            if let destination = segue.destinationViewController as? TicTacToeViewController{
                destination.match = match
            }
        }
        print(segue.identifier)
    }
    
    func turnBasedMatchmakerViewControllerWasCancelled(viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)

    }
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: NSError) {
        viewController.dismissViewControllerAnimated(true, completion: nil)

    }
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController, didFindMatch match: GKTurnBasedMatch) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        //match.
        for player in match.participants!{
            print(player.player?.displayName)
            
        }
        self.match = match
        performSegueWithIdentifier("gamecenter", sender: self)
    }
    

}
