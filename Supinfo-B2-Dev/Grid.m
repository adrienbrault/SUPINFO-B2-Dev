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
- (int)indexForItem:(GridItem *)item;
- (ABPoint)positionForIndex:(int)index;
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
    if (![self position:position availableForItemType:item.type])
        [NSException raise:@"GridError" format:@"Trying to set an item to a wrong position."];
    
    if (!item) {
        [_items replaceObjectAtIndex:[self indexForPosition:position]
                          withObject:[NSNull null]];
    } else {
        NSSet *itemPositions = [self positionsForItemType:item.type atPosition:position];
        for (NSValue *value in itemPositions) {
            ABPoint position = ABPointFromValue(value);
            int positionIndex = [self indexForPosition:position];
            
            [_items replaceObjectAtIndex:positionIndex
                              withObject:item];
        }
    }
}

- (void)removeItem:(GridItem *)item
{
    int index = [self indexForItem:item];
    if (index != NSNotFound) {
        NSSet *itemPositions = [self positionsForItemType:item.type atPosition:[self positionForIndex:index]];
        for (NSValue *value in itemPositions) {
            ABPoint position = ABPointFromValue(value);
            int positionIndex = [self indexForPosition:position];
            
            [_items replaceObjectAtIndex:positionIndex
                              withObject:[NSNull null]];
        }
    }
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

- (int)indexForItem:(GridItem *)item
{
    return (int)[_items indexOfObject:item];
}

- (ABPoint)positionForIndex:(int)index
{
    if (index < (_width * _height)) {
        [NSException raise:@"GridError" format:@"Trying to get a non existing position."];
    }
    
    return ABPointMake(index % _width,
                       index % _height);
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
