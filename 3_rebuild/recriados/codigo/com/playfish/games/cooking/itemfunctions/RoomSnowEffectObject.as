package com.playfish.games.cooking.itemfunctions
{
   import com.playfish.games.cooking.Engine;
   import com.playfish.games.cooking.WorldRestaurant;
   import flash.display.MovieClip;

   // Recriado (2026-10-26): com param3 = true vira petala de cerejeira (sprites RCR_Petal01..03 no
   // indoor_asset.swf): cai mais devagar, balanca mais, pousa no chao, fica um pouco e some.
   // Sem param3 o floco de neve e exatamente o original.
   public class RoomSnowEffectObject extends EffectObject
   {

      public static const MIN_SPEED_Y:Number = 1.5;

      public static const MAX_SPEED_Y:Number = 3;

      public static const PETAL_MIN_SPEED_Y:Number = 0.6;

      public static const PETAL_MAX_SPEED_Y:Number = 1.3;

      private static const PETAL_REST_MSEC:int = 1500;

      private static const PETAL_FADE_MSEC:int = 800;

      private var curAngle:Number = 0;

      private var xOffset:Number = 0;

      private var floorY:int;

      private var petal:Boolean;

      private var petalSpeedY:Number = 0;

      private var petalDrift:Number = 0;

      private var restTime:int = -1;

      public function RoomSnowEffectObject(param1:int, param2:int, param3:Boolean = false)
      {
         this.floorY = WorldRestaurant.getScreenY(param1,param2);
         this.petal = param3;
         if(param3)
         {
            this.petalSpeedY = Engine.rndFloat(PETAL_MIN_SPEED_Y,PETAL_MAX_SPEED_Y);
            this.petalDrift = Engine.rndFloat(-0.3,0.3);
            this.curAngle = Engine.rndFloat(0,6.28);
         }
         super(param3 ? "RCR_Petal0" + Engine.rnd(1,4) : "SnowFlake0" + Engine.rnd(1,3),WorldRestaurant.getScreenX(param1,param2),this.floorY - (param3 ? Engine.rnd(120,200) : Engine.rnd(100,140)),0,param3 ? 0 : Engine.rndFloat(MIN_SPEED_Y,MAX_SPEED_Y),-1);
      }

      override public function tick(param1:uint) : void
      {
         super.tick(param1);
         if(this.petal)
         {
            this.tickPetal(param1);
            return;
         }
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

      private function tickPetal(param1:uint) : void
      {
         var _loc2_:MovieClip = null;
         if(removed)
         {
            return;
         }
         if(this.restTime >= 0)
         {
            this.restTime += param1;
            if(this.restTime >= PETAL_REST_MSEC)
            {
               alpha = 1 - (this.restTime - PETAL_REST_MSEC) / PETAL_FADE_MSEC;
               if(alpha <= 0)
               {
                  remove();
               }
            }
            return;
         }
         this.curAngle += 0.06;
         x -= this.xOffset;
         this.xOffset = Math.sin(this.curAngle) * 16;
         x += this.xOffset + this.petalDrift;
         y += this.petalSpeedY;
         if(y >= this.floorY)
         {
            y = this.floorY;
            this.restTime = 0;
            if(content != null && content.numChildren > 0)
            {
               _loc2_ = content.getChildAt(0) as MovieClip;
               if(_loc2_ != null)
               {
                  _loc2_.stop();
               }
            }
         }
      }
   }
}
