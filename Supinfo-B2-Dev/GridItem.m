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

- (int)width
{
    return (_type == GridItemCastel) ? 2 : 1;
}

- (int)height
{
    return (_type == GridItemCastel) ? 2 : 1;
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

@end
