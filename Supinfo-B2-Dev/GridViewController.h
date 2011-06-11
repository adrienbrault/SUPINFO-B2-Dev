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

#import "BoatView.h"

#import "GridView.h"
#import "AdvancedGridView.h"
#import "CannonBallView.h"


typedef enum {
    GameStateWallsRepair,
    GameStateCanons,
    GameStateAssault
} GameStateType;

static CGFloat const GameStateDuration[] = {
    25.0,
    10.0,
    15.0,
};


@interface GridViewController : NSViewController <NSWindowDelegate> {
    
    GridView *_mapGridView;
    GridView *_territoryGridView;
    AdvancedGridView *_buildingsGridView;
    AdvancedGridView *_previewGridView;
    NSView *_mapView;
    NSProgressIndicator *_timeProgressView;
    NSTextFieldCell *_timeLeftLabel;
    NSTextField *_scoreLabel;
    
    Grid *_mapGrid;
    TerritoryGrid *_territoryGrid;
    BuildingsGrid *_buildingsGrid;
    BuildingsGrid *_previewGrid;
    
    NSInteger _gridWidth;
    NSInteger _gridHeight;
    NSInteger _gridTotalIndex;
    
    NSTrackingArea *_trackingArea;
    
    GameStateType _gameState;
    
    NSTimer *_timeLeftTimer;
    
    NSMutableArray *_boatViews;
    
    NSMutableArray *_boatsCanonBallView;
    
    NSMutableArray *_wallsToDestroy;
    
    NSMutableArray *_gunsReadyToFire;
    
    NSInteger _score;
}

// Internal

@property (assign) IBOutlet GridView *mapGridView;
@property (assign) IBOutlet GridView *territoryGridView;
@property (assign) IBOutlet AdvancedGridView *buildingsGridView;
@property (assign) IBOutlet AdvancedGridView *previewGridView;
@property (assign) IBOutlet NSView *mapView;
@property (assign) IBOutlet NSProgressIndicator *timeProgressView;
@property (assign) IBOutlet NSTextFieldCell *timeLeftLabel;
@property (assign) IBOutlet NSTextField *scoreLabel;


// Public

@property (nonatomic, readonly) NSInteger gridWidth;
@property (nonatomic, readonly) NSInteger gridHeight;
@property (nonatomic, readonly) NSInteger gridTotalIndex;

- (void)setWidth:(NSInteger)width height:(NSInteger)height;

- (void)setCorrectViewSize;

@end
