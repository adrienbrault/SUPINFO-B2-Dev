//
//  MainMenuViewController.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 11/06/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "MainMenuViewController.h"
#import "GridViewController.h"

@implementation MainMenuViewController
@synthesize resultLabel = _resultLabel;
@synthesize startGameButton = _startGameButton;

- (id)init
{
    if ((self = [super initWithNibName:@"MainMenuViewController" bundle:nil])) {
        
    }
    return self;
}

- (IBAction)startNewGame:(id)sender {
    _gridVC = [[GridViewController alloc] init];
    [self.view addSubview:_gridVC.view];
    
    [_gridVC setWidth:46 height:34];
    
    // Setting window size.
    [_gridVC setCorrectViewSize];
    
    self.startGameButton.hidden = YES;
}

- (void)gameEndedWinning:(BOOL)flag
{
    _gridVC.view.window.delegate = nil;
    [_gridVC.view removeFromSuperview];
    
    [_gridVC release];
    _gridVC = nil;
    
    NSString *resultText = flag ? @"Win" : @"Lose";
    self.resultLabel.stringValue = resultText;
    
    self.startGameButton.hidden = NO;
}

@end
