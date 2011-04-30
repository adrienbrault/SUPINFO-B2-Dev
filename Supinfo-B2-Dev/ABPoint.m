//
//  ABPoint.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 30/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "ABPoint.h"

ABPoint
ABPointMake(int x, int y)
{
    ABPoint point;
    point.x = x;
    point.y = y;
    return point;
}

NSValue *
ABPointToValue(ABPoint point)
{
    return [NSValue valueWithBytes:&point objCType:@encode(ABPoint)];
}

ABPoint
ABPointFromValue(NSValue *value)
{
    ABPoint point;
    [value getValue:&point];
    return point;
}