//
//  AdvancedGridView.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 03/05/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AdvancedGrid.h"
#import "GridView.h"

@interface AdvancedGridView : GridView {
 
    AdvancedGrid *_advancedGrid;
    
    NSColor *_lastColor;
}

@property (nonatomic, retain) AdvancedGrid *grid;

// Internal

@property (nonatomic, retain) NSColor *lastColor;

@end
