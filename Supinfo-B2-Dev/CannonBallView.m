//
//  CannonBallView.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 08/06/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "CannonBallView.h"

@implementation CannonBallView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrameSize:NSSizeFromCGSize(CGSizeMake(5.0, 5.0))];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *graphicContext = [NSGraphicsContext currentContext];
    CGContextRef context = [graphicContext graphicsPort];
    
    [[NSColor blackColor] set];
    
    CGRect itemRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGContextFillEllipseInRect(context, itemRect);
}

@end
