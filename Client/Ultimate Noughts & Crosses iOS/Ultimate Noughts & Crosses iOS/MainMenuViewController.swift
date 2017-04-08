//
//  MainMenuViewController.swift
//  Ultimate Noughts & Crosses iOS
//
//  Created by Kyle Jessup on 2016-04-28.
//  Copyright © 2016 PerfectlySoft. All rights reserved.
//

import UIKit

let playGameSegue = "playGame"
let joinGameSegue = "joinGame"

class MainMenuViewController: UIViewController {

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

        let gameState = GameStateClient()
		if let playerId = gameState.savedPlayerId {
			gameState.getActiveGame(playerId: playerId) {
				responseValue in
				
				if case .successInt2(let gameId, _) = responseValue {
					if gameId != invalidId {
						// let's continue playing
						DispatchQueue.main.async() {
							self.performSegue(withIdentifier: playGameSegue, sender: nil)
						}
					} else {
						
					}
				} else {
					
				}
			}
		}
    }
	
	@IBAction func joinGame() {
		self.performSegue(withIdentifier: joinGameSegue, sender: nil)
	}
	
	@IBAction func botGame() {
		let gs = GameStateClient()
		if let playerId = gs.savedPlayerId {
		
			gs.createGame(playerId: playerId, gameType: PlayerType.Bot) {
				response in
				
				DispatchQueue.main.async {
					
					if case .successInt(_) = response {
						self.performSegue(withIdentifier: playGameSegue, sender: nil)
					} else if case .error(let code, let msg) = response {
						
						let alert = UIAlertController(title: "Error Starting Game", message: "\(msg) (\(code))", preferredStyle: .alert)
						let action = UIAlertAction(title: "OK", style: .default) { _ in }
						alert.addAction(action)
						self.present(alert, animated: true) { }
						
					} else {
						
						let alert = UIAlertController(title: "Error Starting Game", message: "Unexpected response type \(response)", preferredStyle: .alert)
						let action = UIAlertAction(title: "OK", style: .default) { _ in }
						alert.addAction(action)
						self.present(alert, animated: true) { }
					}
				}
			}
		}
	}
}
