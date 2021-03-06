//
//  RenderableFactory.swift
//  ZenIDDemo
//
//  Created by František Kratochvíl on 16/12/2019.
//  Copyright © 2019 Trask, a.s. All rights reserved.
//

import UIKit

enum RenderableType: String {
    case line = "line"
    case rectangle = "rectangle"
    // case point = "point" // Point is not used anymore in the framework
    case circle = "circle"
    case ellipse = "ellipse"
    case text = "text"
}

class RenderableFactory {
    static func createRenderables(commands: String) -> [Renderable] {
        #if DEBUG
        // NSLog("Render:\n\(commands)")
        #endif
        return commands
            .split(separator: "\n")
            .compactMap(createRenderable(command:))
    }
        
    static func createRenderable<T>(command: T) -> Renderable? where T: StringProtocol {
        let strCommand = String(command)
        guard let type = strCommand.split(separator: ";").first else { return nil }
        
        switch RenderableType(rawValue: String(type)) {
        case .line:
            return Line(strCommand)
        case .rectangle:
            return Rectangle(strCommand)
        case .circle:
            return Circle(strCommand)
        case .ellipse:
            return Ellipse(strCommand)
        case .text:
            return Text(strCommand)
            
        default:
            return nil
        }
    }
}

extension RenderableFactory {
    static func split(command: String) -> [String] {
        command.split(separator: ";").map { String($0) }
    }
    
    static func floatsIn(splitCommand: [String]) -> [CGFloat] {
        splitCommand.compactMap { str -> CGFloat? in
            if let flValue = Float(str) {
                return CGFloat(flValue)
            }
            return nil
        }
    }
}
