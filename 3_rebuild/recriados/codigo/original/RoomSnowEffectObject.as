package com.playfish.games.cooking.itemfunctions
{
   import com.playfish.games.cooking.Engine;
   import com.playfish.games.cooking.WorldRestaurant;
   
   public class RoomSnowEffectObject extends EffectObject
   {
      
      public static const MIN_SPEED_Y:Number = 1.5;
      
      public static const MAX_SPEED_Y:Number = 3;
      
      private var curAngle:Number = 0;
      
      private var xOffset:Number = 0;
      
      private var floorY:int;
      
      public function RoomSnowEffectObject(param1:int, param2:int)
      {
         this.floorY = WorldRestaurant.getScreenY(param1,param2);
         super("SnowFlake0" + Engine.rnd(1,3),WorldRestaurant.getScreenX(param1,param2),this.floorY - Engine.rnd(100,140),0,Engine.rndFloat(MIN_SPEED_Y,MAX_SPEED_Y),-1);
      }
      
      override public function tick(param1:uint) : void
      {
         super.tick(param1);
         this.curAngle += 0.1;
         x -= this.xOffset;
         this.xOffset = Math.sin(this.curAngle) * 10;
         x += this.xOffset;
         if(this.floorY - y <= 10)
         {
            alpha = (this.floorY - y) / 10;
            if(this.floorY - y <= 0)
            {
               remove();
            }
         }
      }
   }
}

