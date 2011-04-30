//
//  Supinfo_B2_DevAppDelegate.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Supinfo_B2_DevAppDelegate.h"

#import "Grid.h"
#import "GridView.h"

@implementation Supinfo_B2_DevAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    
    // MAP
    
    Grid *mapGrid = [[Grid alloc] initWithWidth:3 height:3];
    
    [mapGrid setItem:[GridItem itemWithType:GridItemEarth]
        atPosition:ABPointMake(0, 0)];
    [mapGrid setItem:[GridItem itemWithType:GridItemEarth]
        atPosition:ABPointMake(1, 0)];
    [mapGrid setItem:[GridItem itemWithType:GridItemEarth]
        atPosition:ABPointMake(2, 0)];
    
    [mapGrid setItem:[GridItem itemWithType:GridItemEarth]
        atPosition:ABPointMake(0, 1)];
    [mapGrid setItem:[GridItem itemWithType:GridItemEarth]
        atPosition:ABPointMake(1, 1)];
    [mapGrid setItem:[GridItem itemWithType:GridItemEarth]
        atPosition:ABPointMake(2, 1)];
    
    [mapGrid setItem:[GridItem itemWithType:GridItemEarth]
        atPosition:ABPointMake(0, 2)];
    [mapGrid setItem:[GridItem itemWithType:GridItemWater]
        atPosition:ABPointMake(1, 2)];
    [mapGrid setItem:[GridItem itemWithType:GridItemWater]
        atPosition:ABPointMake(2, 2)];
    
    
    // Walls
    
    Grid *wallGrid = [[Grid alloc] initWithWidth:3 height:3];
    
    [wallGrid setItem:[GridItem itemWithType:GridItemWall] atPosition:ABPointMake(1, 1)];
    

    // Views
    
    CGRect contentViewFrame = [self.window.contentView frame];
    CGRect gridViewFrame = CGRectMake(0.0, 0.0, contentViewFrame.size.width, contentViewFrame.size.height);
    
    GridView *mapGridView = [[GridView alloc] initWithFrame:gridViewFrame];
    mapGridView.grid = mapGrid;
    
    [self.window.contentView addSubview:mapGridView];
    
    
    GridView *wallGridView = [[GridView alloc] initWithFrame:gridViewFrame];
    wallGridView.grid = wallGrid;
    
    [self.window.contentView addSubview:wallGridView];
}

@end
