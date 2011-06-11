//
//  Grid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Grid.h"


@implementation Grid

#pragma mark - Properties

@synthesize height = _height;
@synthesize width = _width;
@synthesize totalIndex = _totalIndex;
@synthesize items = _items;


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
        _totalIndex = _width * _height;
        
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
        [_items replaceObjectAtIndex:index
                              withObject:item];
            
        item.cachePosition = [self positionForIndex:index];
    }
}

- (void)removeItem:(GridItem *)item
{
    NSInteger index = [self indexForItem:item];
    [_items replaceObjectAtIndex:index
                      withObject:[NSNull null]];
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
    if (([self index:index existsForItem:item] && [self itemAtIndex:index])
        || ![self index:index existsForItem:item])
    {
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
    if (([self position:position existsForItem:item] && [self itemAtPosition:position])
        || ![self position:position existsForItem:item])
    {
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

- (BOOL)item:(GridItem *)item atPosition:(ABPoint)position isOnlyOnTopOf:(GridItemType)type
{
    return [self itemAtPosition:position].type == type;
}


#pragma mark - Position, index helpers

- (NSInteger)indexForPosition:(ABPoint)position
{
    return indexForPosition(position.x, position.y, _width);
}

- (ABPoint)positionForIndex:(NSInteger)index
{
    if (index < 0 || index > self.totalIndex) {
        [NSException raise:@"GridError" format:@"Exception: Trying to get a non existing position. Index: %d (Max: %d)", index, self.totalIndex];
    }
    
    return ABPointMake(index % _width,
                       ceil(index / _width));
}

- (NSInteger)indexForItem:(GridItem *)item
{
    return (int)[_items indexOfObject:item];
}


#pragma mark -

- (NSArray *)indexesForItem:(GridItem *)item atIndex:(NSInteger)index
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

- (NSMutableArray *)itemsOfType:(GridItemType)type
{
    NSMutableArray *items = [NSMutableArray array];
    
    for (NSInteger i=0; i<self.totalIndex; i++) {
        GridItem *item = [self itemAtIndex:i];
        if (item.type == type) {
            [items addObject:item];
        }
    }
    
    return items;
}

@end


#pragma mark - C Functions - Optimization purpose

NSInteger indexForPosition(NSInteger x, NSInteger y, NSInteger width)
{
    return x + y * width;
}