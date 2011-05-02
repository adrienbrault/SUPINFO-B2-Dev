//
//  TerritoryGrid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 02/05/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "TerritoryGrid.h"


@implementation TerritoryGrid

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
