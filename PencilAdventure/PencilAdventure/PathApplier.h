//
//  PathApplier.h
//  PencilAdventure
//
//  Created by Paul Nettle on 7/30/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

#ifndef PencilAdventure_PathApplier_h
#define PencilAdventure_PathApplier_h

@interface AppliedPathElement : NSObject

	@property (nonatomic) CGPoint point;
	@property (nonatomic) int elementType;

@end

NSMutableArray *ConvertPath(CGPathRef path);


#endif
