//
//  GridItemType.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

typedef enum {
    GridItemEarth = 0,
    GridItemWater,
    GridItemWall,
    GridItemCastel,
    GridItemAreaCaptured
} GridItemType;

int GetGridItemTypeWidth(GridItemType type);
int GetGridItemTypeHeight(GridItemType type);