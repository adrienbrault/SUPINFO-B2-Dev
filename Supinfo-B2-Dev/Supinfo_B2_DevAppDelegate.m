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
    
    CGRect windowFrame = CGRectMake(self.window.frame.origin.x,
                                    self.window.frame.origin.y,
                                    gridVC.view.frame.size.width,
                                    gridVC.view.frame.size.height);
    
    [self.window setFrame:windowFrame
                  display:YES];
    
    [gridVC.view setFrame:[self.window.contentView bounds]];
    
    // Locking window aspect ratio and setting minimum size.
    [self.window setAspectRatio:self.window.frame.size];
    [self.window setMinSize:CGSizeMake(300.0, 300.0)];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
    return YES;
}

@end
