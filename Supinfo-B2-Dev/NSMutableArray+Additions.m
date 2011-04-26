//
//  NSMutableArray+Additions.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "NSMutableArray+Additions.h"


@implementation NSMutableArray (Additions)

- (id)initWithNullCapacity:(NSUInteger)capacity
{
    if ((self = [self initWithCapacity:capacity])) {
        for (int i=0; i<capacity; i++) {
            [self addObject:[NSNull null]];
        }
    }
    return self;
}

@end
