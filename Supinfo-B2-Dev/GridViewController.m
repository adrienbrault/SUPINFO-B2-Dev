//
//  GridViewController.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Supinfo_B2_DevAppDelegate.h"
#import "MainMenuViewController.h"


#define TIMER_UPDATE_INTERVAL 0.033
#define CELL_SIZE 14
static NSString *boatAnimationKey = @"boatPosition";
static NSString *boatCannonBallAnimationKey = @"boatCannonBallPosition";
static NSString *gunCannonBallAnimationKey = @"gunCannonBallPosition";

#define BOATS_FIRE_INTERVAL 6.33

#define BOATS_SPEED 10.0
#define CANNON_BALL_SPEED 130.0

#define DISTANCE_TO_SINK_BOAT 30.0


// Possibles shapes
static int possiblesShapesSize = 9;
static BOOL possiblesShapes[9][9] = {
    {
        0, 1, 0,
        1, 1, 1,
        0, 1, 0
    },
    {
        0, 1, 0,
        1, 1, 1,
        0, 0, 0
    },
    {
        1, 1, 1,
        0, 1, 0,
        0, 0, 0
    },
    {
        1, 1, 1,
        1, 0, 0,
        0, 0, 0
    },
    {
        1, 0, 0,
        1, 1, 1,
        0, 0, 0
    },
    {
        1, 0, 0,
        1, 1, 0,
        1, 0, 0
    },
    {
        1, 1, 1,
        1, 0, 0,
        1, 0, 0
    },
    {
        1, 1, 0,
        1, 0, 0,
        1, 1, 0
    },
    {
        0, 0, 1, 
        0, 0, 1,
        1, 1, 1
    }
};


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
- (void)boatViewAnimationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;
- (CGPoint)randomBoatPosition;

@property (nonatomic, retain) NSMutableArray *boatsCanonBallView;

- (void)startBoatsAssault;
- (void)fireBoatsCannonBalls;
- (void)boatCannonBallAnimationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;
- (void)fireCannonBallFromBoat:(BoatView *)boatView;
- (void)removeAllBoatsCannonBalls;

- (void)gunCannonBallAnimationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;
- (void)fireAGunTo:(CGPoint)destination;
- (void)fireCannonBallFromGun:(GridItem *)gun toPosition:(CGPoint)destination;

@property (nonatomic, assign) NSInteger score;

- (void)setNewShape;
- (BOOL)shapesCanBePositionedAt:(ABPoint)position;
- (void)setWallItemsFromShapeAtPosition:(ABPoint)position grid:(AdvancedGrid *)grid;

- (void)enableHandCursor;
- (void)disableHandCursor;

@end


@implementation GridViewController

#pragma mark - Properties

@synthesize mapGridView = _mapGridView;
@synthesize territoryGridView = _territoryGridView;
@synthesize buildingsGridView = _buildingsGridView;
@synthesize previewGridView = _previewGridView;
@synthesize mapView = _mapView;
@synthesize timeProgressView = _timeProgressView;
@synthesize timeLeftLabel = _timeLeftLabel;
@synthesize scoreLabel = _scoreLabel;
@synthesize instructionLabel = _instructionLabel;

@synthesize gridWidth = _gridWidth;
@synthesize gridHeight = _gridHeight;
@synthesize gridTotalIndex = _gridTotalIndex;

@synthesize timeLeftTimer = _timeLeftTimer;

@synthesize boatsCanonBallView = _boatsCanonBallView;

@synthesize score = _score;

