//
//  Grid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Grid.h"


@interface Grid (Private)

- (BOOL)index:(int)index existsForItem:(GridItem *)item;
- (BOOL)index:(int)index availableForItem:(GridItem *)item;

- (NSSet *)indexesForItem:(GridItem *)item atPosition:(ABPoint)position;
- (NSSet *)indexesForItem:(GridItem *)item atIndex:(int)index;

- (int)indexForItem:(GridItem *)item;

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

- (GridItem *)itemAtIndex:(int)index
{
    id item = [_items objectAtIndex:index];
    
    return (item != [NSNull null]) ? (GridItem *)item : nil;
}

- (void)setItem:(GridItem *)item atIndex:(int)index
{
    if (![self index:index availableForItem:item])
        [NSException raise:@"GridError" format:@"Exception: Trying to set an item to a wrong index. (%d)", index];
    
    if (!item) {
        [_items replaceObjectAtIndex:index
                          withObject:[NSNull null]];
    } else {
        if ([self indexForItem:item] != (int)NSNotFound) {
            [self removeItem:item];
        }
        
        NSSet *itemIndexes = [self indexesForItem:item atIndex:index];
        for (NSNumber *number in itemIndexes) {
            int positionIndex = [number intValue];
            
            [_items replaceObjectAtIndex:positionIndex
                              withObject:item];
        }
        item.cachePosition = [self firstItemPosition:item];
    }
}

- (void)removeItem:(GridItem *)item
{
    int index = [self indexForItem:item];
    if (index != NSNotFound) {
        NSSet *itemIndexes = [self indexesForItem:item atIndex:index];
        for (NSNumber *number in itemIndexes) {
            int positionIndex = [number intValue];
            
            [_items replaceObjectAtIndex:positionIndex
                              withObject:[NSNull null]];
        }
    }
}


#pragma mark - Grid @position

- (GridItem *)itemAtPosition:(ABPoint)position;
{
    return [self itemAtIndex:[self indexForPosition:position]];
}

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position
{
    return [self setItem:item atIndex:[self indexForPosition:position]];
}


#pragma mark - Grid tests

- (BOOL)index:(int)index availableForItem:(GridItem *)item
{
    NSSet *itemIndexes = [self indexesForItem:item atIndex:index];
    for (NSNumber *number in itemIndexes) {
        int itemIndex = [number intValue];
        
        if ([self index:itemIndex existsForItem:item] && [self itemAtIndex:itemIndex]
            || ![self index:itemIndex existsForItem:item])
            return NO;
    }
    return YES;
}

- (BOOL)index:(int)index existsForItem:(GridItem *)item
{
    return [self position:[self positionForIndex:index]
            existsForItem:item];
}


#pragma mark - Grid tests @position

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


#pragma mark -

- (ABPoint)firstItemPosition:(GridItem *)item
{
    return [self positionForIndex:[self indexForItem:item]];
}


#pragma mark - Position, index helpers

- (int)indexForPosition:(ABPoint)position
{
    return position.y * _width + position.x;
}

- (ABPoint)positionForIndex:(int)index
{
    if (index < 0 || index > (_width * _height)) {
        [NSException raise:@"GridError" format:@"Exception: Trying to get a non existing position."];
    }
    
    return ABPointMake(index % _width,
                       ceil(index / _width));
}

- (int)indexForItem:(GridItem *)item
{
    return (int)[_items indexOfObject:item];
}

- (NSSet *)indexesForItem:(GridItem *)item atIndex:(int)index
{
    return [self indexesForItem:item atPosition:[self positionForIndex:index]];
}

- (NSSet *)indexesForItem:(GridItem *)item atPosition:(ABPoint)position
{
    NSMutableSet *set = [NSMutableSet set];
    for (int i=0; i<(item.width * item.height); i++) {
        ABPoint itemPosition = ABPointMake(i % item.width + position.x,
                                           ceil(i / item.height) + position.y);
        
        int itemIndex = [self indexForPosition:itemPosition];
        
        [set addObject:[NSNumber numberWithInt:itemIndex]];
    }
    return set;
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


#pragma mark - Territory grid

- (void)setTerritoryIndexesStatus:(NSArray *)indexesStatus
{
    for (int index; index<[indexesStatus count]; index++) {
        NSNumber *boolNumber = [indexesStatus objectAtIndex:index];
        BOOL isOccupied = [boolNumber boolValue];
        
        id item;
        
        if (isOccupied) {
            item = [GridItem itemWithType:GridItemAreaCaptured];
        } else {
            item = [NSNull null];
        }
        
        [_items replaceObjectAtIndex:index withObject:item];
    }NSLog(@"%@", _items);
}

@end
