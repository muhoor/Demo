//
//  Player.h
//  Demo
//
//  Created by 许 晨阳 on 12-11-22.
//
//

#import "CCSprite.h"

@interface Player :CCNode
{

    
 
}
@property(atomic,retain)CCSprite *sprite;
@property int direction;
@property int status;
@property int blood;

+(id)initAuto;


-(void)move;

-(BOOL)dead;

-(void)addToAttackArray:(Player *)player;
-(void)removeAttackArray:(Player *)player;

-(void)cleanAttackArray;

-(void)setSpritePosition:(CGPoint) point;

-(void)reduceBlood:(int)d;
@end
