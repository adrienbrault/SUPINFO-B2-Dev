//
//  Grid.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSMutableArray+Additions.h"
#import "ABPoint.h"
#import "GridItem.h"


@interface Grid : NSObject {
    
    int _width;
    int _height;
    
    NSMutableArray *_items;
}

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

- (id)initWithWidth:(int)width height:(int)height;

- (GridItem *)itemAtPosition:(ABPoint)position;
- (void)setItem:(GridItem *)item atPosition:(ABPoint)position;

- (BOOL)position:(ABPoint)position availableForItemType:(GridItemType)itemType;
- (BOOL)position:(ABPoint)position existsForItemType:(GridItemType)itemType;

@end
