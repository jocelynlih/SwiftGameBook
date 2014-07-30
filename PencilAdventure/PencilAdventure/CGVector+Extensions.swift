//
//  CGVector+Extensions.swift
//  Play
//
//  Created by Paul Nettle on 7/28/14.
//  Copyright (c) 2014 Paul Nettle. All rights reserved.
//

import SpriteKit

extension CGVector
{
	var length: CGFloat
	{
		get
		{
			return sqrt(dx * dx + dy * dy)
		}
	}
	
	var normal: CGVector
	{
		get
		{
			return self * (1.0 / length)
		}
	}
	
	func toCGPoint() -> CGPoint
	{
		return CGPoint(x: dx, y: dy)
	}
	
	func randomOffset(range: CGFloat) -> CGVector
	{
		let xOff = CGFloat.randomValueSigned(range)
		let yOff = CGFloat.randomValueSigned(range)
		return CGVector(dx: dx + xOff, dy: dy + yOff)
	}
	
	func perpendicular() -> CGVector
	{
		return CGVector(dx: dy, dy: dx)
	}
}

extension CGPoint
{
	func toCGVector() -> CGVector
	{
		return CGVector(dx: x, dy: y)
	}
}

@infix func * (left: CGVector, right: CGFloat) -> CGVector
{
	return CGVectorMake(left.dx * right, left.dy * right)
}

@infix func * (left: CGVector, right: CGVector) -> CGVector
{
	return CGVectorMake(left.dx * right.dx, left.dy * right.dy)
}

@infix func / (left: CGVector, right: CGFloat) -> CGVector
{
	return CGVectorMake(left.dx / right, left.dy / right)
}

@infix func / (left: CGVector, right: CGVector) -> CGVector
{
	return CGVectorMake(left.dx / right.dx, left.dy / right.dy)
}

@infix func + (left: CGVector, right: CGFloat) -> CGVector
{
	return CGVectorMake(left.dx + right, left.dy + right)
}

@infix func + (left: CGVector, right: CGVector) -> CGVector
{
	return CGVectorMake(left.dx + right.dx, left.dy + right.dy)
}

@infix func - (left: CGVector, right: CGFloat) -> CGVector
{
	return CGVectorMake(left.dx - right, left.dy - right)
}

@infix func - (left: CGVector, right: CGVector) -> CGVector
{
	return CGVectorMake(left.dx - right.dx, left.dy - right.dy)
}

@infix func - (left: CGPoint, right: CGPoint) -> CGVector
{
	return CGVectorMake(left.x - right.x, left.y - right.y)
}

@assignment func += (inout left: CGVector, right: CGVector)
{
	left = left + right
}

@assignment func -= (inout left: CGVector, right: CGVector)
{
	left = left - right
}

@assignment func *= (inout left: CGVector, right: CGVector)
{
	left = left * right
}

@assignment func /= (inout left: CGVector, right: CGVector)
{
	left = left / right
}

