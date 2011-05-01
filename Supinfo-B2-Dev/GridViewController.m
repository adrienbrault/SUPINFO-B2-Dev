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

@end


@implementation GridViewController

#pragma mark - Properties

@synthesize mapGridView = _mapGridView;
@synthesize territoryGridView = _territoryGridView;
@synthesize buildingsGridView = _buildingsGridView;

@synthesize gridWidth = _gridWidth;
@synthesize gridHeight = _gridHeight;


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
    
    _mapGrid = [[Grid alloc] initWithWidth:_gridWidth height:_gridHeight];
    _territoryGrid = [[Grid alloc] initWithWidth:_gridWidth height:_gridHeight];
    _buildingsGrid = [[Grid alloc] initWithWidth:_gridWidth height:_gridHeight];
    
    _mapGridView.grid = _mapGrid;
    _territoryGridView.grid = _territoryGrid;
    _buildingsGridView.grid = _buildingsGrid;
    
    // Mouse tracking (mouseMoved and mouseEntered + mouseExited)
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.frame
                                                 options:( NSTrackingMouseEnteredAndExited
                                                          | NSTrackingMouseMoved
                                                          | NSTrackingActiveInKeyWindow )
                                                   owner:self
                                                userInfo:nil];
    
    [self.view addTrackingArea:_trackingArea];
    
    // Mouse down event.
    [self setNextResponder:self.view.nextResponder];
    [self.view setNextResponder:self];
    
    [self loadDefaultMap];
}

- (void)loadDefaultMap
{
    int totalItems = _gridWidth * _gridHeight;
    for (int i=0; i<totalItems; i++) {
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
    
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(3*_gridWidth/4, _gridHeight/4)];
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(2*_gridWidth/4, 2*_gridHeight/4)];
    [self setItem:[GridItem itemWithType:GridItemCastel] atPosition:ABPointMake(_gridWidth/4, _gridHeight/4)];
    
    [_mapGridView setNeedsDisplay:YES];
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
    NSLog(@"%@", theEvent);
    
    ABPoint position = [self positionAtEventMouseLocation:theEvent];
    
    [self setItem:[GridItem itemWithType:GridItemWall]
       atPosition:position];
    
    [self.nextResponder mouseDown:theEvent];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSLog(@"%@", theEvent);
    
    [self.nextResponder mouseDown:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSLog(@"%@", theEvent);
    
    [self.nextResponder mouseDown:theEvent];
}


#pragma mark - Mouse stuff

- (ABPoint)positionAtMouseLocation:(NSPoint)mouseLocation
{
    return ABPointMake(ceil((mouseLocation.x + 1.0) / (self.view.frame.size.width / _gridWidth)) - 1,
                       ceil((self.view.frame.size.height - mouseLocation.y + 1.0) / (self.view.frame.size.height / _gridHeight)) - 1);
}

- (ABPoint)positionAtEventMouseLocation:(NSEvent *)theEvent
{
    NSPoint mouseLocation = [theEvent locationInWindow];
    mouseLocation = [self.view convertPoint:mouseLocation fromView:nil];
    
    return [self positionAtMouseLocation:mouseLocation];
}

@end
