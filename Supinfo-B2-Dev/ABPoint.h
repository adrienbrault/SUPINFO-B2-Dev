//
//  ABPoint.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

typedef struct {
    NSInteger x;
    NSInteger y;
} ABPoint;

ABPoint ABPointMake(NSInteger x, NSInteger y);

NSValue * ABPointToValue(ABPoint point);
ABPoint ABPointFromValue(NSValue *value);