- (void)setScore:(NSInteger)score
{
    _score = score;
    if (_score < 0) {
        _score = 0;
    }
    self.scoreLabel.stringValue = [NSString stringWithFormat:@"%d", _score];
}


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _boatsCanonBallView = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.buildingsGridView.grid = nil;
    self.territoryGridView.grid = nil;
    self.buildingsGridView.grid = nil;
    self.previewGridView.grid = nil;
    
    [_mapGrid release];
    [_territoryGrid release];
    [_buildingsGrid release];
    [_previewGrid release];
    
    [self.view removeTrackingArea:_trackingArea];
    [_trackingArea release];
    
    [_timeLeftTimer invalidate];
    [_timeLeftTimer release];
    
    [_boatViews release];
    
    [_boatsCanonBallView release];
    
    [_wallsToDestroy release];
    
    [_gunsReadyToFire release];
    
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
    _previewGrid = [[BuildingsGrid alloc] initWithWidth:_gridWidth height:_gridHeight];
    
    _mapGridView.grid = _mapGrid;
    _territoryGridView.grid = _territoryGrid;
    _buildingsGridView.grid = _buildingsGrid;
    _previewGridView.grid = _previewGrid;
    
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
    // We make sure the mapViews are in the right order.
    [self.mapGridView removeFromSuperview];
    [self.territoryGridView removeFromSuperview];
    [self.buildingsGridView removeFromSuperview];
    [self.previewGridView removeFromSuperview];
    
    [self.mapView addSubview:self.mapGridView];
    [self.mapView addSubview:self.territoryGridView];
    [self.mapView addSubview:self.buildingsGridView];
    [self.mapView addSubview:self.previewGridView];
    
    
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
                [_buildingsGrid setItem:item atPosition:position];
                [_buildingsGridView setNeedsDisplay:YES];
                self.score += 1;
                break;
                
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
    
    [_previewGrid removeAll];
    
    [self disableHandCursor];
    
    ABPoint position = [self positionAtEventMouseLocation:theEvent];
    
    GridItem *mapItem = [_mapGrid itemAtPosition:position];
    if (mapItem && mapItem.type == GridItemEarth) {
        switch (_gameState) {
            case GameStateWallsRepair:
            {
                [self setWallItemsFromShapeAtPosition:position grid:_previewGrid];
                
                if ([self shapesCanBePositionedAt:position]) {
                    [self enableHandCursor];
                }
            } break;
                
            case GameStateCanons:
            {
                GridItem *item = [_territoryGrid itemAtPosition:position];
                
                if (item && item.type == GridItemAreaCaptured) {
                    GridItem *gunItem = [GridItem itemWithType:GridItemGun];
                    if ([self item:gunItem canBePositionedAt:position]) {
                        [_previewGrid setItem:gunItem
                                   atPosition:position];
                        
                        [self enableHandCursor];
                    }
                }
            } break;
                
            default:
                break;
        }
    }
    
    [_previewGridView setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self.nextResponder mouseDown:theEvent];
    
    switch (_gameState) {
        case GameStateWallsRepair:
        {
            ABPoint position = [self positionAtEventMouseLocation:theEvent];
            
            if ([self shapesCanBePositionedAt:position]) {
                [self setWallItemsFromShapeAtPosition:position grid:_buildingsGrid];
                
                [_buildingsGridView setNeedsDisplay:YES];
                
                [self setNewShape];
                
                self.score += 5;
                
                [_previewGrid removeAll];
                [_previewGridView setNeedsDisplay:YES];
            }
            
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
        
        case GameStateAssault:
        {
            NSPoint mouseLocation = [theEvent locationInWindow];
            CGPoint destination = NSPointToCGPoint([self.mapView convertPoint:mouseLocation fromView:self.view]);
            
            [self fireAGunTo:destination];
        } break;
            
        default:
            break;
    }
    
    [self disableHandCursor];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self.nextResponder mouseDragged:theEvent];
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

- (BOOL)isAllMapCaptured
{
    for (NSInteger i=0; i<self.gridTotalIndex; i++) {
        GridItem *mapItem = [_mapGrid itemAtIndex:i];
        GridItem *territoryItem = [_territoryGrid itemAtIndex:i];
        
        if (mapItem && mapItem.type == GridItemEarth
            && !(territoryItem && territoryItem.type == GridItemAreaCaptured)) {
            return NO;
        }
    }
    NSLog(@"all map captured");
    return YES;
}


#pragma mark - Game cycle

- (void)startGameState:(GameStateType)state
{
    if (_gameState == GameStateAssault) {
        [self removeBoats];
    }
    
    if (_gameState == GameStateWallsRepair) {
        [self setNewShape];
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
        [self createBoats:10];
        [self startBoatsAnimations];
        
        [_wallsToDestroy release];
        _wallsToDestroy = [[_buildingsGrid itemsOfType:GridItemWall] mutableCopy];
        
        [_gunsReadyToFire release];
        _gunsReadyToFire = [[_buildingsGrid itemsOfType:GridItemGun] mutableCopy];
        
        [self startBoatsAssault];
    }
    
    [self refreshTerritoryMap];
    
    self.instructionLabel.stringValue = stateLabels[_gameState];
}

