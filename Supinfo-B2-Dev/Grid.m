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

@end



@implementation Grid

#pragma mark - Properties

@synthesize height = _height;
@synthesize width = _width;
@synthesize items = _items;

- (NSSet *)uniqueItems
{
    NSMutableSet *set = [NSMutableSet setWithArray:self.items];
    [set removeObject:[NSNull null]];
    return set;
}


#pragma mark - Object lifecyle

- (id)init
{
    return [self initWithWidth:1 height:1];
}

- (id)initWithWidth:(int)width height:(int)height;
{
    if ((self = [super init])) {
        int capacity = width * height;
        _width = width;
        _height = height;
        
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
    if (![self position:position availableForItem:item])
        [NSException raise:@"GridError" format:@"Exception: Trying to set an item to a wrong position."];
    
    if (!item) {
        [_items replaceObjectAtIndex:[self indexForPosition:position]
                          withObject:[NSNull null]];
    } else {
        if ([self indexForItem:item] != (int)NSNotFound) {
            [self removeItem:item];
        }
        
        NSSet *itemPositions = [self positionsForItem:item atPosition:position];
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
        NSSet *itemPositions = [self positionsForItem:item atPosition:[self positionForIndex:index]];
        for (NSValue *value in itemPositions) {
            ABPoint position = ABPointFromValue(value);
            int positionIndex = [self indexForPosition:position];
            
            [_items replaceObjectAtIndex:positionIndex
                              withObject:[NSNull null]];
        }
    }
}

- (BOOL)position:(ABPoint)position availableForItem:(GridItem *)item
{
    NSSet *itemPositions = [self positionsForItem:item atPosition:position];
    for (NSValue *value in itemPositions) {
        ABPoint itemPosition = ABPointFromValue(value);
        
        if ([self position:itemPosition existsForItem:item] && [self itemAtPosition:itemPosition]
            || ![self position:itemPosition existsForItem:item])
            return NO;
    }
    return YES;
}

- (BOOL)position:(ABPoint)position existsForItem:(GridItem *)item
{
    int itemMaxColumn = position.x + GetGridItemTypeWidth(item.type) - 1;
    int itemMaxLine = position.y + GetGridItemTypeHeight(item.type) - 1;
    
    return itemMaxColumn <= _width && itemMaxLine <= _height;
}

- (ABPoint)firstItemPosition:(GridItem *)item
{
    return [self positionForIndex:[self indexForItem:item]];
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
    if (index < 0 || index > (_width * _height)) {
        [NSException raise:@"GridError" format:@"Exception: Trying to get a non existing position."];
    }
    
    return ABPointMake(index % _width,
                       ceil(index / _height));
}

- (NSSet *)positionsForItem:(GridItem *)item atPosition:(ABPoint)position
{
    NSMutableSet *set = [NSMutableSet set];
    for (int i=0; i<(item.width * item.height); i++) {
        ABPoint itemPosition = ABPointMake(i % item.width + position.x,
                                           ceil(i / item.height) + position.y);
        
        // The best way to store a struct into a NSArray is to convert it to a NSValue.
        NSValue *value = ABPointToValue(itemPosition);
        [set addObject:value];
    }
    return set;
}

@end
