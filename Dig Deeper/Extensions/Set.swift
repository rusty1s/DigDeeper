//
//  Set.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 12.04.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

extension Set {
    
    func map<U>(transform: (T) -> (U)) -> Set<U> {
        return Set<U>(Swift.map(self, transform))
    }
    
    func filter(transform: (T) -> (Bool)) -> Set<T> {
        return Set<T>(Swift.filter(self, transform))
    }
}
