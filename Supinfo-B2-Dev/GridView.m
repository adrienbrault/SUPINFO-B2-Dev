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
                       position.y * _itemSize.height);
}


#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *graphicContext = [NSGraphicsContext currentContext];
    CGContextRef context = [graphicContext graphicsPort];
    
    // Set the origin of the coordinate system in the upper left corner instead of the lower left corner.
    CGContextConcatCTM(context,
                       CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, self.frame.size.height));
    
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
    CGRect itemRect = CGRectMake(floor(position.x),
                                 floor(position.y),
                                 ceil(item.width * _itemSize.width),
                                 ceil(item.height * _itemSize.height));
    
    switch (item.type) {
        case GridItemEarth:
            [[NSColor greenColor] set];
            break;
        
        case GridItemCastel:
            [[NSColor purpleColor] set];
            break;
            
        case GridItemWall:
            [[NSColor grayColor] set];
            break;
        
        case GridItemWater:
            [[NSColor blueColor] set];
            break;
            
        default:
            [[NSColor blackColor] set];
            break;
    }
    
    CGContextFillRect(context, itemRect);
}

@end
