//
//  FireNode.m
//  RabbitRun
//
//  Created by Michael Shen on 15/3/19.
//  Copyright (c) 2015年 Dextrys. All rights reserved.
//

#import "FireNode.h"

@implementation FireNode
-(id)initWithTexture:(SKTexture *)texture{
    if (self = [super initWithTexture:texture]) {
        self.fireArray = [NSArray arrayWithObjects:@"fire_1",@"fire_2",@"fire_3",@"fire_4", nil];
        self.fireAnimationInt = self.fireArray.count;
    }
    return self;
}
@end
