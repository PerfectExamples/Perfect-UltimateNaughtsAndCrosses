//
//  JoinGameViewController.swift
//  Ultimate Noughts & Crosses iOS
//
//  Created by Kyle Jessup on 2016-04-26.
//  Copyright © 2016 PerfectlySoft. All rights reserved.
//

import UIKit

class JoinGameViewController: UIViewController {

	var waiting = false
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let gameState = GameStateClient()
		if let playerId = gameState.savedPlayerId {
			gameState.createGame(playerId: playerId, gameType: PlayerType.MultiPlayer) {
				response in
				
        DispatchQueue.main.async {
					
					if case .successInt(let gameId) = response {
						
						if gameId != invalidId {
							self.dismiss(animated: true) {}
						} else {
							self.startWaiting()
						}
						
					} else if case .error(let code, let msg) = response {
						
						let alert = UIAlertController(title: "Error Starting Game", message: "\(msg) (\(code))", preferredStyle: .alert)
						let action = UIAlertAction(title: "OK", style: .default) { _ in self.dismiss(animated: true) {} }
						alert.addAction(action)
						self.present(alert, animated: true) { }
						
					} else {
						
						let alert = UIAlertController(title: "Error Starting Game", message: "Unexpected response type \(response)", preferredStyle: .alert)
						let action = UIAlertAction(title: "OK", style: .default) { _ in self.dismiss(animated: true) {} }
						alert.addAction(action)
						self.present(alert, animated: true) { }
					}
				}
			}
		}
	}
	
	@IBAction func stopWaiting() {
		let gameState = GameStateClient()
		gameState.concedeGame {
			response in
			
			DispatchQueue.main.async {
				self.dismiss(animated: true) {}
			}
		}
	}
	
	func startWaiting() {
		self.waiting = true
		self.checkStatus()
	}
	
	func checkStatus() {
		guard self.waiting else {
			return
		}
		
		let gameState = GameStateClient()
		if let playerId = gameState.savedPlayerId {
			gameState.getActiveGame(playerId: playerId) { [weak self]
				response in
				
				guard let me = self else {
					return
				}
				
				if case .successInt2(let gameId, _) = response
        {
          if gameId != invalidId
          {
            me.waiting = false
            DispatchQueue.main.async {
              me.dismiss(animated: true) {}
            }
          }
				} else {
					me.queueStatusCheck()
				}
			}
		}
	}
	
	func queueStatusCheck() {
		guard self.waiting else {
			return
		}
		
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      	self.checkStatus()
		}
	}
}
