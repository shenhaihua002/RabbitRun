//
//  GameScene.m
//  RabbitRun
//
//  Created by Michael Shen on 15/3/18.
//  Copyright (c) 2015年 Dextrys. All rights reserved.
//

#import "GameScene.h"
#import <CoreMotion/CoreMotion.h>
#import "FireNode.h"
#import "ResultScene.h"

@interface GameScene()
@property (nonatomic) double lastCurrentTime;
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) CFTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int playerAnimationInt;
@property (nonatomic) int fileAnimationInt;
@property (nonatomic) CFTimeInterval lastSpawnTimeInterval;
@property (nonatomic,strong) CMMotionManager *motionManager;
@property (nonatomic,strong) NSMutableArray *fireArray;
@property (nonatomic) BOOL isWin;
@property (nonatomic,strong) SKAction *spinForever;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size{
     if (self = [super initWithSize:size]) {
         self.fireArray = [NSMutableArray array];
         SKTexture* explodeTexture2 = [SKTexture textureWithImageNamed:@"game_bg"];
         explodeTexture2.filteringMode = SKTextureFilteringNearest;
         SKSpriteNode *backNode = [SKSpriteNode spriteNodeWithTexture:explodeTexture2 size:CGSizeMake(self.frame.size.width, self.frame.size.height)];
         backNode.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
         [self addChild:backNode];
         
         SKTexture* explodeTexture1 = [SKTexture textureWithImageNamed:@"rabbit_ani_chiki_1"];
         explodeTexture1.filteringMode = SKTextureFilteringNearest;
         self.player = [SKSpriteNode spriteNodeWithTexture:explodeTexture1];
         self.player.position = CGPointMake(self.frame.size.width/2, self.player.size.height/2+8);
         [self addChild:self.player];
         
         NSMutableArray *texturesArray = [NSMutableArray array];
         for (int i = 0; i < 6; i++) {
             SKTexture* explodeTexture1 = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"rabbit_ani_chiki_%d",i+1]];
             explodeTexture1.filteringMode = SKTextureFilteringNearest;
             [texturesArray addObject:explodeTexture1];
         }
         SKAction *actionImage = [SKAction animateWithTextures:texturesArray timePerFrame:0.1];
         self.spinForever = [SKAction repeatActionForever:actionImage];
         [self.player runAction:_spinForever withKey:@"running"];
         
         _isWin = NO;
         //     NSLog(@"Size: %@", NSStringFromCGSize(size));
         self.motionManager = [[CMMotionManager alloc]init];
         
         [self.motionManager startAccelerometerUpdates];
         
         SKAction *actionAddMonster = [SKAction runBlock:^{
             [self addMonster];
         }];
         SKAction *actionWaitNextMonster = [SKAction waitForDuration:0.5];
         [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[actionAddMonster,actionWaitNextMonster]]]];
     }
    return self;
}

#pragma mark-
- (void) addMonster {
    
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"fire_1"];
    
    //1 Determine where to spawn the monster along the Y axis
    CGSize winSize = self.size;
    int minX = monster.size.width / 2;
    int maxX = winSize.width - monster.size.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    //2 Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(actualX, winSize.height+monster.size.height/2);
    [self addChild:monster];
    [self.fireArray addObject:monster];
    
    //3 Determine speed of the monster
    int minDuration = 1.0;
    int maxDuration = 3.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //4 Create the actions. Move monster sprite across the screen and remove it from scene after finished.
    SKAction *actionMove = [SKAction moveTo:CGPointMake(actualX, monster.size.height/2+5)
                                   duration:actualDuration];
    SKAction *actionMoveDone = [SKAction runBlock:^{
        [monster removeFromParent];
        [self.fireArray removeObject:monster];
    }];
    NSMutableArray *texturesArray = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        SKTexture* explodeTexture1 = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"fire_%d",i+1]];
        explodeTexture1.filteringMode = SKTextureFilteringNearest;
        [texturesArray addObject:explodeTexture1];
    }
    SKAction *actionImage = [SKAction animateWithTextures:texturesArray timePerFrame:0.1];
    SKAction *spinForever = [SKAction repeatActionForever:actionImage];
    [monster runAction:spinForever];
    [monster runAction:[SKAction sequence:@[actionMove,actionMoveDone]]];

}

