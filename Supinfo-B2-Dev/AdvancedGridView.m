//
//  AdvancedGridView.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 03/05/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "AdvancedGridView.h"


@interface AdvancedGridView (Private)

- (void)drawInContext:(CGContextRef)context item:(GridItem *)item atPosition:(CGPoint)position;
- (void)drawInContext:(CGContextRef)context item:(GridItem *)item atPosition:(CGPoint)position extraSize:(CGSize)extraSize color:(NSColor *)color;

- (void)setDrawingColor:(NSColor *)color;

@end



@implementation AdvancedGridView

#pragma mark - Properties

@synthesize grid = _advancedGrid;
@synthesize lastColor = _lastColor;

- (void)setGrid:(AdvancedGrid *)grid
{
    if (_advancedGrid != grid) {
        [_advancedGrid release];
        _advancedGrid = [grid retain];
        
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
    [_lastColor release];
    [_advancedGrid release];
    [super dealloc];
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
        case GridItemCastel:
        {
            [self setDrawingColor:[NSColor blackColor]];
            CGSize borderSize = [self borderSize];
            CGRect castelBackgroundRect = CGRectMake(itemRect.origin.x + borderSize.width * 2.0,
                                                     itemRect.origin.y + borderSize.height * 2.0,
                                                     itemRect.size.width - borderSize.width * 4.0,
                                                     itemRect.size.height - borderSize.height * 4.0);
            CGContextFillRect(context, castelBackgroundRect);
            
            [self setDrawingColor:[NSColor whiteColor]];
            CGRect castelRect = CGRectMake(itemRect.origin.x + borderSize.width * 3.0,
                                           itemRect.origin.y + borderSize.height * 3.0,
                                           itemRect.size.width - borderSize.width * 6.0,
                                           itemRect.size.height - borderSize.height * 6.0);
            CGContextFillRect(context, castelRect);
        } return;
            
        case GridItemWall:
        {
            colorToSet = [NSColor colorWithDeviceRed:187.0 / 255.0 green:187.0 / 255.0 blue:187.0 / 255.0 alpha:1.0];
        } break;
            
        case GridItemGun:
        {
            // Reduce item size.
            itemRect = CGRectMake(itemRect.origin.x + 1,
                                  itemRect.origin.y + 1,
                                  itemRect.size.width - 1,
                                  itemRect.size.height - 1);
            [self setDrawingColor:[NSColor colorWithDeviceRed:230.0 / 255.0 green:163.0 / 255.0 blue:89.0 / 255.0 alpha:1.0]];
            CGContextFillEllipseInRect(context, itemRect);
        } return;
            
        default:
        {
            colorToSet = [NSColor blackColor];
        } break;
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

@end
