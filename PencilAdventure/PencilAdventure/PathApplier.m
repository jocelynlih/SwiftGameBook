//
//  PathApplier.m
//  PencilAdventure
//
//  Created by Paul Nettle on 7/30/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "PathApplier.h"

@implementation AppliedPathElement
	CGPoint point;
	int elementType;
@end

void PathApplier(void *info, const CGPathElement *element)
{
	NSMutableArray *arr = (__bridge NSMutableArray *)info;
	
	AppliedPathElement *el = [AppliedPathElement alloc];
	el.point = element->points[0];
	el.elementType = element->type;
	
	switch (element->type)
	{
		case kCGPathElementMoveToPoint:
		{
			AppliedPathElement *el = [AppliedPathElement alloc];
			el.point = element->points[0];
			el.elementType = element->type;
			[arr addObject:el];
			break;
		}
		case kCGPathElementAddLineToPoint:
		{
			AppliedPathElement *el = [AppliedPathElement alloc];
			el.point = element->points[0];
			el.elementType = element->type;
			[arr addObject:el];
			break;
		}
		case kCGPathElementCloseSubpath:
		{
			// Close the loop by inserting the first element as the next
			if (arr.count != 0)
			{
				AppliedPathElement *first = [arr objectAtIndex:0];
				AppliedPathElement *el = [AppliedPathElement alloc];
				el.point = first.point;
				el.elementType = kCGPathElementAddLineToPoint;
				[arr addObject:el];
			}
			break;
		}
		default:
			NSLog(@"Unused path element type");
			break;
	}
}

NSMutableArray *ConvertPath(CGPathRef path)
{
	NSMutableArray *pathElements = [[NSMutableArray alloc] init];
	CGPathApply(path, (void *)pathElements, PathApplier);
	
	return pathElements;
}

//
//typedef void (*PathApplieFPtr)(void *info, const CGPathElement *element);
//PathApplieFPtr GlobalPathApplier = PathApplier;
