//
//  CGVector+Extensions.swift
//
//  Created by Paul Nettle on 7/28/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

extension CGVector
{
	var length: CGFloat
	{
		get
		{
			return sqrt(lengthSquared)
		}
	}
	
	var lengthSquared: CGFloat
	{
		get
		{
			return dx * dx + dy * dy
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
	
	func toPoint2D() -> Point2D
	{
		return Point2D(x: Int(dx), y: Int(dy))
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
	
	func dot(other: CGVector) -> CGFloat
	{
		return dx * other.dx + dy * other.dy
	}
}

func * (left: CGVector, right: CGFloat) -> CGVector
{
	return CGVector(dx: left.dx * right, dy: left.dy * right)
}

func * (left: CGVector, right: CGVector) -> CGVector
{
	return CGVector(dx: left.dx * right.dx, dy: left.dy * right.dy)
}

func / (left: CGVector, right: CGFloat) -> CGVector
{
	return CGVector(dx: left.dx / right, dy: left.dy / right)
}

func / (left: CGVector, right: CGVector) -> CGVector
{
	return CGVector(dx: left.dx / right.dx, dy: left.dy / right.dy)
}

func + (left: CGVector, right: CGFloat) -> CGVector
{
	return CGVector(dx: left.dx + right, dy: left.dy + right)
}

func + (left: CGVector, right: CGVector) -> CGVector
{
	return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

func - (left: CGVector, right: CGFloat) -> CGVector
{
	return CGVector(dx: left.dx - right, dy: left.dy - right)
}

func - (left: CGVector, right: CGVector) -> CGVector
{
	return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}

func += (inout left: CGVector, right: CGVector)
{
	left = left + right
}

func -= (inout left: CGVector, right: CGVector)
{
	left = left - right
}

func *= (inout left: CGVector, right: CGVector)
{
	left = left * right
}

func /= (inout left: CGVector, right: CGVector)
{
	left = left / right
}

