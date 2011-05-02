//
//  AdvancedGrid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 02/05/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "AdvancedGrid.h"


@implementation AdvancedGrid

#pragma mark -

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
            NSInteger positionIndex = [number integerValue];
            
            [_items replaceObjectAtIndex:positionIndex
                              withObject:[NSNull null]];
        }
    }
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


#pragma mark -

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

@end
