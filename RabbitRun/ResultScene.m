//
//  ResultScene.m
//  RabbitRun
//
//  Created by Michael Shen on 15/3/27.
//  Copyright (c) 2015年 Dextrys. All rights reserved.
//

#import "ResultScene.h"
#import "GameScene.h"

@implementation ResultScene

-(instancetype)initWithSize:(CGSize)size won:(BOOL)won
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        //1 Add a result label to the middle of screen
        SKLabelNode *resultLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        resultLabel.text = won ? @"You win!" : @"You lose";
        resultLabel.fontSize = 30;
        resultLabel.fontColor = [SKColor blackColor];
        resultLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame));
        [self addChild:resultLabel];
        
        //2 Add a retry label below the result label
        SKLabelNode *retryLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryLabel.text = @"Try again";
        retryLabel.fontSize = 20;
        retryLabel.fontColor = [SKColor blueColor];
        retryLabel.position = CGPointMake(resultLabel.position.x, resultLabel.position.y * 0.8);
        //3 Give a name for this node, it will help up to find the node later.
        retryLabel.name = @"retryLabel";
        [self addChild:retryLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:touchLocation];
        
        if ([node.name isEqualToString:@"retryLabel"]) {
            [self changeToGameScene];
        }
    }
}

-(void) changeToGameScene
{
    GameScene *ms = [GameScene sceneWithSize:self.size];
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:0.1];
    [self.scene.view presentScene:ms transition:reveal];
}

@end
