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
    
    NSInteger _width;
    NSInteger _height;
    
    NSMutableArray *_items;
}

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSSet *uniqueItems;

- (id)initWithWidth:(NSInteger)width height:(NSInteger)height;

- (GridItem *)itemAtPosition:(ABPoint)position;
- (void)setItem:(GridItem *)item atPosition:(ABPoint)position;
- (void)removeItem:(GridItem *)item;

- (BOOL)position:(ABPoint)position availableForItem:(GridItem *)item;
- (BOOL)position:(ABPoint)position existsForItem:(GridItem *)item;

- (ABPoint)firstItemPosition:(GridItem *)item;
- (NSArray *)positionsForItem:(GridItem *)item atPosition:(ABPoint)position;

- (GridItem *)itemAtIndex:(NSInteger)index;
- (void)setItem:(GridItem *)item atIndex:(NSInteger)index;

- (ABPoint)positionForIndex:(NSInteger)index;
- (NSInteger)indexForPosition:(ABPoint)position;


- (void)setTerritoryIndexesStatus:(NSArray *)indexesStatus;

@end
