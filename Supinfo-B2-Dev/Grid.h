//
//  Grid.h
//  Supinfo-B2-Dev
//
//  Created by Adrien Brault on 26/04/11.
//  Copyright 2011 Adrien Brault. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Grid : NSObject {
    
    int _lines;
    int _columns;
}

@property (nonatomic, assign) int lines;
@property (nonatomic, assign) int columns;

@end