- (void)gameStateTimeDidEnd
{
    switch (_gameState) {
        case GameStateWallsRepair:
        {
            if (![self isACastelCaptured]) {
                Supinfo_B2_DevAppDelegate *appDelegate = [NSApp delegate];
                [appDelegate.mainMenu gameEndedWinning:NO score:self.score];
                
                [self.timeLeftTimer invalidate];
                self.timeLeftTimer = nil;
                
                return;
            }
            
            if ([self isAllMapCaptured]) {
                Supinfo_B2_DevAppDelegate *appDelegate = [NSApp delegate];
                [appDelegate.mainMenu gameEndedWinning:YES score:self.score];
                
                [self.timeLeftTimer invalidate];
                self.timeLeftTimer = nil;
                
                return;
            }
            
            // TODO: Check if all map is captured and tell the user that he won.
            
            [self startGameState:GameStateCanons];
        } break;
        
        case GameStateCanons:
        {
            [self startGameState:GameStateAssault];
        } break;
        
        case GameStateAssault:
        {
            [self removeAllBoatsCannonBalls];
            
            [self startGameState:GameStateWallsRepair];
        } break;
            
        default:
            break;
    }
}

- (void)timeLeftTimerFire:(id)timer
{
    self.timeProgressView.doubleValue -= self.timeProgressView.maxValue / (GameStateDuration[_gameState] / TIMER_UPDATE_INTERVAL);
    self.timeLeftLabel.title = [NSString stringWithFormat:@"%1.1f s", ((self.timeProgressView.doubleValue / self.timeProgressView.maxValue) * GameStateDuration[_gameState])];
    
    if (self.timeProgressView.doubleValue <= 0.0) {
        [self gameStateTimeDidEnd];
    }
}


#pragma mark - Boat management

- (void)createBoats:(NSInteger)number
{
    [self removeBoats];
    
    NSMutableArray *boatsViews = [[NSMutableArray alloc] init];
    
    CGSize imageSize = NSSizeToCGSize([BoatView boatImage].size);
    
    for (NSInteger i=0; i<number; i++) {
        CGPoint randomPosition = [self randomBoatPosition];
        BoatView *boatView = [[BoatView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(randomPosition.x,
                                                                                         randomPosition.y,
                                                                                         imageSize.width,
                                                                                         imageSize.height))];
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
    CGFloat speed = ((arc4random() % 30) / 10 + 1) * BOATS_SPEED; // In pixels/sec
    
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
    animation.toValue = [NSValue valueWithPoint:NSPointFromCGPoint(randomPosition)];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    
    [boatView setFrameOrigin:NSPointFromCGPoint(randomPosition)];
    
    [animation setValue:boatAnimationKey forKey:@"key"];
    [animation setValue:boatView forKey:@"boatView"];
    [boatView.layer addAnimation:animation forKey:boatAnimationKey];
}

- (void)boatViewAnimationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    BoatView *boatView = [theAnimation valueForKey:@"boatView"];
    [boatView.layer removeAnimationForKey:boatAnimationKey];
    [self animateBoatView:boatView];
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
    [self.view setFrameSize:NSSizeFromCGSize(CGSizeMake(CELL_SIZE * self.gridWidth,
                                                        CELL_SIZE * self.gridHeight + self.timeProgressView.frame.size.height))];
    
    CGRect windowFrame = CGRectMake(self.view.window.frame.origin.x,
                                    self.view.window.frame.origin.y,
                                    self.view.frame.size.width,
                                    self.view.frame.size.height);
    
    [self.view.window setFrame:NSRectFromCGRect(windowFrame)
                       display:YES];
    
    [self.view setFrame:[self.view.window.contentView bounds]];
    
    // Locking window aspect ratio and setting minimum size.
    [self.view.window setAspectRatio:self.view.window.frame.size];
    [self.view.window setMinSize:NSSizeFromCGSize(CGSizeMake(300.0, 300.0))];
    
    [self setTrackingArea];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if ([theAnimation valueForKey:@"key"] == boatAnimationKey) {
        [self boatViewAnimationDidStop:theAnimation finished:flag];
    } else if ([theAnimation valueForKey:@"key"] == boatCannonBallAnimationKey) {
        [self boatCannonBallAnimationDidStop:theAnimation finished:flag];
    } else if ([theAnimation valueForKey:@"key"] == gunCannonBallAnimationKey) {
        [self gunCannonBallAnimationDidStop:theAnimation finished:flag];
    }
}


