//
//  Point2D.swift
//
//  Created by Paul Nettle on 7/28/14.
//

import SpriteKit

struct Point2D
{
	var x: Int
	var y: Int
	
	func toCGVector() -> CGVector
	{
		return CGVector(dx: CGFloat(x), dy: CGFloat(y))
	}
	
	func toCGPoint() -> CGPoint
	{
		return CGPoint(x: CGFloat(x), y: CGFloat(y))
	}
}

func * (left: Point2D, right: Int) -> Point2D
{
	return Point2D(x: left.x * right, y: left.y * right)
}

func * (left: Point2D, right: Point2D) -> Point2D
{
	return Point2D(x: left.x * right.x, y: left.y * right.y)
}

func / (left: Point2D, right: Int) -> Point2D
{
	return Point2D(x: left.x / right, y: left.y / right)
}
func / (left: Point2D, right: Point2D) -> Point2D
{
	return Point2D(x: left.x / right.x, y: left.y / right.y)
}

func + (left: Point2D, right: Int) -> Point2D
{
	return Point2D(x: left.x + right, y: left.y + right)
}

func + (left: Point2D, right: Point2D) -> Point2D
{
	return Point2D(x: left.x + right.x, y: left.y + right.y)
}

func - (left: Point2D, right: Int) -> Point2D
{
	return Point2D(x: left.x - right, y: left.y - right)
}

func - (left: Point2D, right: Point2D) -> Point2D
{
	return Point2D(x: left.x - right.x, y: left.y - right.y)
}

func += (inout left: Point2D, right: Point2D)
{
	left = left + right
}

func -= (inout left: Point2D, right: Point2D)
{
	left = left - right
}

func *= (inout left: Point2D, right: Point2D)
{
	left = left * right
}

func /= (inout left: Point2D, right: Point2D)
{
	left = left / right
}

