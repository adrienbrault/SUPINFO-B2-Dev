//
//  Grid.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "Grid.h"


@implementation Grid

#pragma mark - Properties

@synthesize lines = _lines;
@synthesize columns = _columns;


#pragma mark - Object lifecyle

- (id)init
{
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)dealloc
{
    
}

@end