-(void) changeToResultSceneWithWon:(BOOL)won
{
//    [self.bgmPlayer stop];
//    self.bgmPlayer = nil;
    _isWin = YES;
    ResultScene *rs = [[ResultScene alloc] initWithSize:self.size won:won];
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionUp duration:0.1];
    [self.scene.view presentScene:rs transition:reveal];
}




-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.xScale = 0.5;
//        sprite.yScale = 0.5;
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
}

#pragma mark- 每0.1s切换兔子
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 0.1) {
        self.lastSpawnTimeInterval = 0;
        _playerAnimationInt++;
        if (_playerAnimationInt>6) {
            _playerAnimationInt = 1;
        }
        self.player.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"rabbit_ani_chiki_%d", _playerAnimationInt]];
    }
}

#pragma mark- 每0.1s切换火焰
- (void)updateWithTimeFireSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 0.1) {
        self.lastSpawnTimeInterval = 0;
        _playerAnimationInt++;
        if (_playerAnimationInt>4) {
            _playerAnimationInt = 1;
        }
        self.player.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"fire_%d", _playerAnimationInt]];
    }
}

#pragma mark- 刷新计时器
-(void)processUserMotionForUpdate:(NSTimeInterval)currentTime {
    CMAccelerometerData* data = self.motionManager.accelerometerData;
    NSString *stringX = [NSString stringWithFormat:@"accelerationX : %f", data.acceleration.x];
    NSString *stringY = [NSString stringWithFormat:@"accelerationY : %f", data.acceleration.y];
//    NSString *stringZ = [NSString stringWithFormat:@"accelerationZ : %f", data.acceleration.z];
//    NSLog(@"-------%@-------",stringY);
    
    if (ABS(data.acceleration.y)<0.02) {
        return;
    }
    if (self.player.position.x<=self.player.size.width/2) {
        self.player.position = CGPointMake(self.player.size.width/2, self.player.position.y);
    }
    
    if (self.player.position.x>=self.frame.size.width-self.player.size.width/2) {
        self.player.position = CGPointMake(self.frame.size.width-self.player.size.width/2, self.player.position.y);
    }
    
    if (data.acceleration.y>0) {
        double playX = self.player.position.x + data.acceleration.y*20;
        self.player.position = CGPointMake(playX, self.player.position.y);
    }
    if (data.acceleration.y<0) {
        double playX = self.player.position.x + data.acceleration.y*20;
        self.player.position = CGPointMake(playX, self.player.position.y);
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
//    NSLog(@"-----%d",_playerAnimationInt);
//
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 0.1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
//    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    if (!_isWin) {
        [self processUserMotionForUpdate:currentTime];

    }
//    [self updateWithTimeFireSinceLastUpdate:timeSinceLast];
    for (SKSpriteNode *monster in self.fireArray) {
        
        if (CGRectIntersectsRect(self.player.frame, monster.frame)) {
            if (!_isWin) {
                _isWin = YES;
                [self.motionManager stopAccelerometerUpdates];
                NSLog(@"你已经输了");
                [self.player removeActionForKey:@"running"];
                NSMutableArray *texturesArray = [NSMutableArray array];
                for (int i = 0; i < 5; i++) {
                    SKTexture* explodeTexture1 = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"rabbit_fire_%d",i+1]];
                    explodeTexture1.filteringMode = SKTextureFilteringNearest;
                    [texturesArray addObject:explodeTexture1];
                }
                SKAction *actionImage = [SKAction animateWithTextures:texturesArray timePerFrame:0.1];
                SKAction *actionPlay = [SKAction repeatAction:actionImage count:1];
                [self.player runAction:actionPlay completion:^{
                    [self changeToResultSceneWithWon:NO];
                }];

            }
           
        }
    }
}

@end
