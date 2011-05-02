//
//  AdvancedGrid.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 02/05/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Grid.h"

// This class supports GridItem with any height and width

@interface AdvancedGrid : Grid {
    
}

- (NSArray *)positionsForItem:(GridItem *)item atPosition:(ABPoint)position;
- (NSArray *)indexesForItem:(GridItem *)item atPosition:(ABPoint)position;
- (NSArray *)indexesForItem:(GridItem *)item atIndex:(NSInteger)index;

@end
