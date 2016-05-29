//
//  TicTacToeGame.swift
//  TicTacToe
//
//  Created by Aaron Boswell on 5/19/16.
//  Copyright © 2016 Aaron Boswell. All rights reserved.
//

import Foundation

func == (left:TicTacToeGame, right:TicTacToeGame) ->Bool{
    for index in 0...left.board.count - 1 {
        if(left.board[index] != right.board[index]){
            return false
        }
    }
    if left.turn != right.turn{
        return false
    }
    return true
}

//Struct so it is pass by copy
struct TicTacToeGame {
    var turn:String = "X"
    var board:[String] = [String].init(count: 9, repeatedValue: "")
    
    //publically read only
    
    var winner:String?
    var gameOver = false
    
    mutating func play(index:Int){
        if gameOver{
            return
        }
        if board[index] == "" {
            board[index] = turn
            checkWin()
            turn = (turn == "X") ? "O" : "X"
        }
    }
    
    
    mutating func checkWin(){
        if( (board[0] == board[1] && board[1] == board[2]) && board[0] != "" || //check horizontal 1
            (board[3] == board[4] && board[4] == board[5]) && board[3] != "" || //check horizontal 2
            (board[6] == board[7] && board[7] == board[8]) && board[6] != "" || //check horizontal 3
            (board[0] == board[3] && board[3] == board[6]) && board[0] != "" || //check verticle 1
            (board[1] == board[4] && board[4] == board[7]) && board[1] != "" || //check verticle 2
            (board[2] == board[5] && board[5] == board[8]) && board[2] != "" || //check verticle 3
            (board[0] == board[4] && board[4] == board[8]) && board[0] != "" || //check diagonal 1
            (board[2] == board[4] && board[4] == board[6]) && board[2] != "" ){ //check diagonal 1
           
            winner = turn
            
        }
        
        var draw = true
        for spot in board{
            if spot == ""{
                draw = false
            }
        }
        gameOver = draw || winner != nil
    }
    

    var miniMaxValue:Int{
        get{
            //basecase
            if gameOver{
                if let win = winner{
                    var score = 15
                    for spot in board{
                        if !spot.isEmpty {
                            score = score - 1
                        }
                    }
                    return win == "X" ? score : -score

                }
                
                return 0
            }
            
            var score = turn == "X" ? -100 : 100

            //advance all posible next games
            //then pass along their score
            let allPosibleNextGames = [TicTacToeGame].init(count: 9, repeatedValue: self)
            for (index,var g) in allPosibleNextGames.enumerate(){
                g.play(index)
                if g == self{
                    continue
                }
                if turn == "X"{
                    if g.miniMaxValue > score{
                        score = g.miniMaxValue
                    }
                }else{
                    if g.miniMaxValue < score{
                        score = g.miniMaxValue
                    }
                }
            }
            return score
            
        }
    }
    
    
    func bestMove() -> Int{
        var bestScore = turn == "X" ? -100 : 100
        var i = -1
        //create all posible next games
        //then determine which has the best score, return the index of the score
        let allPosibleNextGames = [TicTacToeGame].init(count: 9, repeatedValue: self)
        for (index,var g) in allPosibleNextGames.enumerate(){
            g.play(index)
            if g == self{
                continue
            }
            if turn == "X"{
                if g.miniMaxValue > bestScore{
                    i = index
                    bestScore = g.miniMaxValue
                }
            }else{
                if g.miniMaxValue < bestScore{
                    i = index
                    bestScore = g.miniMaxValue
                }
            }
        }
        return i
    }

}