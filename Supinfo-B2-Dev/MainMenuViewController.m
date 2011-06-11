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
@synthesize menuView = _menuView;

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
    
    self.menuView.hidden = YES;
}

- (void)gameEndedWinning:(BOOL)flag score:(NSInteger)score
{
    _gridVC.view.window.delegate = nil;
    [_gridVC.view removeFromSuperview];
    
    [_gridVC release];
    _gridVC = nil;
    
    NSString *resultText = flag ? @"Win" : @"Lose";
    resultText = [NSString stringWithFormat:@"%@ - Score: %d", resultText, score];
    self.resultLabel.stringValue = resultText;
    
    self.menuView.hidden = NO;
}

@end
