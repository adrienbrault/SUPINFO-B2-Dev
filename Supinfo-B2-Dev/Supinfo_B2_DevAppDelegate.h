//
//  Supinfo_B2_DevAppDelegate.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainMenuViewController;

@interface Supinfo_B2_DevAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    
    MainMenuViewController *_mainMenu;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) MainMenuViewController *mainMenu;

@end
