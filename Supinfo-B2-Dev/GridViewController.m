//
//  GridViewController.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController (Private)

- (void)loadDefaultMap;

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position;
- (BOOL)item:(GridItem *)item canBePositionedAt:(ABPoint)position;

- (ABPoint)positionAtMouseLocation:(NSPoint)mouseLocation;
- (ABPoint)positionAtEventMouseLocation:(NSEvent *)theEvent;

- (void)setTrackingArea;


- (NSArray *)capturedTeritoryIndexes;
- (BOOL)checkIndexes;
- (void)findNextIndexes;
- (BOOL)isIndexAWall:(int)index;
- (NSMutableSet *)borderIndexes;

@end


@implementation GridViewController

#pragma mark - Properties

@synthesize mapGridView = _mapGridView;
@synthesize territoryGridView = _territoryGridView;
@synthesize buildingsGridView = _buildingsGridView;

@synthesize gridWidth = _gridWidth;
@synthesize gridHeight = _gridHeight;
@synthesize gridTotalIndex = _gridTotalIndex;


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

- (void)setWidth:(int)width height:(int)height
{
    if (!(width > 0 && height > 0)) {
        [NSException raise:@"GridViewControllerException" format:@"Exception: Width and height must be greater than 0."];
    }
    
    _gridWidth = width;
    _gridHeight = height;
    _gridTotalIndex = _gridWidth * _gridHeight;
    
    _mapGrid = [[Grid alloc] initWithWidth:_gridWidth height:_gridHeight];
    _territoryGrid = [[Grid alloc] initWithWidth:_gridWidth height:_gridHeight];
    _buildingsGrid = [[Grid alloc] initWithWidth:_gridWidth height:_gridHeight];
    
    _mapGridView.grid = _mapGrid;
    _territoryGridView.grid = _territoryGrid;
    _buildingsGridView.grid = _buildingsGrid;
    
    self.view.window.delegate = self;
    [self setTrackingArea];
    
    // Mouse down event.
    [self setNextResponder:self.view.nextResponder];
    [self.view setNextResponder:self];
    
    [self loadDefaultMap];
}

