//
//  RegisterNickViewController.swift
//  Ultimate Noughts & Crosses iOS
//
//  Created by Kyle Jessup on 2016-04-26.
//  Copyright © 2016 PerfectlySoft. All rights reserved.
//

import UIKit

let nickRegisteredSegue = "nickRegistered"

class RegisterNickViewController: UIViewController {

	@IBOutlet weak var nickText: UITextField!
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		var gameState = GameStateClient()
		if let playerId = gameState.savedPlayerId {
			// validate it
			gameState.getPlayerNick(playerId: playerId) {
				response in
				
				DispatchQueue.main.async() {
					if case .successString(let nick) = response {
						GameStateClient.retrievedPlayerNick = nick
						self.performSegue(withIdentifier: nickRegisteredSegue, sender: nil)
					} else if case .error(-1004, let msg) = response {
						
						let alert = UIAlertController(title: "Error Contacting Server", message: "\(msg) (-1004)", preferredStyle: .alert)
						let action = UIAlertAction(title: "OK", style: .default) { _ in }
						alert.addAction(action)
						self.present(alert, animated: true) { }
						
					} else {
						// player id was not valid. reset it
						gameState.savedPlayerId = nil
					}
				}
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func registerNick() {
    if let nickText = self.nickText.text {
      
      if !nickText.isEmpty {
        var gameState = GameStateClient()
			
        gameState.createPlayer(nick: nickText) {
          response in
				
          DispatchQueue.main.async() {
					
            if case .successInt(let playerId) = response {
              gameState.savedPlayerId = playerId
              self.performSegue(withIdentifier: nickRegisteredSegue, sender: nil)
            } else if case .error(let code, let msg) = response {
						
              let alert = UIAlertController(title: "Error registering nick", message: "\(msg) (\(code))", preferredStyle: .alert)
              let action = UIAlertAction(title: "OK", style: .default) { _ in }
              alert.addAction(action)
              self.present(alert, animated: true) { }
						
            } else {

              let alert = UIAlertController(title: "Error registering nick", message: "Unexpected response type \(response)", preferredStyle: .alert)
              let action = UIAlertAction(title: "OK", style: .default) { _ in }
              alert.addAction(action)
              self.present(alert, animated: true) { }
            }
          }
        }
      }
		}
	}
}
