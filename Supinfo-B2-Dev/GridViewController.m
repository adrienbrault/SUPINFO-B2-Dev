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
    
    [super dealloc];
}


#pragma mark -

- (void)setWidth:(int)width height:(int)height
{NSLog(@"hey");
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
    
    [self loadDefaultMap];
}

- (void)loadDefaultMap
{
    int totalItems = _gridWidth*_gridHeight;
    for (int i=0; i<totalItems; i++) {
        GridItemType itemType;
        
        // Weird condition that make the map look cool.
        if (i < ceil(totalItems/2)
            || (i % _gridWidth) < (_gridHeight - i / _gridHeight) * 2) {
            itemType = GridItemEarth;
        } else {
            itemType = GridItemWater;
        }
        
        [_mapGrid setItem:[GridItem itemWithType:itemType]
               atPosition:ABPointMake(i % _gridWidth, ceil(i / _gridHeight))];
    }
    [_mapGridView setNeedsDisplay:YES];
}

@end
