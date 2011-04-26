//
//  GridItem.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GridItemType.h"


@interface GridItem : NSObject {
    
    GridItemType _type;
}

@property (nonatomic, readonly) GridItemType type;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

- (id)initWithType:(GridItemType)type;

@end
