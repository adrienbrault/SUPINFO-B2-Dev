//
//  GridView.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridView.h"

#define BORDER_SIZE_SCALE 15.0


@interface GridView (Private)

- (void)calculateItemSize;
- (void)drawInContext:(CGContextRef)context item:(GridItem *)item atPosition:(CGPoint)position;
- (void)drawInContext:(CGContextRef)context item:(GridItem *)item atPosition:(CGPoint)position extraSize:(CGSize)extraSize color:(NSColor *)color;
- (CGPoint)screenPositionForItem:(GridItem *)item atPosition:(ABPoint)position;
- (CGPoint)itemFramePosition:(GridItem *)item;
- (CGSize)borderSize;

- (void)setDrawingColor:(NSColor *)color;

@end


@implementation GridView

#pragma mark - Properties

@synthesize grid = _grid;
@synthesize lastColor = _lastColor;

- (void)setGrid:(Grid *)grid
{
    if (_grid != grid) {
        [_grid release];
        _grid = [grid retain];
        
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

- (CGPoint)itemFramePosition:(GridItem *)item
{
    return [self screenPositionForItem:item atPosition:item.cachePosition];
}

- (CGSize)borderSize
{
    return CGSizeMake(ceil(_itemSize.width / BORDER_SIZE_SCALE),
                      ceil(_itemSize.height / BORDER_SIZE_SCALE));
}


#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    [self calculateItemSize];
    
    self.lastColor = nil;
    
    NSGraphicsContext *graphicContext = [NSGraphicsContext currentContext];
    CGContextRef context = [graphicContext graphicsPort];
    
    // Dessin du contour noir des murs.
    for (GridItem *item in self.grid.items) {
        if ([item isKindOfClass:[GridItem class]] && item.type == GridItemWall) {
            CGSize borderSize = [self borderSize];
            
            [self drawInContext:context
                           item:item
                     atPosition:[self itemFramePosition:item]
                      extraSize:CGSizeMake(borderSize.width * 2.0, borderSize.height * 2.0)
                          color:[NSColor blackColor]];
        }
    }
    
    // Dessin de tous les items.
    for (GridItem *item in self.grid.items) {
        if ([item isKindOfClass:[GridItem class]]) {
            [self drawInContext:context
                           item:item
                     atPosition:[self screenPositionForItem:item atPosition:item.cachePosition]];
        }
    }
}

- (void)drawInContext:(CGContextRef)context item:(GridItem *)item atPosition:(CGPoint)position;
{
    [self drawInContext:context
                   item:item
             atPosition:position
              extraSize:CGSizeMake(0.0, 0.0)
                  color:nil];
}

- (void)drawInContext:(CGContextRef)context item:(GridItem *)item atPosition:(CGPoint)position extraSize:(CGSize)extraSize color:(NSColor *)color
{
    CGRect itemRect = CGRectMake(floor(position.x - extraSize.width / 2),
                                 floor(position.y - extraSize.height / 2),
                                 ceil(item.width * _itemSize.width + extraSize.width),
                                 ceil(item.height * _itemSize.height + extraSize.height));
    NSColor *colorToSet;
    
    switch (item.type) {
        case GridItemEarth:
            colorToSet = [NSColor greenColor];
            break;
            
        case GridItemCastel:
            [self setDrawingColor:[NSColor blackColor]];
            CGSize borderSize = [self borderSize];
            CGRect castelBackgroundRect = CGRectMake(itemRect.origin.x + borderSize.width * 2.0,
                                           itemRect.origin.y + borderSize.height * 2.0,
                                           itemRect.size.width - borderSize.width * 4.0,
                                           itemRect.size.height - borderSize.height * 4.0);
            CGContextFillRect(context, castelBackgroundRect);
            
            [self setDrawingColor:[NSColor purpleColor]];
            CGRect castelRect = CGRectMake(itemRect.origin.x + borderSize.width * 3.0,
                                           itemRect.origin.y + borderSize.height * 3.0,
                                           itemRect.size.width - borderSize.width * 6.0,
                                           itemRect.size.height - borderSize.height * 6.0);
            CGContextFillRect(context, castelRect);
            
            return;
            break;
            
        case GridItemWall:
            colorToSet = [NSColor grayColor];
            break;
            
        case GridItemWater:
            colorToSet = [NSColor blueColor];
            break;
        
        case GridItemAreaCaptured:
            colorToSet = [NSColor orangeColor];
            break;
            
        default:
            colorToSet = [NSColor blackColor];
            break;
    }
    
    if (color) {
        colorToSet = color;
    }
    
    [self setDrawingColor:colorToSet];
    
    CGContextFillRect(context, itemRect);
}

- (void)setDrawingColor:(NSColor *)color
{
    if (color != _lastColor) {
        [color set];
        self.lastColor = color;
    }
}


#pragma mark - NSView

- (BOOL)isFlipped
{
    return YES;
}

@end
