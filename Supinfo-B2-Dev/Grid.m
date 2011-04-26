//
//  Grid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Grid.h"


@interface Grid (Private)

- (int)indexForLine:(int)line column:(int)column;

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


#pragma mark -

- (GridItem *)itemAtLine:(int)line column:(int)column
{
    id item = [_items objectAtIndex:[self indexForLine:line column:column]];
    
    return (item != [NSNull null]) ? (GridItem *)item : nil;
}

- (void)setItem:(GridItem *)item atLine:(int)line column:(int)column
{
    if (!item) [NSException raise:@"GridItemError" format:@"You cannot set a nil object."];
    
    [_items replaceObjectAtIndex:[self indexForLine:line column:column]
                      withObject:item];
}


#pragma mark - Private

- (int)indexForLine:(int)line column:(int)column
{
    return line * _width + column;
}

@end
