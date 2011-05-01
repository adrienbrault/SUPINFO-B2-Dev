//
//  GridView.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Grid.h"

@class GridView;
@protocol GridViewDelegate <NSObject>

- (void)gridViewDidDraw:(GridView *)gridView;

@end

@interface GridView : NSView {
    
    Grid *_grid;
    
    CGSize _itemSize;
    
    id <GridViewDelegate> _delegate;
}

@property (nonatomic, retain) Grid *grid;
@property (nonatomic, assign) id <GridViewDelegate> delegate;

@end