#pragma mark - Boat cannonBalls

- (void)startBoatsAssault
{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(fireBoatsCannonBalls)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)fireBoatsCannonBalls
{
    for (BoatView *boatView in _boatViews) {
        [self fireCannonBallFromBoat:boatView];
        if ([_wallsToDestroy count] < 1) {
            break;
        }
    }
}

- (void)boatCannonBallAnimationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    // Remove cannon ball
    CannonBallView *ballView = [theAnimation valueForKey:@"cannonBallView"];
    [_boatsCanonBallView removeObject:ballView];
    [ballView removeFromSuperview];
    [ballView.layer removeAnimationForKey:boatCannonBallAnimationKey];
    
    // Remove wall
    [_buildingsGrid removeItem:[theAnimation valueForKey:@"wall"]];
    [self.buildingsGridView setNeedsDisplay:YES];
    
    self.score -= 1;
    
    // Fire again
    [self fireCannonBallFromBoat:[theAnimation valueForKey:@"boat"]];
    
}

- (void)fireCannonBallFromBoat:(BoatView *)boatView
{
    if (!([_wallsToDestroy count] > 0)) {
        return;
    }
    
    if (![_boatViews containsObject:boatView]) {
        return;
    }
    
    GridItem *wall = [_wallsToDestroy objectAtIndex:arc4random() % [_wallsToDestroy count]];
    [_wallsToDestroy removeObject:wall];
    
    if (wall && [wall isKindOfClass:[GridItem class]] && wall.type == GridItemWall) {
        CannonBallView *ballView = [[CannonBallView alloc] init];
        ballView.wantsLayer = YES;
        
        [self.mapView addSubview:ballView];
        [_boatsCanonBallView addObject:ballView];
        
        CGPoint destination = [self.buildingsGridView screenPositionForItem:wall atPosition:wall.cachePosition];
        destination.y = self.mapView.frame.size.height - destination.y - CELL_SIZE / 2.0;
        destination.x += CELL_SIZE / 2.0;
        
        CGPoint origin = ((CALayer*)boatView.layer.presentationLayer).position;
        // The presentation layer has the current animation position of the layer.
        
        CGFloat speed = CANNON_BALL_SPEED;
        CGFloat distance = sqrt(pow((destination.x - origin.x), 2) + pow((destination.y - origin.y), 2));
        CGFloat duration = distance / speed;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithPoint:NSPointFromCGPoint(origin)];
        animation.toValue = [NSValue valueWithPoint:NSPointFromCGPoint(destination)];
        animation.duration = duration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        animation.delegate = self;
        animation.removedOnCompletion = NO;
        
        [ballView setFrameOrigin:NSPointFromCGPoint(destination)];
        
        [animation setValue:boatCannonBallAnimationKey forKey:@"key"];
        [animation setValue:ballView forKey:@"cannonBallView"];
        [animation setValue:wall forKey:@"wall"];
        [animation setValue:boatView forKey:@"boat"];
        [ballView.layer addAnimation:animation forKey:boatCannonBallAnimationKey];
    }
}

- (void)removeAllBoatsCannonBalls
{
    for (CannonBallView *ball in _boatsCanonBallView) {
        [ball.layer removeAllAnimations];
        [ball removeFromSuperview];
    }
    
    [_boatsCanonBallView removeAllObjects];
}


#pragma mark - Gun firing management

