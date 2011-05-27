//
//  GridViewController.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridViewController.h"


#define TIMER_UPDATE_INTERVAL 0.033
#define STATE_WALLS_DURATION 10.0


@interface GridViewController ()

- (void)loadDefaultMap;

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position;
- (BOOL)item:(GridItem *)item canBePositionedAt:(ABPoint)position;

- (ABPoint)positionAtMouseLocation:(NSPoint)mouseLocation;
- (ABPoint)positionAtEventMouseLocation:(NSEvent *)theEvent;

- (void)setTrackingArea;

- (void)refreshTerritoryMap;

- (void)startGameState:(GameStateType)state;
- (void)gameStateTimeDidEnd;
- (void)timeLeftTimerFire:(id)timer;

@property (nonatomic, retain) NSTimer *timeLeftTimer;

@end


@implementation GridViewController

#pragma mark - Properties

@synthesize mapGridView = _mapGridView;
@synthesize territoryGridView = _territoryGridView;
@synthesize buildingsGridView = _buildingsGridView;
@synthesize mapView = _mapView;
@synthesize timeProgressView = _timeProgressView;

@synthesize gridWidth = _gridWidth;
@synthesize gridHeight = _gridHeight;
@synthesize gridTotalIndex = _gridTotalIndex;

@synthesize timeLeftTimer = _timeLeftTimer;


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
    }
    return self;
}

- (void)dealloc
{
    [_mapGrid release];
    [_territoryGrid release];
    [_buildingsGrid release];
    
    [_mapGridView release];
    [_territoryGridView release];
    [_buildingsGridView release];
    
    [_trackingArea release];
    
    [super dealloc];
}


#pragma mark -

- (void)setWidth:(NSInteger)width height:(NSInteger)height
{
    if (!(width > 0 && height > 0)) {
        [NSException raise:@"GridViewControllerException" format:@"Exception: Width and height must be greater than 0."];
    }
    
    _gridWidth = width;
    _gridHeight = height;
    _gridTotalIndex = _gridWidth * _gridHeight;
    
    _mapGrid = [[Grid alloc] initWithWidth:_gridWidth height:_gridHeight];
    _territoryGrid = [[TerritoryGrid alloc] initWithWidth:_gridWidth height:_gridHeight];
    _buildingsGrid = [[BuildingsGrid alloc] initWithWidth:_gridWidth height:_gridHeight];
    
    _mapGridView.grid = _mapGrid;
    _territoryGridView.grid = _territoryGrid;
    _buildingsGridView.grid = _buildingsGrid;
    
    self.view.window.delegate = self;
    [self setTrackingArea];
    
    // Mouse down event.
    [self setNextResponder:self.view.nextResponder];
    [self.view setNextResponder:self];
    
    [self loadDefaultMap];
    
    [self startGameState:GameStateWallsStart];
}

- (void)loadDefaultMap
{
    NSLog(@"Loading default map");
    
    NSAutoreleasePool *pool = nil;
    
    NSInteger totalItems = _gridWidth * _gridHeight;
    for (NSInteger i=0; i<totalItems; i++) {
        if (i % 10000 == 0) {
            [pool drain];
            pool = [[NSAutoreleasePool alloc] init];
        }
        
        
        GridItemType itemType;
        ABPoint position = ABPointMake(i % _gridWidth, floor(i / _gridWidth));
        
        // Weird condition that make the map look cool.
        if ((i / _gridWidth) < _gridHeight / 2
            || (i % _gridWidth) < (_gridHeight - i / _gridWidth)) {
            itemType = GridItemEarth;
        } else {
            itemType = GridItemWater;
        }
        
        [self setItem:[GridItem itemWithType:itemType]
               atPosition:position];
    }
    [pool drain];
    
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(3*_gridWidth/4, 1*_gridHeight/7)];
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(_gridWidth/6, 2*_gridHeight/4)];
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(_gridWidth/4, _gridHeight/4)];
    
    [_mapGridView setNeedsDisplay:YES];
    
    NSLog(@"Default map loaded");
}


#pragma mark -

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position
{
    if ([self item:item canBePositionedAt:position]) {
        switch (item.type) {
            case GridItemWall:
            case GridItemCastel:
            case GridItemTower:
                [_buildingsGrid setItem:item atPosition:position];
                [_buildingsGridView setNeedsDisplay:YES];
                break;
            
            case GridItemAreaCaptured:
                [_territoryGrid setItem:item atPosition:position];
                [_territoryGridView setNeedsDisplay:YES];
                break;
            
            case GridItemEarth:
            case GridItemWater:
                [_mapGrid setItem:item atPosition:position];
                [_mapGridView setNeedsDisplay:YES];
                break;
        }
    }
}

- (BOOL)item:(GridItem *)item canBePositionedAt:(ABPoint)position
{
    switch (item.type) {
        case GridItemWall:
        case GridItemCastel:
        case GridItemTower:
        {
            if (![_buildingsGrid position:position availableForItem:item]) {
                return NO;
            }
            
            if (![_mapGrid item:item atPosition:position isOnlyOnTopOf:GridItemEarth]) {
                return NO;
            }
            
            break;
        }
        
        case GridItemEarth:
        case GridItemWater:
            break;
            
        case GridItemAreaCaptured:
            break;
    }
    
    return YES;
}


