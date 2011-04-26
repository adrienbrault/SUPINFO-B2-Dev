//
//  Grid.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSMutableArray+Additions.h"
#import "GridItem.h"


@interface Grid : NSObject {
    
    int _width;
    int _height;
    
    NSMutableArray *_items;
}

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

- (id)initWithWidth:(int)width height:(int)height;

- (GridItem *)itemAtLine:(int)line column:(int)column;
- (void)setItem:(GridItem *)item atLine:(int)line column:(int)column;

@end
