//
//  GridView.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Grid.h"

#define BORDER_SIZE_SCALE 15.0

@interface GridView : NSView {
    
    Grid *_grid;
    
    CGSize _itemSize;
}

@property (nonatomic, retain) Grid *grid;


// Internal - For inheritance

- (void)calculateItemSize;
- (CGPoint)screenPositionForItem:(GridItem *)item atPosition:(ABPoint)position;
- (CGPoint)itemFramePosition:(GridItem *)item;
- (CGSize)borderSize;

@end