#pragma mark - Mouse events

- (void)mouseMoved:(NSEvent *)theEvent
{
    [self.nextResponder mouseMoved:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self.nextResponder mouseDown:theEvent];
    
    CGPoint mouseLocation = NSPointToCGPoint([theEvent locationInWindow]);
    if (!CGRectContainsPoint(self.mapView.frame, mouseLocation)) {
        return;
    }
    
    switch (_gameState) {
        case GameStateWallsStart:
        case GameStateWallsRepair:
        {
            ABPoint position = [self positionAtEventMouseLocation:theEvent];
            
            [self setItem:[GridItem itemWithType:GridItemWall]
               atPosition:position];
            
            [self refreshTerritoryMap];
        } break;
            
        default:
            break;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self.nextResponder mouseDragged:theEvent];
    
    CGPoint mouseLocation = NSPointToCGPoint([theEvent locationInWindow]);
    if (!CGRectContainsPoint(self.mapView.frame, mouseLocation)) {
        return;
    }
    
    switch (_gameState) {
        case GameStateWallsStart:
        case GameStateWallsRepair:
        {
            ABPoint position = [self positionAtEventMouseLocation:theEvent];
            
            [self setItem:[GridItem itemWithType:GridItemWall]
               atPosition:position];
            
            [self refreshTerritoryMap];
        } break;
            
        default:
            break;
    }
}


#pragma mark - Mouse stuff

- (ABPoint)positionAtMouseLocation:(NSPoint)mouseLocation
{
    ABPoint position = ABPointMake(ceil((mouseLocation.x + 1.0) / (self.mapView.frame.size.width / _gridWidth)) - 1,
                       ceil((self.mapView.frame.size.height - mouseLocation.y + 1.0) / (self.mapView.frame.size.height / _gridHeight)) - 1);
    
    // We make sure that the position is correct.
    if (position.x >= _gridWidth) {
        position.x = _gridWidth - 1;
    }
    if (position.y >= _gridHeight) {
        position.y = _gridHeight - 1;
    }
    
    if (position.x < 0) {
        position.x = 0;
    }
    if (position.y < 0) {
        position.y = 0;
    }
    
    return position;
}

- (ABPoint)positionAtEventMouseLocation:(NSEvent *)theEvent
{
    NSPoint mouseLocation = [theEvent locationInWindow];
    mouseLocation = [self.mapView convertPoint:mouseLocation fromView:self.view];
    
    return [self positionAtMouseLocation:mouseLocation];
}

- (void)setTrackingArea
{
    [self.view removeTrackingArea:_trackingArea];
    [_trackingArea release];
    
    // Mouse tracking (mouseMoved and mouseEntered + mouseExited)
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.frame
                                                 options:( NSTrackingMouseEnteredAndExited
                                                          | NSTrackingMouseMoved
                                                          | NSTrackingActiveInKeyWindow
                                                          | NSTrackingActiveAlways)
                                                   owner:self
                                                userInfo:nil];
    
    [self.view addTrackingArea:_trackingArea];
}


#pragma mark - NSWindowDelegate

- (void)windowDidEndLiveResize:(NSNotification *)notification
{
    [self setTrackingArea];
}

- (void)windowDidUpdate:(NSNotification *)notification
{
    [self setTrackingArea];
}


#pragma mark - TerritoryMap

- (void)refreshTerritoryMap
{
    [_territoryGrid setTerritoryIndexesStatus:[_buildingsGrid capturedTeritoryIndexes]];
    [_territoryGridView setNeedsDisplay:YES];
}


#pragma mark -

- (void)startGameState:(GameStateType)state
{
    _gameState = state;
    
    self.timeProgressView.doubleValue = self.timeProgressView.maxValue;
    
    [self.timeLeftTimer invalidate];
    self.timeLeftTimer = nil;
    if (GameStateDuration[_gameState] > 0.0) {
        self.timeLeftTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_UPDATE_INTERVAL
                                                              target:self
                                                            selector:@selector(timeLeftTimerFire:)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

- (void)gameStateTimeDidEnd
{
    switch (_gameState) {
        case GameStateWallsStart:
        case GameStateWallsRepair:
        {
            // TODO: Check to see if any castle is captured.
            
            [self startGameState:GameStateCanons];
        } break;
        
        case GameStateCanons:
        {
            [self startGameState:GameStateAssault];
        } break;
            
        default:
            break;
    }
}

- (void)timeLeftTimerFire:(id)timer
{
    self.timeProgressView.doubleValue -= self.timeProgressView.maxValue / (GameStateDuration[_gameState] / TIMER_UPDATE_INTERVAL);
    
    if (self.timeProgressView.doubleValue <= 0.0) {
        [self gameStateTimeDidEnd];
    }
}

@end
