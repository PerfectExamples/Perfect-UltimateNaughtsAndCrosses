//
//  UltimateState-Client.swift
//  Ultimate Noughts & Crosses iOS
//
//  Created by Kyle Jessup on 2016-04-25.
//  Copyright © 2016 PerfectlySoft. All rights reserved.
//

import Foundation

let requestRoot = "http://127.0.0.1:8181/"
//let requestRoot = "http://10.10.1.121:8181/"
let savedPlayerIdKey = "unc.saved.uid"

struct GameStateClient: GameState {
	
	static var retrievedPlayerNick: String?
	
	let session = URLSession.shared
	
	var savedPlayerId: Int? {
		get {
			if let playerId = UserDefaults.standard.value(forKey: savedPlayerIdKey) {
				return playerId as? Int
			}
			return nil
		}
		set(to) {
			let defaults = UserDefaults.standard
			if let playerId = to {
				defaults.setValue(playerId, forKey: savedPlayerIdKey)
			} else {
				defaults.removeObject(forKey: savedPlayerIdKey)
			}
			defaults.synchronize()
		}
	}
	
	func createPlayer(nick: String, response: @escaping (AsyncResponse) -> ()) {
		let request = self.urlRequest(endPoint: EndPoint.RegisterNick, args: [nick])
		self.performRequest(request: request) {
			responseValue in
			
			switch responseValue {
			case .successString(let str):
				if let validId = Int(str) {
					response(.successInt(validId))
				} else {
					response(.error(-1, "Invalid response from server: \(str)"))
				}
			default:
				response(responseValue)
			}
		}
	}
	
	func getPlayerNick(playerId: Int, response: @escaping (AsyncResponse) -> ()) {
		let request = self.urlRequest(endPoint: EndPoint.GetPlayerNick, args: [String(playerId)])
		self.performRequest(request: request) {
			responseValue in
			
			response(responseValue)
		}
	}
	
	func getCurrentState(playerId: Int, response: @escaping (AsyncResponse) -> ()) {
		let request = self.urlRequest(endPoint: EndPoint.GetGameStatus)
		self.performRequest(request: request) {
			responseValue in
			
			switch responseValue {
			case .successString(let str):
				if let state = UltimateState.deserialize(source: str) {
					response(.successState(state))
				} else {
					response(.error(-1, "Invalid response from server: \(str)"))
				}
			default:
				response(responseValue)
			}
		}
	}
	
	func createGame(playerId: Int, gameType: PlayerType, response: @escaping (AsyncResponse) -> ()) {
		let request = self.urlRequest(endPoint: EndPoint.StartGame, args: [String(gameType.rawValue)])
		self.performRequest(request: request) {
			responseValue in
			
			switch responseValue {
			case .successString(let str):
				if let gameId = Int(str) {
					response(.successInt(gameId))
				} else {
					response(.error(-1, "Invalid response from server: \(str)"))
				}
			default:
				response(responseValue)
			}
		}
	}
	
	func getActiveGame(playerId _: Int, response: @escaping (AsyncResponse) -> ()) {
		let request = self.urlRequest(endPoint: EndPoint.GetActiveGame)
		self.performRequest(request: request) {
			responseValue in
			
			if case .successString(let str) = responseValue {
                let split = str.characters.split(separator: " ")
				
				guard split.count == 2 else {
					return response(.error(-1, "Invalid response from server: \(str)"))
				}
				
				guard let gameId = Int(String(split[0])), let pieceId = Int(String(split[1])) else {
					return response(.error(-1, "Invalid response from server: \(str)"))
				}
				
				response(.successInt2(gameId, pieceId))
				
			} else {
				response(responseValue)
			}
		}
	}
	
	func playPieceOnBoard(playerId: Int, board: GridIndex, slotIndex: GridIndex, response: @escaping (AsyncResponse) -> ()) {
		let request = self.urlRequest(endPoint: EndPoint.MakeMove, args: ["\(board.x)", "\(board.y)", "\(slotIndex.x)", "\(slotIndex.y)"])
		self.performRequest(request: request) {
			responseValue in
			
			switch responseValue {
			case .successString(let str):
				if let state = UltimateState.deserialize(source: str) {
					response(.successState(state))
				} else {
					response(.error(-1, "Invalid response from server: \(str)"))
				}
			default:
				response(responseValue)
			}
		}
	}
	
	func concedeGame(response: @escaping (AsyncResponse) -> ()) {
		let request = self.urlRequest(endPoint: EndPoint.ConcedeGame)
		self.performRequest(request: request) {
			responseValue in
			
			switch responseValue {
			case .successString(let str):
				if let state = UltimateState.deserialize(source: str) {
					response(.successState(state))
				} else {
					response(.error(-1, "Invalid response from server: \(str)"))
				}
			default:
				response(responseValue)
			}
		}
	}
	
	private func urlRequest(endPoint: EndPoint, args: [String]? = nil) -> URLRequest {
		guard let url =  NSURL(string: "\(requestRoot)\(endPoint.replace(variables: args))") else {
			fatalError("Could not make NSURL out of \(requestRoot)\(endPoint.rawValue)")
		}
		var request = URLRequest(url: url as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10.0)
		
		if let playerId = self.savedPlayerId {
			request.addValue("\(playerIdCookieName)=\(playerId)", forHTTPHeaderField: "Cookie")
		}
		return request
	}
	
	// will give either Error or SuccessString responses
	// caller should further interpret SuccessString value
	private func performRequest(request: URLRequest, callback: @escaping (AsyncResponse) -> ()) {
    session.dataTask(with: request, completionHandler: {
      (data, response, error) in
			
			guard nil == error else {
				return callback(.error(-1, error!.localizedDescription))
			}
			
			guard let data = data else {
				return callback(.error(-1, "No response from server"))
			}
			
			let httpResponse = response as! HTTPURLResponse
			let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
			
			guard httpResponse.statusCode == 200 else {
				return callback(.error(httpResponse.statusCode, "Error from server: \(httpResponse.statusCode) \(dataString)"))
			}
				
			callback(.successString(dataString))
		}).resume()
	}
}

