//
//  BoatView.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/05/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "BoatView.h"


static NSImage *_boatImage = nil;


@implementation BoatView

#pragma mark - Properties

+ (NSImage *)boatImage
{
    if (!_boatImage) {
        _boatImage = [[NSImage imageNamed:@"boat.png"] retain];
    }
    return _boatImage;
}


#pragma mark - Object lifecyle

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        self.image = [BoatView boatImage];
    }
    return self;
}

@end
