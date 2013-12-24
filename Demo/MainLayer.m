//
//  MainLayer.m
//  Demo
//
//  Created by 许 晨阳 on 12-11-21.
//
//

#import "MainLayer.h"
#import "Player.h"
#import "IntroLayer.h"

@implementation MainLayer
{
    CCSprite *bg;
    float lx;
    float ly;
    
    float moveX;
    float moveY;
    
    CGSize screen;
    
    NSMutableArray *playerArray;
    NSMutableArray *leftArray;
    NSMutableArray *rightArray;
    CCSpriteBatchNode *batch;
}

enum{
    GAME_BG
};

+(id)scene
{
    CCScene *scene=[CCScene node];
    CCLayer *layer=[MainLayer node];
    [scene addChild:layer];
    return scene;
}
-(void)onEnter
{
    [super onEnter];
    screen=[[CCDirector sharedDirector] winSize];
    ax=0;
    ay=0;
    isTouchEnabled_=YES;
    playerArray=[[NSMutableArray alloc]init];
    leftArray=[[NSMutableArray alloc]init];
    rightArray=[[NSMutableArray alloc]init];
    [self initTouch];
    [self addBG];
    [self addPlayer];
    [self schedule:@selector(update:) interval:0.03];
    
}

/*添加背景*/
-(void)addBG
{
    //CCSpriteBatchNode *batch=[CCSpriteBatchNode batchNodeWithFile:@"bg.jpg"];
    //[self addChild:batch];
    bg=[CCSprite spriteWithFile:@"bg.png"];
    bg.anchorPoint=CGPointMake(0,0);
    [self addChild:bg];
    //[batch addChild:bg z:1 tag:GAME_BG];
}

/*添加角色*/
-(void)addPlayer
{
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    [cache addSpriteFramesWithFile:@"r1_img.plist"];
    batch=[[CCSpriteBatchNode batchNodeWithFile:@"r1_img.png"] retain];
    [self addChild:batch];
//    for(int j=0;j<7;j++)
//        for(int i=0;i<1;i++){
//            [self addSinglePlayer:batch];
//    }
    [self schedule:@selector(addSinglePlayer:) interval:0.1];
    //[self addSinglePlayer:batch];
}

-(void)addSinglePlayer:(ccTime) t
{
    int direction=arc4random()%2;
    int roleIndex=(direction==0?1:2);
    Player *player=[Player initAuto:direction roleIndex:roleIndex];
    int startX;
    if(direction == 0){
        startX=50;
        [leftArray addObject:player];
    }else{
        startX=1000;
        [rightArray addObject:player];
    }
    int sprite_y=arc4random()%180+100;
    [player setSpritePosition:ccp(startX, sprite_y)];
    player.sprite.zOrder=sprite_y*(-1);
    player.direction=direction;
    [self addChild:player];
    [batch addChild:player.sprite];
    [playerArray addObject:player];
}

-(void)updatePlayer
{
    [self calculate];
    [self updatePlayerState];
}

-(void)updatePlayerState
{
    for(int i=[playerArray count]-1;i>=0;i--)
    {
        Player *p=[playerArray objectAtIndex:i];
        [p move];
        if(p.sprite.position.x<=40)
        {
            //p.direction=0;
            p.blood=0;
        }else if(p.sprite.position.x >=1000){
            p.blood=0;
        }
        if([p dead]){
            //[batch removeChild:p.sprite cleanup:NO];
            [playerArray removeObjectAtIndex:i];
            [self removeChild:p cleanup:YES];
            [leftArray removeObject:p];
            [rightArray removeObject:p];
        }
    }
}

-(void)calculate
{
    for(int i=0;i<leftArray.count;i++){
        Player *left=[leftArray objectAtIndex:i];
        for(int j=0;j<rightArray.count;j++){
            Player *right=[rightArray objectAtIndex:j];
            if(abs(left.sprite.position.x-right.sprite.position.x) <= 100 && abs(left.sprite.position.y-right.sprite.position.y) <= 30){
                [right addToAttackArray:left];
                [left addToAttackArray:right];
            }else{
                [right removeAttackArray:left];
                [left removeAttackArray:right];
            }
        }
    }
}


-(void)initTouch
{
    [[CCTouchDispatcher sharedDispatcher]addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touches withEvent:(UIEvent *)event
{
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[IntroLayer scene] withColor:ccWHITE]];
    CGPoint p=[touches locationInView:touches.view];
    p=[[CCDirector sharedDirector] convertToGL:p];
    lx=p.x;
    ly=p.y;
    //[self addSinglePlayer:1];
    return YES;
}
-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint p=[touch locationInView:touch.view];
    p=[[CCDirector sharedDirector] convertToGL:p];
    ax=moveX=p.x-lx;
    ay=moveY=p.y-ly;
    lx=p.x;
    ly=p.y;
    
}


float ax;
float ay;
float speed=0.3;
-(void)update:(ccTime) delta
{
    [self updatePlayer];
//    if(self.position.x+moveX>0 && moveX>0){
//        moveX=-(self.position.x+moveX);
//    }
//    if(self.position.x+moveX<screen.width-bg.contentSize.width && moveX<0){
//        moveX=(screen.width-bg.contentSize.width)-(self.position.x+moveX);
//    }
    if(self.position.x+moveX>=0 || self.position.x +moveX <=screen.width-bg.contentSize.width)
    {
        moveX=0;
    }else{
        if(moveX>0){
            moveX-=1;
            if(moveX<0){
                moveX=0;
            }
        }else if(moveX<0){
            moveX+=1;
            if(moveX>0){
                moveX=0;
            }
        }
    }
    if(self.position.y+moveY>=0 || self.position.y +moveY <=screen.height-bg.contentSize.height)
    {
        moveY=0;
    }else{
        if(moveY>0){
            moveY-=1;
            if(moveY<0){
                moveY=0;
            }
        }else if(moveY<0){
            moveY+=1;
            if(moveY>0){
                moveY=0;
            }
        }
    }
    self.position=ccp(self.position.x+moveX, self.position.y+moveY);
}

-(void)onExit
{
    [super onExit];
    [self removeChild:batch cleanup:YES];
    [self removeChild:bg cleanup:YES];
    [batch removeAllChildrenWithCleanup:YES];
    [batch release];
    
        
    for(int i=[playerArray count]-1;i>=0;i--)
    {
        Player *p=[playerArray objectAtIndex:i];
        [p cleanAttackArray];
        [self removeChild:p cleanup:YES];
    }    
    [playerArray release];
    [leftArray release];
    [rightArray release];
    
    
}

-(void)dealloc
{
    [super dealloc];
    CCSpriteFrameCache *cache= [CCSpriteFrameCache sharedSpriteFrameCache];
    [cache removeSpriteFramesFromFile:@"r1_img.plist"];
    cache=nil;
    
    CCTextureCache *tc=[CCTextureCache sharedTextureCache];
    [tc removeAllTextures];
    
    
}
@end