- (void)loadDefaultMap
{
    NSLog(@"Loading default map");
    
    NSAutoreleasePool *pool = nil;
    
    int totalItems = _gridWidth * _gridHeight;
    for (int i=0; i<totalItems; i++) {
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
    
    /*
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(3*_gridWidth/4, 1*_gridHeight/7)];
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(_gridWidth/6, 2*_gridHeight/4)];
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(_gridWidth/4, _gridHeight/4)];
     */
    
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
    if (item.type == GridItemWall
        || item.type == GridItemCastel
        || item.type == GridItemAreaCaptured
        || item.type == GridItemTower) {
        NSSet *positions = [_mapGrid positionsForItem:item atPosition:position];
        for (NSValue *value in positions) {
            ABPoint position = ABPointFromValue(value);
            if ([_mapGrid itemAtPosition:position].type != GridItemEarth || [_buildingsGrid itemAtPosition:position]) {
                return NO;
            }
        }
    }
    
    return YES;
}


#pragma mark - Mouse events

- (void)mouseMoved:(NSEvent *)theEvent
{
    
    //[self.nextResponder mouseMoved:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"%@", theEvent);
    
    ABPoint position = [self positionAtEventMouseLocation:theEvent];
    
    [self setItem:[GridItem itemWithType:GridItemWall]
       atPosition:position];
    
    [self.nextResponder mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    //NSLog(@"%@", theEvent);
    
    ABPoint position = [self positionAtEventMouseLocation:theEvent];
    NSLog(@"%d %d", position.x, position.y);
    [self setItem:[GridItem itemWithType:GridItemWall]
       atPosition:position];
    
    [self.nextResponder mouseDown:theEvent];
}


#pragma mark - Mouse stuff

- (ABPoint)positionAtMouseLocation:(NSPoint)mouseLocation
{
    ABPoint position = ABPointMake(ceil((mouseLocation.x + 1.0) / (self.view.frame.size.width / _gridWidth)) - 1,
                       ceil((self.view.frame.size.height - mouseLocation.y + 1.0) / (self.view.frame.size.height / _gridHeight)) - 1);
    
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
    mouseLocation = [self.view convertPoint:mouseLocation fromView:self.view];
    
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
                                                          | NSTrackingActiveInKeyWindow )
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


#pragma mark - Algorithms

- (NSArray *)capturedTeritoryIndexes
{
    // Calloc init all values to 0.
    _indexesStatus = calloc(self.gridTotalIndex, sizeof(char)); /*** 1: Free || 2: Occupied ***/
    _indexesDone = calloc(self.gridTotalIndex, sizeof(BOOL));
    
    // We start from borders.
    _indexesToProcess = [self borderIndexes];
    
    BOOL anIndexIsCorrect = [self checkIndexes];
    
    while (anIndexIsCorrect) {
        [self findNextIndexes];
        anIndexIsCorrect = [self checkIndexes];
    }
    
    NSMutableArray *positionsStatus = [NSMutableArray arrayWithCapacity:self.gridTotalIndex];
    for (int i=0; i<self.gridTotalIndex; i++) {
        char status = _indexesStatus[i];
        BOOL isOccupied = (status != 1) ? YES : NO;
        [positionsStatus addObject:[NSNumber numberWithBool:isOccupied]];
    }
    
    free(_indexesStatus);
    free(_indexesDone);
    
    return positionsStatus;
}

- (BOOL)checkIndexes
{
    BOOL anIndexIsCorrect = NO;
    NSMutableSet *numbersToRemove = [NSMutableSet set];
    
    for (NSNumber *number in _indexesToProcess) {
        int currentIndex = [number intValue];
        
        if ([self isIndexAWall:currentIndex]) {
            _indexesStatus[currentIndex] = 2;
            [numbersToRemove addObject:number];
        } else {
            _indexesStatus[currentIndex] = 1;
            anIndexIsCorrect = YES;
        }
        
        _indexesDone[currentIndex] = YES;
    }
    
    for (NSNumber *number in numbersToRemove) {
        [_indexesToProcess removeObject:number];
    }
    
    return anIndexIsCorrect;
}

- (void)findNextIndexes
{
    NSMutableSet *newIndexesToProcess = [NSMutableSet set];
    
    for (NSNumber *number in _indexesToProcess) {
        int index = [number intValue];
        ABPoint indexPosition = [_mapGrid positionForIndex:index];
        
        int positionNextToCurrentIndex[8] = {
            [_mapGrid indexForPosition:ABPointMake(indexPosition.x - 1, indexPosition.y - 1)],
            [_mapGrid indexForPosition:ABPointMake(indexPosition.x + 0, indexPosition.y - 1)],
            [_mapGrid indexForPosition:ABPointMake(indexPosition.x + 1, indexPosition.y - 1)],
            [_mapGrid indexForPosition:ABPointMake(indexPosition.x + 1, indexPosition.y + 0)],
            [_mapGrid indexForPosition:ABPointMake(indexPosition.x + 1, indexPosition.y + 1)],
            [_mapGrid indexForPosition:ABPointMake(indexPosition.x + 0, indexPosition.y + 1)],
            [_mapGrid indexForPosition:ABPointMake(indexPosition.x - 1, indexPosition.y + 1)],
            [_mapGrid indexForPosition:ABPointMake(indexPosition.x - 1, indexPosition.y + 0)]
        };
        
        for (int i=0; i<8; i++) {
            int currentPossibleIndex = positionNextToCurrentIndex[i];
            
            if (currentPossibleIndex > 0 && currentPossibleIndex < self.gridTotalIndex
                && !_indexesDone[currentPossibleIndex]) {
                [newIndexesToProcess addObject:[NSNumber numberWithInt:currentPossibleIndex]];
            }
        }
    }
    
    _indexesToProcess = newIndexesToProcess;
}

- (NSMutableSet *)borderIndexes
{
    int totalIndex = _gridWidth * _gridHeight;
    
    NSMutableSet *borderIndexes = [NSMutableArray array];
    
    // Top border.
    for (int i = 0;
         i<_gridWidth;
         i++)
    {
        [borderIndexes addObject:[NSNumber numberWithInt:i]];
    }
    
    // Right border.
    for (int i = _gridWidth * 2.0 - 1;
         (i + 1) % _gridWidth == 0 && i < totalIndex;
         i += _gridWidth)
    {
        [borderIndexes addObject:[NSNumber numberWithInt:i]];
    }
    
    // Left border.
    for (int i = _gridWidth;
         i % _gridWidth == 0 && i < totalIndex;
         i += _gridWidth)
    {
        [borderIndexes addObject:[NSNumber numberWithInt:i]];
    }
    
    // Bottom border.
    for (int i = totalIndex - _gridWidth;
         i < totalIndex - 1;
         i++)
    {
        [borderIndexes addObject:[NSNumber numberWithInt:i]];
    }
    
    return borderIndexes;
}

- (BOOL)isIndexAWall:(int)index
{
    GridItem *item = [_buildingsGrid itemAtIndex:index];
    
    if (item && item.type == GridItemWall) {
        return YES;
    }
    
    return NO;
}

#pragma mark - IBActions

- (IBAction)testAlgo:(id)sender
{
    [_territoryGrid setTerritoryIndexesStatus:[self capturedTeritoryIndexes]];
    [_territoryGridView setNeedsDisplay:YES];
}

@end
