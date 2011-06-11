//
//  Supinfo_B2_DevAppDelegate.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Supinfo_B2_DevAppDelegate.h"

#import "GridViewController.h"

@implementation Supinfo_B2_DevAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    GridViewController *gridVC = [[GridViewController alloc] init];
    [self.window.contentView addSubview:gridVC.view];
    
    [gridVC setWidth:46 height:34];
    
    // Setting window size.
    [gridVC setCorrectViewSize];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
    return YES;
}

@end
