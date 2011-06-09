//
//  GridView.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridView.h"


@interface GridView (Private)

- (void)drawInContext:(CGContextRef)context itemType:(GridItemType)type fromPosition:(ABPoint)fromPosition toPosition:(ABPoint)toPosition;
- (void)drawInContext:(CGContextRef)context itemType:(GridItemType)type inRect:(CGRect)rect;

- (CGRect)rectFromPosition:(ABPoint)fromPosition toPosition:(ABPoint)toPosition;

@end


@implementation GridView

#pragma mark - Properties

@synthesize grid = _grid;

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
    
    NSGraphicsContext *graphicContext = [NSGraphicsContext currentContext];
    CGContextRef context = [graphicContext graphicsPort];
    
    GridItemType lastType = -1;
    ABPoint lastTypeFirstPosition = ABPointMake(0, 0);
    
    // Dessin de tous les items.
    for (NSInteger i=0; i<[self.grid.items count]; i++) {
        GridItem *item = [self.grid.items objectAtIndex:i];
        
        if ([item isKindOfClass:[GridItem class]]) {
            if (item.type != lastType) {
                // Draw last type
                if (lastType != -1) {
                    NSInteger toIndex = i - 1;
                    ABPoint toPosition = [self.grid positionForIndex:toIndex];
                    
                    [self drawInContext:context
                               itemType:lastType
                           fromPosition:lastTypeFirstPosition
                             toPosition:toPosition];
                }
                
                // Set var for the next type
                lastType = item.type;
                lastTypeFirstPosition = item.cachePosition;
            }
        } else {
            if (lastType != -1) {
                NSInteger toIndex = i - 1;
                ABPoint toPosition = [self.grid positionForIndex:toIndex];
                
                [self drawInContext:context
                           itemType:lastType
                       fromPosition:lastTypeFirstPosition
                         toPosition:toPosition];
            }
            lastType = -1;
        }
    }
    
    if (lastType != -1) {
        [self drawInContext:context
                   itemType:lastType
               fromPosition:lastTypeFirstPosition
                 toPosition:ABPointMake(self.grid.width - 1, self.grid.height - 1)];
    }
    
}

- (void)drawInContext:(CGContextRef)context itemType:(GridItemType)type fromPosition:(ABPoint)fromPosition toPosition:(ABPoint)toPosition
{
    NSInteger lines = toPosition.y - fromPosition.y + 1;
    
    // First line
    ABPoint firstLineLastPosition = ABPointMake((lines > 1) ? self.grid.width - 1 : toPosition.x,
                                                fromPosition.y);
    [self drawInContext:context
               itemType:type
                 inRect:[self rectFromPosition:fromPosition toPosition:firstLineLastPosition]];
    
    // Last line
    if (lines >= 2) {
        ABPoint lastLineFirstPosition = ABPointMake(0,
                                                    toPosition.y);
        [self drawInContext:context
                   itemType:type
                     inRect:[self rectFromPosition:lastLineFirstPosition toPosition:toPosition]];
    }
    
    // Lines between first and last (should be a rect).
    if (lines >= 3) {
        ABPoint middleLinesFirstPosition = ABPointMake(0, fromPosition.y + 1);
        ABPoint middleLinesLastPosition = ABPointMake(self.grid.width - 1, toPosition.y - 1);
        
        [self drawInContext:context
                   itemType:type
                     inRect:[self rectFromPosition:middleLinesFirstPosition toPosition:middleLinesLastPosition]];
    }
}

- (void)drawInContext:(CGContextRef)context itemType:(GridItemType)type inRect:(CGRect)rect
{
    NSColor *color;
    
    switch (type) {
        case GridItemEarth:
            color = [NSColor colorWithDeviceRed:0.0
                                          green:1.0
                                           blue:(128.0 / 255.0)
                                          alpha:1.0];
            break;
        
        case GridItemWater:
            color = [NSColor colorWithDeviceRed:0.0
                                          green:0.0
                                           blue:1.0
                                          alpha:1.0];
            break;
        
        case GridItemAreaCaptured:
            color = [NSColor colorWithDeviceRed:(51.0 / 255.0)
                                          green:(51.0 / 255.0)
                                           blue:(51.0 / 255.0)
                                          alpha:1.0];
            break;
            
        default:
            color = [NSColor brownColor];
            break;
    }
    
    [color set];
    
    CGContextFillRect(context, rect);
}

- (CGRect)rectFromPosition:(ABPoint)fromPosition toPosition:(ABPoint)toPosition
{
    return CGRectMake(floor(fromPosition.x * _itemSize.width),
                      floor(fromPosition.y * _itemSize.height),
                      ceil((toPosition.x - fromPosition.x + 1) * _itemSize.width),
                      ceil((toPosition.y - fromPosition.y + 1) * _itemSize.height));
}


#pragma mark - NSView

- (BOOL)isFlipped
{
    return YES;
}

@end
