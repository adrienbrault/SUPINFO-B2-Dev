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
    GameStateWallsRepair = 0,
    GameStateCanons,
    GameStateAssault
} GameStateType;

static NSString *const stateLabels[] = {
    @"Place walls to protect your Castels!",
    @"Place guns in your captured area!",
    @"Shoot at the boats to protect your walls!"
};

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
    NSTextField *_instructionLabel;
    
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
    
    BOOL _wallShapes[9];
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
@property (assign) IBOutlet NSTextField *instructionLabel;


// Public

@property (nonatomic, readonly) NSInteger gridWidth;
@property (nonatomic, readonly) NSInteger gridHeight;
@property (nonatomic, readonly) NSInteger gridTotalIndex;

- (void)setWidth:(NSInteger)width height:(NSInteger)height;

- (void)setCorrectViewSize;

@end