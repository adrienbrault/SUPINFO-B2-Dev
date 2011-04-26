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
- (NSSet *)positionsForItemType:(GridItemType)itemType atPosition:(ABPoint)position;

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


#pragma mark - Grid

- (GridItem *)itemAtPosition:(ABPoint)position;
{
    id item = [_items objectAtIndex:[self indexForPosition:position]];
    
    return (item != [NSNull null]) ? (GridItem *)item : nil;
}

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position
{
    if (!item)
        [NSException raise:@"GridItemError" format:@"You cannot set a nil object."];
    
    if (![self position:position existsForItemType:item.type])
        [NSException raise:@"GridItemError" format:@"You cannot set this at this position."];
    
    [_items replaceObjectAtIndex:[self indexForPosition:position]
                      withObject:item];
}

- (BOOL)position:(ABPoint)position availableForItemType:(GridItemType)itemType
{
    NSSet *itemPositions = [self positionsForItemType:itemType atPosition:position];
    for (NSValue *value in itemPositions) {
        ABPoint position = ABPointFromValue(value);
        
        if (!([self position:position existsForItemType:itemType] && ![self itemAtPosition:position]))
            return NO;
    }
    return YES;
}

- (BOOL)position:(ABPoint)position existsForItemType:(GridItemType)itemType
{
    int itemMaxColumn = position.x + GetGridItemTypeWidth(itemType);
    int itemMaxLine = position.y + GetGridItemTypeHeight(itemType);
    
    return itemMaxColumn <= _width && itemMaxLine <= _height;
}


#pragma mark - Private

- (int)indexForPosition:(ABPoint)position
{
    return position.y * _width + position.x;
}

- (NSSet *)positionsForItem:(GridItem *)item atPosition:(ABPoint)position
{
    NSMutableSet *set = [NSMutableSet set];
    for (int i=0; i<(item.width * item.height); i++) {
        ABPoint position = ABPointMake(i % item.width + position.x,
                                       i % item.height + position.y);
        
        // The best way to store a struct into a NSArray is to convert it to a NSValue.
        NSValue *value = ABPointToValue(position);
        [set addObject:value];
    }
    return set;
}

@end
