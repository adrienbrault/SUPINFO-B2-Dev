//
//  GridItemType.m
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import "GridItemType.h"

int
GetGridItemTypeWidth(GridItemType type)
{
    return (type == GridItemCastel) ? 2 : 1;
}

int
GetGridItemTypeHeight(GridItemType type)
{
    return (type == GridItemCastel) ? 2 : 1;
}

NSString *
GetGridItemTypeString(GridItemType type)
{
    return GridItemType_toString[type];
}