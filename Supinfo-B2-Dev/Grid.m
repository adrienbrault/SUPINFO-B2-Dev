//
//  Grid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Grid.h"


@interface Grid (Private)

- (int)indexForPosition:(ABPoint)position;
- (NSArray *)positionsForItem:(GridItem *)item atPosition:(ABPoint)position;

@end



@implementation Grid

#pragma mark - Properties

@synthesize height = _height;
@synthesize width = _width;


#pragma mark - Object lifecyle

- (id)init
{
    return [self initWithWidth:1 height:1];
}

- (id)initWithWidth:(int)width height:(int)height;
{
    if ((self = [super init])) {
        int capacity = width * height;
        
        _items = [[NSMutableArray alloc] initWithNullCapacity:capacity];
    }
    return self;
}

- (void)dealloc
{
    [_items release];
    [super dealloc];
}


#pragma mark - Grid

- (GridItem *)itemAtPosition:(ABPoint)position;
{
    id item = [_items objectAtIndex:[self indexForPosition:position]];
    
    return (item != [NSNull null]) ? (GridItem *)item : nil;
}

- (void)setItem:(GridItem *)item atPosition:(ABPoint)position
{
    if (!item)
        [NSException raise:@"GridItemError" format:@"You cannot set a nil object."];
    
    if (![self position:position existsForItem:item])
        [NSException raise:@"GridItemError" format:@"You cannot set this at this position."];
    
    [_items replaceObjectAtIndex:[self indexForPosition:position]
                      withObject:item];
}

- (BOOL)position:(ABPoint)position availableForItem:(GridItem *)item
{
    NSArray *itemPositions = [self positionsForItem:item atPosition:position];
    for (NSValue *value in itemPositions) {
        ABPoint position = ABPointFromValue(value);
        
        if (!([self position:position existsForItem:item] && ![self itemAtPosition:position]))
            return NO;
    }
    return YES;
}

- (BOOL)position:(ABPoint)position existsForItem:(GridItem *)item
{
    int itemMaxColumn = position.x + item.width;
    int itemMaxLine = position.y + item.height;
    
    return itemMaxColumn <= _width && itemMaxLine <= _height;
}


#pragma mark - Private

- (int)indexForPosition:(ABPoint)position
{
    return position.y * _width + position.x;
}

- (NSArray *)positionsForItem:(GridItem *)item atPosition:(ABPoint)position
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<(item.width * item.height); i++) {
        ABPoint position = ABPointMake(i % item.width + position.x,
                                       i % item.height + position.y);
        
        // The best way to store a struct into a NSArray is to convert it to a NSValue.
        NSValue *value = ABPointToValue(position);
        [array addObject:value];
    }
    return array;
}

@end
