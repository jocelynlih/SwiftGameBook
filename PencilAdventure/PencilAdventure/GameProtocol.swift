//
//  GameOverProtocol.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/25/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

public protocol GameProtocol {
    var viewableArea: CGRect! { get }
    
    func gameEnd(didWin: Bool)
}

