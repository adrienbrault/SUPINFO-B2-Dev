//
//  GridItem.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    GridItemEarth = 0,
    GridItemWater,
    GridItemWall,
    GridItemCastel,
    GridItemAreaCaptured
} GridItemType;


@interface GridItem : NSObject {
    
    GridItemType _type;
}

@property (nonatomic, assign) GridItemType type;

@end
