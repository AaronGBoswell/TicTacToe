//
//  StartPageViewController.swift
//  TicTacToe
//
//  Created by Aaron Boswell on 5/21/16.
//  Copyright © 2016 Aaron Boswell. All rights reserved.
//

import UIKit

class StartPageViewController: UIViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "computer" {
            if let destination = segue.destinationViewController as? TicTacToeViewController{
                destination.computerControlled = true
            }
        }
        print(segue.identifier)
    }
}
