//
//  GridViewController.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridViewController.h"
#import <QuartzCore/QuartzCore.h>


#define TIMER_UPDATE_INTERVAL 0.033
#define CELL_SIZE 16
static NSString *boatAnimationKey = @"boatPosition";


@interface GridViewController ()

- (void)loadDefaultMap;

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position;
- (BOOL)item:(GridItem *)item canBePositionedAt:(ABPoint)position;

- (ABPoint)positionAtMouseLocation:(NSPoint)mouseLocation;
- (ABPoint)positionAtEventMouseLocation:(NSEvent *)theEvent;

- (void)setTrackingArea;

- (void)refreshTerritoryMap;
- (BOOL)isACastelCaptured;

- (void)startGameState:(GameStateType)state;
- (void)gameStateTimeDidEnd;
- (void)timeLeftTimerFire:(id)timer;

@property (nonatomic, retain) NSTimer *timeLeftTimer;

- (void)createBoats:(NSInteger)number;
- (void)removeBoats;
- (void)startBoatsAnimations;
- (void)animateBoatView:(BoatView *)boatView;
- (CGPoint)randomBoatPosition;

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
    
    [_mapView release];
    [_timeProgressView release];
    
    [_trackingArea release];
    
    [_timeLeftTimer release];
    
    [_boatViews release];
    
    [super dealloc];
}


#pragma mark - Map management

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
    
    [self startGameState:GameStateWallsRepair];
}

- (void)loadDefaultMap
{
    NSLog(@"Loading default map");
    
    // The NSAutoreleasePool is here for memory optimization.
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


#pragma mark - Grid helpers

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position
{
    if ([self item:item canBePositionedAt:position]) {
        switch (item.type) {
            case GridItemWall:
            case GridItemCastel:
            case GridItemGun:
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
        case GridItemGun:
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
        case GameStateWallsRepair:
        {
            ABPoint position = [self positionAtEventMouseLocation:theEvent];
            
            [self setItem:[GridItem itemWithType:GridItemWall]
               atPosition:position];
            
            [self refreshTerritoryMap];
        } break;
        
        case GameStateCanons:
        {
            ABPoint position = [self positionAtEventMouseLocation:theEvent];
            GridItem *item = [_territoryGrid itemAtPosition:position];
            
            if (item && item.type == GridItemAreaCaptured) {
                [self setItem:[GridItem itemWithType:GridItemGun]
                   atPosition:position];
            }
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
        case GameStateWallsRepair:
        {
            ABPoint position = [self positionAtEventMouseLocation:theEvent];
            
            [self setItem:[GridItem itemWithType:GridItemWall]
               atPosition:position];
            
            [self refreshTerritoryMap];
        } break;
        
        case GameStateCanons:
        {
            ABPoint position = [self positionAtEventMouseLocation:theEvent];
            GridItem *item = [_territoryGrid itemAtPosition:position];
            
            if (item && item.type == GridItemAreaCaptured) {
                [self setItem:[GridItem itemWithType:GridItemGun]
                   atPosition:position];
            }
        } break;
            
        default:
            break;
    }
}


#pragma mark - Mouse helper

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

- (BOOL)isACastelCaptured
{
    NSSet *castelsSet = [_buildingsGrid castels];
    
    for (GridItem *item in castelsSet) {
        GridItem *territoryItem = [_territoryGrid itemAtPosition:item.cachePosition];
        if (territoryItem && territoryItem.type == GridItemAreaCaptured) {
            return YES;
        }
    }
    
    return NO;
}


#pragma mark - Game cycle

- (void)startGameState:(GameStateType)state
{
    if (_gameState == GameStateAssault) {
        [self removeBoats];
    }
    
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
    
    if (_gameState == GameStateAssault) {
        [self createBoats:20];
        [self startBoatsAnimations];
    }
}

- (void)gameStateTimeDidEnd
{
    switch (_gameState) {
        case GameStateWallsRepair:
        {
            if (![self isACastelCaptured]) {
                NSLog(@"You lose.");
                [NSApp terminate:nil];
            }
            
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


#pragma mark - Boat management

- (void)createBoats:(NSInteger)number
{
    [self removeBoats];
    
    NSMutableArray *boatsViews = [[NSMutableArray alloc] init];
    
    CGSize imageSize = [BoatView boatImage].size;
    
    for (NSInteger i=0; i<number; i++) {
        CGPoint randomPosition = [self randomBoatPosition];
        BoatView *boatView = [[BoatView alloc] initWithFrame:CGRectMake(randomPosition.x,
                                                                        randomPosition.y,
                                                                        imageSize.width,
                                                                        imageSize.height)];
        boatView.wantsLayer = YES;
        [self.mapView addSubview:boatView];
        [boatsViews addObject:boatView];
    }
    
    _boatViews = boatsViews;
}

- (void)removeBoats
{
    for (BoatView *boatView in _boatViews) {
        [boatView.layer removeAllAnimations];
        [boatView removeFromSuperview];
    }
    
    [_boatViews release];
    _boatViews = nil;
}

- (void)startBoatsAnimations
{
    for (BoatView *boatView in _boatViews) {
        [self animateBoatView:boatView];
    }
}

- (void)animateBoatView:(BoatView *)boatView
{
    CGFloat speed = (arc4random() % 3 + 1) * 10; // In pixels/sec
    
    CGFloat distance = 0;
    CGPoint randomPosition;
    
    CGFloat minimumDistance = _mapView.frame.size.width / 10.0;
    
    while (distance < minimumDistance) {
        randomPosition = [self randomBoatPosition];
        
        distance = sqrt(pow(boatView.frame.origin.x - randomPosition.x, 2)
                        + pow(boatView.frame.origin.y - randomPosition.y, 2));

    }
    
    CGFloat duration = distance / speed;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithPoint:boatView.frame.origin];
    animation.toValue = [NSValue valueWithPoint:randomPosition];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    
    [boatView setFrameOrigin:randomPosition];
    
    [boatView.layer addAnimation:animation forKey:boatAnimationKey];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (flag) {
        for (BoatView *boatView in _boatViews) {
            if ([boatView.layer animationForKey:boatAnimationKey] == theAnimation) {
                [boatView.layer removeAnimationForKey:boatAnimationKey];
                [self animateBoatView:boatView];
                return;
            }
        }
    }
}

- (CGPoint)randomBoatPosition
{
    ABPoint randomPosition;
    BOOL validPosition = NO;
    
    while (!validPosition) {
        randomPosition = ABPointMake(arc4random() % _gridWidth, arc4random() % _gridHeight);
        validPosition = [_mapGrid itemAtPosition:randomPosition].type == GridItemWater;
    }
    
    CGSize cellSize = CGSizeMake(self.mapView.frame.size.width / _gridWidth,
                                 self.mapView.frame.size.height / _gridHeight);
    
    CGFloat xOffset = - ((arc4random() % 100) / 100.0) * cellSize.width;
    CGFloat yOffset = + ((arc4random() % 100) / 100.0) * cellSize.height;
    
    return CGPointMake(randomPosition.x * cellSize.width + xOffset,
                       self.mapView.frame.size.height - (randomPosition.y + 1) * cellSize.height + yOffset);
}


#pragma mark -

- (void)setCorrectViewSize
{
    [self.view setFrameSize:CGSizeMake(CELL_SIZE * self.gridWidth,
                                       CELL_SIZE * self.gridHeight + self.timeProgressView.frame.size.height)];
}

@end