- (void)gunCannonBallAnimationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    // Remove cannon ball from screen.
    CannonBallView *ballView = [theAnimation valueForKey:@"cannonBallView"];
    [ballView removeFromSuperview];
    [ballView.layer removeAnimationForKey:gunCannonBallAnimationKey];
    
    // Sink boats.
    CABasicAnimation *basicAnimation = (CABasicAnimation *)theAnimation;
    CGPoint destination = NSPointToCGPoint([basicAnimation.toValue pointValue]);
    NSMutableArray *boatsToSink = [NSMutableArray array]; // We can't remove objects from an array while enumerating it.
    
    for (BoatView *boatView in _boatViews) {
        CGPoint boatPosition = ((CALayer*)boatView.layer.presentationLayer).position;
        CGFloat distance = sqrt(pow((destination.x - boatPosition.x), 2) + pow((destination.y - boatPosition.y), 2));
        
        if (distance <= DISTANCE_TO_SINK_BOAT) {
            [boatView removeFromSuperview];
            [boatView.layer removeAllAnimations];
            
            [boatsToSink addObject:boatView];
        }
    }
    
    for (BoatView *boatView in boatsToSink) {
        [_boatViews removeObject:boatView];
        self.score += 5;
    }
    
    // Add the gun back to the pool.
    GridItem *gun = [theAnimation valueForKey:@"gun"];
    [_gunsReadyToFire addObject:gun];
}

- (void)fireAGunTo:(CGPoint)destination
{
    if ([_gunsReadyToFire count] > 0) {
        NSInteger gunIndex = arc4random() % [_gunsReadyToFire count];
        GridItem *gun = [_gunsReadyToFire objectAtIndex:gunIndex];
        
        [_gunsReadyToFire removeObject:gun];
        
        [self fireCannonBallFromGun:gun toPosition:destination];
    }
}

- (void)fireCannonBallFromGun:(GridItem *)gun toPosition:(CGPoint)destination
{
    CannonBallView *ballView = [[CannonBallView alloc] init];
    ballView.wantsLayer = YES;
    
    [self.mapView addSubview:ballView];
    
    CGPoint origin = [self.buildingsGridView screenPositionForItem:gun atPosition:gun.cachePosition];
    origin.x += CELL_SIZE / 2.0;
    origin.y = self.mapView.frame.size.height - origin.y - CELL_SIZE / 2.0;
    
    CGFloat speed = CANNON_BALL_SPEED;
    CGFloat distance = sqrt(pow((destination.x - origin.x), 2) + pow((destination.y - origin.y), 2));
    CGFloat duration = distance / speed;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithPoint:NSPointFromCGPoint(origin)];
    animation.toValue = [NSValue valueWithPoint:NSPointFromCGPoint(destination)];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    
    [animation setValue:gunCannonBallAnimationKey forKey:@"key"];
    [animation setValue:ballView forKey:@"cannonBallView"];
    [animation setValue:gun forKey:@"gun"];
    [ballView.layer addAnimation:animation forKey:gunCannonBallAnimationKey];
}


#pragma mark - Wall shapes

- (void)setNewShape
{
    NSInteger randomIndex = arc4random() % possiblesShapesSize;
    
    for (NSInteger i=0; i<9; i++) {
        _wallShapes[i] = possiblesShapes[randomIndex][i];
    }
}

- (BOOL)shapesCanBePositionedAt:(ABPoint)position
{
    GridItem *wall = [GridItem itemWithType:GridItemWall];
    
    for (NSInteger i=0; i<9; i++) {
        if (_wallShapes[i]) {
            ABPoint currentPosition = ABPointMake(position.x + (i % 3), position.y + (i / 3));
            
            if (![self item:wall canBePositionedAt:currentPosition]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)setWallItemsFromShapeAtPosition:(ABPoint)position grid:(AdvancedGrid *)grid
{
    for (NSInteger i=0; i<9; i++) {
        if (_wallShapes[i]) {
            GridItem *wall = [GridItem itemWithType:GridItemWall];
            ABPoint wallPosition = ABPointMake(position.x + (i % 3), position.y + (i / 3));
            [grid setItem:wall atPosition:wallPosition];
        }
    }
}


#pragma mark - Cursor

- (void)enableHandCursor
{
    [[self.mapView superview] addCursorRect:self.mapView.frame
                                     cursor:[NSCursor pointingHandCursor]];
}

- (void)disableHandCursor
{
    [[self.mapView superview] removeCursorRect:self.mapView.frame
                                        cursor:[NSCursor pointingHandCursor]];
}

@end
