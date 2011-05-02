//
//  Grid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Grid.h"


@interface Grid (Private)

- (BOOL)index:(NSInteger)index existsForItem:(GridItem *)item;
- (BOOL)index:(NSInteger)index availableForItem:(GridItem *)item;

- (NSArray *)indexesForItem:(GridItem *)item atPosition:(ABPoint)position;
- (NSArray *)indexesForItem:(GridItem *)item atIndex:(NSInteger)index;

- (NSInteger)indexForItem:(GridItem *)item;

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

- (id)initWithWidth:(NSInteger)width height:(NSInteger)height;
{
    if ((self = [super init])) {
        NSInteger capacity = width * height;
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

- (GridItem *)itemAtIndex:(NSInteger)index
{
    id item = [_items objectAtIndex:index];
    
    return (item != [NSNull null]) ? (GridItem *)item : nil;
}

- (void)setItem:(GridItem *)item atIndex:(NSInteger)index
{
    if (![self index:index availableForItem:item])
        [NSException raise:@"GridError" format:@"Exception: Trying to set an item to a wrong index. (%d)", index];
    
    if (!item) {
        [_items replaceObjectAtIndex:index
                          withObject:[NSNull null]];
    } else {
        NSArray *itemIndexes = [self indexesForItem:item atIndex:index];
        for (int i=0; i<[itemIndexes count]; i++) {
            NSNumber *number = [itemIndexes objectAtIndex:i];
            NSInteger positionIndex = [number integerValue];
            
            [_items replaceObjectAtIndex:positionIndex
                              withObject:item];
            
            if (i == 0) {
                item.cachePosition = [self positionForIndex:positionIndex];
            }
        }
    }
}

- (void)removeItem:(GridItem *)item
{
    NSInteger index = [self indexForItem:item];
    if (index != NSNotFound) {
        NSArray *itemIndexes = [self indexesForItem:item atIndex:index];
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

- (BOOL)index:(NSInteger)index availableForItem:(GridItem *)item
{
    NSArray *itemIndexes = [self indexesForItem:item atIndex:index];
    for (NSNumber *number in itemIndexes) {
        NSInteger itemIndex = [number intValue];
        
        if ([self index:itemIndex existsForItem:item] && [self itemAtIndex:itemIndex]
            || ![self index:itemIndex existsForItem:item])
            return NO;
    }
    return YES;
}

- (BOOL)index:(NSInteger)index existsForItem:(GridItem *)item
{
    return [self position:[self positionForIndex:index]
            existsForItem:item];
}


#pragma mark - Grid tests @position

- (BOOL)position:(ABPoint)position availableForItem:(GridItem *)item
{
    NSArray *itemPositions = [self positionsForItem:item atPosition:position];
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
    NSInteger itemMaxColumn = position.x + GetGridItemTypeWidth(item.type) - 1;
    NSInteger itemMaxLine = position.y + GetGridItemTypeHeight(item.type) - 1;
    
    return itemMaxColumn <= _width && itemMaxLine <= _height;
}


#pragma mark -

- (ABPoint)firstItemPosition:(GridItem *)item
{
    return [self positionForIndex:[self indexForItem:item]];
}


#pragma mark - Position, index helpers

- (NSInteger)indexForPosition:(ABPoint)position
{
    return position.y * _width + position.x;
}

- (ABPoint)positionForIndex:(NSInteger)index
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

- (NSArray *)indexesForItem:(GridItem *)item atIndex:(int)index
{
    return [self indexesForItem:item atPosition:[self positionForIndex:index]];
}

- (NSArray *)indexesForItem:(GridItem *)item atPosition:(ABPoint)position
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<(item.width * item.height); i++) {
        ABPoint itemPosition = ABPointMake(i % item.width + position.x,
                                           ceil(i / item.height) + position.y);
        
        NSInteger itemIndex = [self indexForPosition:itemPosition];
        
        [array addObject:[NSNumber numberWithInteger:itemIndex]];
    }
    return array;
}

- (NSArray *)positionsForItem:(GridItem *)item atPosition:(ABPoint)position
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<(item.width * item.height); i++) {
        ABPoint itemPosition = ABPointMake(i % item.width + position.x,
                                           ceil(i / item.height) + position.y);
        
        // The best way to store a struct into a NSArray is to convert it to a NSValue.
        NSValue *value = ABPointToValue(itemPosition);
        [array addObject:value];
    }
    return array;
}


#pragma mark - Territory grid

- (void)setTerritoryIndexesStatus:(NSArray *)indexesStatus
{
    for (int index = 0; index<[indexesStatus count]; index++) {
        NSNumber *boolNumber = [indexesStatus objectAtIndex:index];
        BOOL isOccupied = [boolNumber boolValue];
        
        id item;
        
        if (isOccupied) {
            item = [GridItem itemWithType:GridItemAreaCaptured];
            ((GridItem *)item).cachePosition = [self positionForIndex:index];
        } else {
            item = [NSNull null];
        }
        
        [_items replaceObjectAtIndex:index withObject:item];
    }
}

@end
