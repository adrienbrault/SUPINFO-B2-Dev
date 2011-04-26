//
//  Grid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Grid.h"


@interface Grid (Private)

- (int)indexForPosition:(ABPoint)position;
- (BOOL)indexAvailableForItem:(GridItem *)item atPosition:(ABPoint)position;

@end



@implementation Grid

#pragma mark - Properties

@synthesize height = _height;
@synthesize width = _width;


#pragma mark - Object lifecyle

- (id)init
{
    return [self initWithWidth:1 height:1];
}

- (id)initWithWidth:(int)width height:(int)height;
{
    if ((self = [super init])) {
        int capacity = width * height;
        
        _items = [[NSMutableArray alloc] initWithNullCapacity:capacity];
    }
    return self;
}

- (void)dealloc
{
    [_items release];
    [super dealloc];
}


#pragma mark -

- (GridItem *)itemAtPosition:(ABPoint)position;
{
    id item = [_items objectAtIndex:[self indexForPosition:position]];
    
    return (item != [NSNull null]) ? (GridItem *)item : nil;
}

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position
{
    if (!item)
        [NSException raise:@"GridItemError" format:@"You cannot set a nil object."];
    
    if (![self indexAvailableForItem:item atPosition:position])
        [NSException raise:@"GridItemError" format:@"You cannot set this at this position."]
    
    [_items replaceObjectAtIndex:[self indexForPosition:position]
                      withObject:item];
}


#pragma mark - Private

- (int)indexForPosition:(ABPoint)position
{
    return position.y * _width + position.x;
}

- (BOOL)indexAvailableForItem:(GridItem *)item atPosition:(ABPoint)position;
{
    int itemMaxColumn = position.x + item.width;
    int itemMaxLine = position.y + item.height;
    
    return itemMaxColumn <= _width && itemMaxLine <= _height;
}

@end
