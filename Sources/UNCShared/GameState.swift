//
//  GameState.swift
//  Ultimate Noughts & Crosses Server
//
//  Created by Kyle Jessup on 2016-04-21.
//  Copyright © 2016 PerfectlySoft. All rights reserved.
//

public let ultimateSlotCount = 3
public let invalidId = -1

public enum UltimateState {
	/// no game
	case none
	// waiting for opponent
	case waiting
	// who won, current field
	case gameOver(PieceType, Field)
	// whose turn is it, required play board, current state
	case inPlay(PieceType, GridIndex, Field)
	// current player made invalid move
	case invalidMove
	
	private enum UltimateStateId: Int {
		case noneId, waitingId, gameOverId, inPlayId, invalidMoveId
	}
	
	private var serialId: Int {
		switch self {
		case .none:			return UltimateStateId.noneId.rawValue
		case .waiting:		return UltimateStateId.waitingId.rawValue
		case .gameOver:		return UltimateStateId.gameOverId.rawValue
		case .inPlay:		return UltimateStateId.inPlayId.rawValue
		case .invalidMove:	return UltimateStateId.invalidMoveId.rawValue
		}
	}
	
	public func serialize() -> String {
		switch self {
		case .none, .invalidMove, .waiting:
			return "\(self.serialId)"
		case .gameOver(let piece, let field):
			return "\(self.serialId)\(piece.serialize())\(field.serialize())"
		case .inPlay(let piece, let index, let field):
			return "\(self.serialId)\(piece.serialize())\(self.serialize(gridIndex: index))\(field.serialize())"
		}
	}
	
	func serialize(gridIndex: GridIndex) -> String {
		var s = ""
		if gridIndex.x == invalidId {
			s.append("-")
		} else {
			s.append("\(gridIndex.x)")
		}
		if gridIndex.y == invalidId {
			s.append("-")
		} else {
			s.append("\(gridIndex.y)")
		}
		return s
	}
	
	static func deserialize(idxX: String, idxY: String) -> GridIndex {
		let x = idxX[idxX.startIndex] == "-" ? invalidId : Int(idxX)!
		let y = idxY[idxY.startIndex] == "-" ? invalidId : Int(idxY)!
		return (x, y)
	}
	
	static func deserialize(source: String) -> UltimateState? {
		if let id = Int(String(source[source.startIndex])), let stateId = UltimateStateId(rawValue: id) {
			switch stateId {
			case .noneId:
				return .none
			case .waitingId:
				return .waiting
			case .gameOverId:
				if let pieceTypeInt = Int(String(source[source.index(after: source.startIndex)])),
					let pieceType = PieceType(rawValue: pieceTypeInt) {
					
					let fieldString = source[source.index(source.startIndex, offsetBy: 2)..<source.endIndex]
					if let field = Field.deserialize(source: fieldString) {
						return .gameOver(pieceType, field)
					}
				}
			case .inPlayId:
				if let pieceTypeInt = Int(String(source[source.index(after: source.startIndex)])),
					let pieceType = PieceType(rawValue: pieceTypeInt) {
					
					let c1 = String(source[source.index(source.startIndex, offsetBy: 2)])
					let c2 = String(source[source.index(source.startIndex, offsetBy: 3)])
					
					let gridIndex = self.deserialize(idxX: c1, idxY: c2)
					
					let fieldString = source[source.index(source.startIndex, offsetBy: 4)..<source.endIndex]
					if let field = Field.deserialize(source: fieldString) {
						return .inPlay(pieceType, gridIndex, field)
					}
				}
			case .invalidMoveId:
				return .invalidMove
			}
		}
		return nil
	}
}

public enum AsyncResponse {
	case error(Int, String)
	case successEmpty()
	case successInt(Int)
	case successInt2(Int, Int)
	case successString(String)
	case successState(UltimateState)
}

public protocol GameState {
	func createPlayer(nick: String, response: @escaping (AsyncResponse) -> ())
	func getPlayerNick(playerId: Int, response: @escaping (AsyncResponse) -> ())
	func getCurrentState(playerId: Int, response: @escaping (AsyncResponse) -> ())
	func getActiveGame(playerId: Int, response: @escaping (AsyncResponse) -> ())
	func playPieceOnBoard(playerId: Int, board: GridIndex, slotIndex: GridIndex, response: @escaping (AsyncResponse) -> ())
	func createGame(playerId: Int, gameType: PlayerType, response: @escaping (AsyncResponse) -> ())
}

