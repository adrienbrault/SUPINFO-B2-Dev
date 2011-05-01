//
//  GridItem.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridItem.h"


@implementation GridItem

#pragma mark - Properties

@synthesize type = _type;
@synthesize cachePosition = _cachePosition;

- (int)width
{
    return GetGridItemTypeWidth(_type);
}

- (int)height
{
    return GetGridItemTypeHeight(_type);
}


#pragma mark - Object lifecyle

- (id)init
{
    return [self initWithType:GridItemEarth];
}

- (id)initWithType:(GridItemType)type
{
    if ((self = [super init])) {
        _type = type;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


#pragma mark -

- (NSString *)description
{
    return [NSString stringWithFormat:@"Type: %@; Width: %d; Height: %d;", GetGridItemTypeString(self.type), self.width, self.height];
}


#pragma mark - Class

+ (id)itemWithType:(GridItemType)type
{
    return [[[GridItem alloc] initWithType:type] autorelease];
}

@end
