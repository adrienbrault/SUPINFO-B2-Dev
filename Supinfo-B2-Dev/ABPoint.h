//
//  ABPoint.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

typedef struct {
    int x;
    int y;
} ABPoint;

ABPoint
ABPointMake(int x, int y);

NSValue *
ABPointToValue(ABPoint point);

ABPoint
ABPointFromValue(NSValue *value);