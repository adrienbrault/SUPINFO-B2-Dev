//
//  BuildingsGrid.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 02/05/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvancedGrid.h"


/*
 *  This class contains the algorithms to calculate the captured area.
 */

@interface BuildingsGrid : AdvancedGrid {
    
    // Algorithm part
    char *_indexesStatus;
    BOOL *_indexesDone;
    
    NSInteger *_indexesToProcess;
    NSInteger _indexesToProcessSize;
}

- (NSArray *)capturedTeritoryIndexes;

- (NSSet *)castels;

@end
