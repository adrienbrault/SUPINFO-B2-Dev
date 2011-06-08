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

- (BOOL)index:(NSInteger)index availableForItem:(GridItem *)item
{
    NSArray *itemIndexes = [self indexesForItem:item atIndex:index];
    for (NSNumber *number in itemIndexes) {
        NSInteger itemIndex = [number intValue];
        
        if (([self index:itemIndex existsForItem:item] && [self itemAtIndex:itemIndex])
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
        
        if (([self position:itemPosition existsForItem:item] && [self itemAtPosition:itemPosition])
            || ![self position:itemPosition existsForItem:item])
            return NO;
    }
    return YES;
}

- (BOOL)item:(GridItem *)item atPosition:(ABPoint)position isOnlyOnTopOf:(GridItemType)type
{
    NSArray *positions = [self positionsForItem:item atPosition:position];
    for (NSValue *value in positions) {
        ABPoint currentPosition = ABPointFromValue(value);
        if ([self itemAtPosition:currentPosition].type != type) {
            return NO;
        }
    }
    
    return YES;
}

@end
