//
//  GridView.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Grid.h"

@interface GridView : NSView {
    
    Grid *_grid;
    
    CGSize _itemSize;
    
    NSColor *_lastColor;
}

@property (nonatomic, retain) Grid *grid;

// Internal

@property (nonatomic, retain) NSColor *lastColor;

@end
