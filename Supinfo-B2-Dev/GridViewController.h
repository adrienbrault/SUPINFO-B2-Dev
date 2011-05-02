//
//  GridViewController.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Grid.h"
#import "AdvancedGrid.h"
#import "GridView.h"

@interface GridViewController : NSViewController <NSWindowDelegate> {
    
    GridView *_mapGridView;
    GridView *_territoryGridView;
    GridView *_buildingsGridView;
    
    Grid *_mapGrid;
    Grid *_territoryGrid;
    AdvancedGrid *_buildingsGrid;
    
    NSInteger _gridWidth;
    NSInteger _gridHeight;
    NSInteger _gridTotalIndex;
    
    NSTrackingArea *_trackingArea;
    
    // Algorithm part
    char *_indexesStatus;
    BOOL *_indexesDone;
    NSMutableSet *_indexesToProcess;
}

@property (nonatomic, retain) IBOutlet GridView *mapGridView;
@property (nonatomic, retain) IBOutlet GridView *territoryGridView;
@property (nonatomic, retain) IBOutlet GridView *buildingsGridView;

@property (nonatomic, readonly) NSInteger gridWidth;
@property (nonatomic, readonly) NSInteger gridHeight;
@property (nonatomic, readonly) NSInteger gridTotalIndex;

- (void)setWidth:(NSInteger)width height:(NSInteger)height;

@end
