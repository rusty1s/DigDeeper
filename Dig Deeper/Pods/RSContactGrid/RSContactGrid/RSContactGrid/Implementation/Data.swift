//
//  Data.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 21.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

/// A class that adds additional information to a tile in a grid.
/// This needs to be a class to modify the data of a tile in a grid
/// without removing and newly inserting it because of passed-by-value.
public class Data<T, S> {
    
    /// The content that is stored in a tile.
    public var content: T?
    
    /// The contacted object that is stored in a tile.
    public var contact: S?
}
