//
//  GridView.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridView.h"


@interface GridView (Private)

- (void)calculateItemSize;
- (void)drawInContext:(CGContextRef)context item:(GridItem *)item atPosition:(CGPoint)position;
- (CGPoint)screenPositionForItem:(GridItem *)item atPosition:(ABPoint)position;

@end


@implementation GridView

#pragma mark - Properties

@synthesize grid = _grid;

- (void)setGrid:(Grid *)grid
{
    if (_grid != grid) {
        [_grid release];
        _grid = [grid retain];
        
        [self calculateItemSize];
        
        [self setNeedsDisplay:YES];
    }
}


#pragma mark - Object lifecycle

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code here.
    }
    return self;
}

- (void)dealloc
{
    [_grid release];
    [super dealloc];
}


#pragma mark -

- (void)calculateItemSize
{
    _itemSize = CGSizeMake(self.frame.size.width / self.grid.width,
                           self.frame.size.height / self.grid.height);
}

- (CGPoint)screenPositionForItem:(GridItem *)item atPosition:(ABPoint)position
{
    return CGPointMake(position.x * _itemSize.width,
                       position.y * _itemSize.height + self.frame.size.height - _itemSize.height * item.height);
}


#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *graphicContext = [NSGraphicsContext currentContext];
    CGContextRef context = [graphicContext graphicsPort];
    
    NSSet *items = [self.grid.uniqueItems retain];
    for (GridItem *item in items) {
        ABPoint itemPosition = [self.grid firstItemPosition:item];
        CGPoint itemScreenPosition = [self screenPositionForItem:item atPosition:itemPosition];
        
        [self drawInContext:context
                       item:item
                 atPosition:itemScreenPosition];
    }
    [items release];
}

- (void)drawInContext:(CGContextRef)context item:(GridItem *)item atPosition:(CGPoint)position;
{
    CGRect itemRect = CGRectMake(position.x,
                                 position.y,
                                 item.width * _itemSize.width,
                                 item.height * _itemSize.height);
    
    switch (item.type) {
        case GridItemEarth:
            [[NSColor greenColor] set];
            break;
        
        case GridItemCastel:
            [[NSColor grayColor] set];
            break;
            
        default:
            break;
    }
    
    CGContextFillRect(context, itemRect);
}

@end
