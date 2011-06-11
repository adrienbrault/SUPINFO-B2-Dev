//
//  MainMenuViewController.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 11/06/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GridViewController;

@interface MainMenuViewController : NSViewController {
    GridViewController *_gridVC;
    NSTextField *_resultLabel;
    NSButton *_startGameButton;
}

@property (assign) IBOutlet NSTextField *resultLabel;
@property (assign) IBOutlet NSButton *startGameButton;

- (IBAction)startNewGame:(id)sender;

- (void)gameEndedWinning:(BOOL)flag;

@end
