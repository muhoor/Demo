//
//  Player.m
//  Demo
//
//  Created by 许 晨阳 on 12-11-22.
//
//

#import "Player.h"
#import "cocos2d.h"

@implementation Player
{
    int playerSpeed_;
    CCSprite *sprite_;
    int direction_;
    int status_;
    int blood_;
    int damage;
    
    int roleIndex_;
    
    CCAction *run;
    CCAction *attack;
    CCAction *die;
    
    BOOL isDead;
    
    NSMutableArray *attackedArray_;
}
@synthesize sprite=sprite_;
@synthesize direction=direction_;   //0-朝右 1-朝左
@synthesize status=status_;         //1-跑 2-攻击 3-死
@synthesize blood=blood_;


+(id)initAuto:(int) direction roleIndex:(int) role
{
    return [[[self alloc]init:direction roleIndex:role]autorelease];
}

-(id)init:(int)d roleIndex:(int)role
{
    if((self =[super init])){
        NSLog(@"成功生产");
        blood_=800+arc4random()%5;
        damage=200+arc4random()%20;
        roleIndex_=role;
        attackedArray_=[[NSMutableArray alloc]init];
        direction_=d;
        playerSpeed_=arc4random()%5+5;
        status_=1;
        NSString *roleName=[NSString stringWithFormat:@"r%d_run_1.png",roleIndex_];
        sprite_=[[CCSprite spriteWithSpriteFrameName:roleName] retain];
        [self setSpriteDirection];
        [self initActions];
        [self playerRun];
        [self scheduleUpdate];
    }
    return self;
}

-(void)initActions
{
    run=[[self addSingleAnimation:@"run" type:1] retain];
    attack=[[self addSingleAnimation:@"attack" type:2] retain];
    die=[[self addSingleAnimation:@"die" type:3] retain];
}

-(CCAction *)addSingleAnimation:(NSString *) actionName type:(int) t
{
    int imgNum=t==3?(roleIndex_==1?17:16):15;//////坑爹的美术，MLBG的，一个角色是17张，另一个角色又是16张。
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:imgNum];
    for(int i=0;i<imgNum;i++){
        NSString *string=[NSString stringWithFormat:@"r%d_%@_%i.png",roleIndex_,actionName,i];
        CCSpriteFrame *frame=[cache spriteFrameByName:string];
        [array addObject:frame];
    }
    CCAnimation *animation=[CCAnimation animationWithFrames:array delay:0.06f];
    CCAnimate *animate=[CCAnimate actionWithAnimation:animation];
    CCAction *action;
    if(t==3){
        action=[CCRepeat actionWithAction:animate times:1];
    }else{
        action=[CCRepeatForever actionWithAction:animate];
    }
    return action;
}


-(void)setSpritePosition:(CGPoint) point
{
    sprite_.position=point;
}

-(void)playerRun
{
    status_=1;
    [self setSpriteDirection];
    [sprite_ stopAllActions];
    [sprite_ runAction:run];
    
}

-(void)move
{
    if(status_ !=1)
        return;
    [self setSpriteDirection];
    if(direction_ == 0)
    {
        sprite_.position=ccp(sprite_.position.x+playerSpeed_, sprite_.position.y);
    }else{
        sprite_.position=ccp(sprite_.position.x-playerSpeed_, sprite_.position.y);
    }
}

-(void)playerAttack
{
    status_=2;
    [self setSpriteDirection];
    [sprite_ stopAllActions];
    [sprite_ runAction:attack];
    [self schedule:@selector(attack) interval:1];
}

-(void)attack
{
    if([attackedArray_ count]>0){
        for(int i=0;i<[attackedArray_ count];i++)
        {
            Player *p=[attackedArray_ objectAtIndex:i];
            [p reduceBlood:damage];
        }
    }else{
        [self unschedule:@selector(attack)];
        [self playerRun];
    }
}
-(void)playerDie
{
    status_=3;
    isDead=YES;
    [self setSpriteDirection];
    [sprite_ stopAllActions];
    [sprite_ runAction:die];
    if(blood_ == 0)
        NSLog(@"撞墙死的");
    else
        NSLog(@"被人砍死的");
    //[self removeSelfFromeParent];
    //[self scheduleOnce:@selector(removeSelfFromeParent:) delay:1];
    //[self schedule:@selector(removeSelfFromeParent:) interval:0 repeat:1 delay:3];
    [self performSelector:@selector(removeSelfFromeParent) withObject:nil afterDelay:5];
}

-(void)removeSelfFromeParent
{
    [self cleanAttackArray];
    [self.sprite removeFromParentAndCleanup:YES];
}

-(void)cleanAttackArray
{
    [attackedArray_ removeAllObjects];
}

-(BOOL)dead
{
    if(isDead)
    {
        return YES;
    }
    if(blood_ <=0)
    {
        [self playerDie];
        return YES;
    }
    return NO;
}

-(void)setSpriteDirection
{

    if(direction_ == 0){
        [sprite_ setFlipX:NO];
    }else{
        [sprite_ setFlipX:YES];
    }
}

-(void)addToAttackArray:(Player *)player
{
    if([attackedArray_ indexOfObject:player] == NSNotFound){
        [attackedArray_ addObject:player];
    }
}
-(void)removeAttackArray:(Player *)player
{
    if([attackedArray_ indexOfObject:player] != NSNotFound){
        [attackedArray_ removeObject:player];
    }
}

-(void)update:(ccTime)time
{
    for(int i=[attackedArray_ count]-1;i>=0;i--){
        Player *player=[attackedArray_ objectAtIndex:i];
        if([player dead]){
            [attackedArray_ removeObject:player];
        }
    }
    if([attackedArray_ count]>0)
    {
        if(status_ == 1)
        {
            [self playerAttack];
        }
    }
    
}

-(void)reduceBlood:(int)d
{
    blood_-=d;
}

-(void)dealloc
{
    [super dealloc];
    [sprite_ release];
    [attackedArray_ release];
    [run release];
    [attack release];
    [die release];
    NSLog(@"成功释放");
    //NSLog(@"spriteCount:%d",[sprite_ retainCount]);
}
@end
