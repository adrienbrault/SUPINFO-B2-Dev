//
//  GridViewController.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Grid.h"
#import "GridView.h"

@interface GridViewController : NSViewController {
    
    GridView *_mapGridView;
    GridView *_territoryGridView;
    GridView *_buildingsGridView;
    
    Grid *_mapGrid;
    Grid *_territoryGrid;
    Grid *_buildingsGrid;
    
    int _gridWidth;
    int _gridHeight;
    
    NSTrackingArea *_trackingArea;
    BOOL _mouseIsInside;
}

@property (nonatomic, retain) IBOutlet GridView *mapGridView;
@property (nonatomic, retain) IBOutlet GridView *territoryGridView;
@property (nonatomic, retain) IBOutlet GridView *buildingsGridView;

@property (nonatomic, readonly) int gridWidth;
@property (nonatomic, readonly) int gridHeight;

- (void)setWidth:(int)width height:(int)height;

@end
