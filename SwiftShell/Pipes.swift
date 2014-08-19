//
// Pipes.swift
// SwiftShell
//
// Created by Kåre Morstøl on 17/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//


infix operator |> { precedence 50 associativity left }

public func |> <T,U>(lhs: T, rhs: T -> U) -> U {
	return rhs(lhs)
}
/*
public func | <T,U,V>(lhs: T, rhs:((T,V) -> U, V)) -> U {
	return rhs.0(lhs, rhs.1 )
}
*/