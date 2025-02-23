//
//  Types.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation

public typealias MediaPickerCompletionClosure = ([Media]) -> Void
public typealias MediaPickerOrientationHandler = (ShouldLock) -> Void
public typealias SimpleClosure = ()->()

public enum ShouldLock {
    case lock, unlock
}
