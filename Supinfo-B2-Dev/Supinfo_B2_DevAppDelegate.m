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
    gridVC.view.frame = [self.window.contentView bounds];
    [self.window.contentView addSubview:gridVC.view];
    
    [gridVC setWidth:100 height:100];
}

@end
