//
//  GridDelegate.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 03.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

public protocol GridDelegate {
    
    // MARK: Instance methods
    
    /// Called when the grid begins to resolve contacts with a polygon.
    func didBeginResolveContacts()
    
    /// Called when a polygon overlays a `GridElementType`.
    func didResolveContactInElement(element: Any)
    
    /// Called when the grid resolved all contacts with a polygon.
    func didEndResolveContacts()
}
