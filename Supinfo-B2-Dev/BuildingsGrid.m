//
//  BuildingsGrid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 02/05/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "BuildingsGrid.h"


@interface BuildingsGrid (Private)

- (BOOL)checkIndexes;
- (void)findNextIndexes;
- (BOOL)isIndexAWall:(NSInteger)index;
- (NSMutableSet *)borderIndexes;

@end


@implementation BuildingsGrid

#pragma mark - Algorithms

- (NSArray *)capturedTeritoryIndexes
{
    // Calloc init all values to 0.
    _indexesStatus = calloc(_totalIndex, sizeof(char)); /*** 1: Free || 2: Occupied ***/
    _indexesDone = calloc(_totalIndex, sizeof(BOOL));
    
    // We start from borders.
    _indexesToProcess = [self borderIndexes];
    
    BOOL anIndexIsCorrect = [self checkIndexes];
    
    while (anIndexIsCorrect) {
        [self findNextIndexes];
        anIndexIsCorrect = [self checkIndexes];
    }
    
    NSMutableArray *positionsStatus = [NSMutableArray arrayWithCapacity:_totalIndex];
    for (NSInteger i=0; i<_totalIndex; i++) {
        char status = _indexesStatus[i];
        BOOL isOccupied = (status != 1) ? YES : NO;
        [positionsStatus addObject:[NSNumber numberWithBool:isOccupied]];
    }
    
    free(_indexesStatus);
    free(_indexesDone);
    
    return positionsStatus;
}

- (BOOL)checkIndexes
{
    BOOL anIndexIsCorrect = NO;
    NSMutableSet *numbersToRemove = [NSMutableSet set];
    
    for (NSNumber *number in _indexesToProcess) {
        NSInteger currentIndex = [number integerValue];
        
        if ([self isIndexAWall:currentIndex]) {
            _indexesStatus[currentIndex] = 2;
            [numbersToRemove addObject:number];
        } else {
            _indexesStatus[currentIndex] = 1;
            anIndexIsCorrect = YES;
        }
        
        _indexesDone[currentIndex] = YES;
    }
    
    for (NSNumber *number in numbersToRemove) {
        [_indexesToProcess removeObject:number];
    }
    
    return anIndexIsCorrect;
}

- (void)findNextIndexes
{
    NSMutableSet *newIndexesToProcess = [NSMutableSet set];
    
    for (NSNumber *number in _indexesToProcess) {
        NSInteger index = [number integerValue];
        ABPoint indexPosition = [self positionForIndex:index];
        
        NSInteger positionNextToCurrentIndex[8] = {
            [self indexForPosition:ABPointMake(indexPosition.x - 1, indexPosition.y - 1)],
            [self indexForPosition:ABPointMake(indexPosition.x + 0, indexPosition.y - 1)],
            [self indexForPosition:ABPointMake(indexPosition.x + 1, indexPosition.y - 1)],
            [self indexForPosition:ABPointMake(indexPosition.x + 1, indexPosition.y + 0)],
            [self indexForPosition:ABPointMake(indexPosition.x + 1, indexPosition.y + 1)],
            [self indexForPosition:ABPointMake(indexPosition.x + 0, indexPosition.y + 1)],
            [self indexForPosition:ABPointMake(indexPosition.x - 1, indexPosition.y + 1)],
            [self indexForPosition:ABPointMake(indexPosition.x - 1, indexPosition.y + 0)]
        };
        
        for (NSInteger i=0; i<8; i++) {
            NSInteger currentPossibleIndex = positionNextToCurrentIndex[i];
            
            if (currentPossibleIndex > 0 && currentPossibleIndex < _totalIndex
                && !_indexesDone[currentPossibleIndex]) {
                [newIndexesToProcess addObject:[NSNumber numberWithInteger:currentPossibleIndex]];
            }
        }
    }
    
    _indexesToProcess = newIndexesToProcess;
}

- (NSMutableSet *)borderIndexes
{
    NSMutableSet *borderIndexes = [NSMutableArray array];
    
    // Top border.
    for (NSInteger i = 0;
         i<_width;
         i++)
    {
        [borderIndexes addObject:[NSNumber numberWithInteger:i]];
    }
    
    // Right border.
    for (NSInteger i = _width * 2.0 - 1;
         (i + 1) % _width == 0 && i < _totalIndex;
         i += _width)
    {
        [borderIndexes addObject:[NSNumber numberWithInteger:i]];
    }
    
    // Left border.
    for (NSInteger i = _width;
         i % _width == 0 && i < _totalIndex;
         i += _width)
    {
        [borderIndexes addObject:[NSNumber numberWithInteger:i]];
    }
    
    // Bottom border.
    for (NSInteger i = _totalIndex - _width;
         i < _totalIndex - 1;
         i++)
    {
        [borderIndexes addObject:[NSNumber numberWithInteger:i]];
    }
    
    return borderIndexes;
}

- (BOOL)isIndexAWall:(NSInteger)index
{
    if ([self itemAtIndex:index].type == GridItemWall) {
        return YES;
    }
    
    return NO;
}

@end
