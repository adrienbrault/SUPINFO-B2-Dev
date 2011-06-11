//
//  Supinfo_B2_DevAppDelegate.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Supinfo_B2_DevAppDelegate.h"

#import "MainMenuViewController.h"

@implementation Supinfo_B2_DevAppDelegate

@synthesize window, mainMenu = _mainMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _mainMenu = [[MainMenuViewController alloc] init];
    
    self.window.contentView = self.mainMenu.view;
    
    [self.window setMinSize:NSSizeFromCGSize(CGSizeMake(300.0, 300.0))];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
    return YES;
}

@end
