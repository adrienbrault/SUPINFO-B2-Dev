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
- (void)setBorderIndexes;

@end


@implementation BuildingsGrid

#pragma mark - Algorithms

- (NSArray *)capturedTeritoryIndexes
{
    // Calloc init all values to 0.
    _indexesStatus = calloc(_totalIndex, sizeof(char)); /*** 1: Free || 2: Occupied ***/
    _indexesDone = calloc(_totalIndex, sizeof(BOOL));
    
    // We start from borders.
    [self setBorderIndexes];
    
    BOOL anIndexIsCorrect = [self checkIndexes];
    
    while (anIndexIsCorrect) {
        [self findNextIndexes];
        anIndexIsCorrect = [self checkIndexes];
    }
    free(_indexesToProcess);
    
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
    
    for (NSInteger i=0; i<_indexesToProcessSize; i++) {
        NSInteger currentIndex = _indexesToProcess[i];
        
        if ([self isIndexAWall:currentIndex]) {
            _indexesStatus[currentIndex] = 2;
            _indexesToProcess[i] = -1;
        } else {
            _indexesStatus[currentIndex] = 1;
            anIndexIsCorrect = YES;
        }
        
        _indexesDone[currentIndex] = YES;
    }
    
    return anIndexIsCorrect;
}

- (void)findNextIndexes
{
    NSInteger *newIndexesToProcess = calloc((_width + _height - 2) * 2, sizeof(NSInteger));
    NSInteger newIndexesToProcessI = 0;
    
    for (NSInteger i=0; i<_indexesToProcessSize; i++) {
        NSInteger index = _indexesToProcess[i];
        if (index > -1) {
            ABPoint indexPosition = [self positionForIndex:index];
            
            NSInteger positionNextToCurrentIndex[8] = {
                indexForPosition(indexPosition.x - 1, indexPosition.y - 1, _width),
                indexForPosition(indexPosition.x + 0, indexPosition.y - 1, _width),
                indexForPosition(indexPosition.x + 1, indexPosition.y - 1, _width),
                indexForPosition(indexPosition.x + 1, indexPosition.y + 0, _width),
                indexForPosition(indexPosition.x + 1, indexPosition.y + 1, _width),
                indexForPosition(indexPosition.x + 0, indexPosition.y + 1, _width),
                indexForPosition(indexPosition.x - 1, indexPosition.y + 1, _width),
                indexForPosition(indexPosition.x - 1, indexPosition.y + 0, _width)
            };
            
            for (NSInteger i=0; i<8; i++) {
                NSInteger currentPossibleIndex = positionNextToCurrentIndex[i];
                
                if (currentPossibleIndex > 0 && currentPossibleIndex < _totalIndex
                    && !_indexesDone[currentPossibleIndex]) {
                    newIndexesToProcess[newIndexesToProcessI++] = currentPossibleIndex;
                    _indexesDone[currentPossibleIndex] = YES;
                }
            }
        }
    }
    
    free(_indexesToProcess);
    _indexesToProcess = newIndexesToProcess;
    _indexesToProcessSize = newIndexesToProcessI;
}

- (void)setBorderIndexes
{
    _indexesToProcessSize = (_width + _height - 2) * 2;
    _indexesToProcess = calloc(_indexesToProcessSize, sizeof(NSInteger));
    
    NSInteger indexesToProcessI = 0;
    
    // Top border.
    for (NSInteger i = 0;
         i<_width;
         i++)
    {
        _indexesToProcess[indexesToProcessI++] = i;
    }
    
    // Right border.
    for (NSInteger i = _width * 2.0 - 1;
         (i + 1) % _width == 0 && i < _totalIndex;
         i += _width)
    {
        _indexesToProcess[indexesToProcessI++] = i;
    }
    
    // Left border.
    for (NSInteger i = _width;
         i % _width == 0 && i < _totalIndex;
         i += _width)
    {
        _indexesToProcess[indexesToProcessI++] = i;
    }
    
    // Bottom border.
    for (NSInteger i = _totalIndex - _width;
         i < _totalIndex - 1;
         i++)
    {
        _indexesToProcess[indexesToProcessI++] = i;
    }
}

- (BOOL)isIndexAWall:(NSInteger)index
{
    if ([self itemAtIndex:index].type == GridItemWall) {
        return YES;
    }
    
    return NO;
}

@end
