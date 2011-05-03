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
#import "TerritoryGrid.h"
#import "BuildingsGrid.h"

#import "GridView.h"
#import "AdvancedGridView.h"

@interface GridViewController : NSViewController <NSWindowDelegate> {
    
    GridView *_mapGridView;
    GridView *_territoryGridView;
    AdvancedGridView *_buildingsGridView;
    
    Grid *_mapGrid;
    TerritoryGrid *_territoryGrid;
    BuildingsGrid *_buildingsGrid;
    
    NSInteger _gridWidth;
    NSInteger _gridHeight;
    NSInteger _gridTotalIndex;
    
    NSTrackingArea *_trackingArea;
}

@property (nonatomic, retain) IBOutlet GridView *mapGridView;
@property (nonatomic, retain) IBOutlet GridView *territoryGridView;
@property (nonatomic, retain) IBOutlet AdvancedGridView *buildingsGridView;

@property (nonatomic, readonly) NSInteger gridWidth;
@property (nonatomic, readonly) NSInteger gridHeight;
@property (nonatomic, readonly) NSInteger gridTotalIndex;

- (void)setWidth:(NSInteger)width height:(NSInteger)height;

@end
