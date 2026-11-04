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

      // 2026-11-03, efeitos de julho/2010 (param4 = configuracao do SnowGenerator):
      //   "cai"    como a neve, com a arte dada e velocidade velMin..velMax (Rain Cloud: RainDropIndoor)
      //   "petala" como a petala (Cherry Blossom Tree original: SakuraTreeLeaf01..03)
      //   "sobe"   sobe balancando e some em ~5 s, como os coracoes (Musical Note, Magic Unicorn)
      private var sobe:Boolean = false;

      //   "nada"   (2026-11-04, Coral Garden) peixe que atravessa o salao numa das 4 direcoes do piso, com a arte
      //            de 4 quadros (FloatingFish01..03: 1 = baixo-direita, 2 = baixo-esquerda, 3 = cima-esquerda,
      //            4 = cima-direita, como os bichos), balancando de leve, e some em ~7 s. Blog oficial
      //            (2010-05-25): "releases schools of fish into your restaurant ... swimming around your table".
      private var nada:Boolean = false;

      private var nadaDir:int = 1;

      public function RoomSnowEffectObject(param1:int, param2:int, param3:Boolean = false, param4:Object = null)
      {
         var _loc5_:String = param3 ? "RCR_Petal0" + Engine.rnd(1,4) : "SnowFlake0" + Engine.rnd(1,3);
         var _loc6_:Number = Engine.rndFloat(MIN_SPEED_Y,MAX_SPEED_Y);
         var _loc7_:int = -1;
         var _loc8_:Number = 0;
         var _loc9_:Number = 0;
         var _loc10_:Number = 0;
         this.floorY = WorldRestaurant.getScreenY(param1,param2);
         if(param4 != null)
         {
            _loc5_ = String(param4.simbolos[Engine.rnd(0,param4.simbolos.length)]);
            param3 = param4.modo == "petala";
            this.sobe = param4.modo == "sobe";
            this.nada = param4.modo == "nada";
            if(param4.velMin != null)
            {
               _loc6_ = Engine.rndFloat(Number(param4.velMin),Number(param4.velMax));
            }
         }
         this.petal = param3;
         if(param3)
         {
            this.petalSpeedY = Engine.rndFloat(PETAL_MIN_SPEED_Y,PETAL_MAX_SPEED_Y);
            this.petalDrift = Engine.rndFloat(-0.3,0.3);
            this.curAngle = Engine.rndFloat(0,6.28);
         }
         _loc8_ = this.floorY - (param3 ? Engine.rnd(120,200) : Engine.rnd(100,140));
         if(param3)
         {
            _loc6_ = 0;
         }
         if(this.sobe)
         {
            this.curAngle = Engine.rndFloat(0,6.28);
            _loc8_ = this.floorY - Engine.rnd(10,60);
            _loc6_ = Engine.rndFloat(-2.2,-0.8);
            _loc7_ = 5000 + Engine.rnd(-1000,1000);
         }
         if(this.nada)
         {
            this.nadaDir = Engine.rnd(1,5);
            _loc10_ = Engine.rndFloat(0.6,1.1);
            _loc9_ = (this.nadaDir == 1 || this.nadaDir == 4 ? 1 : -1) * _loc10_;
            _loc6_ = (this.nadaDir <= 2 ? 0.5 : -0.5) * _loc10_;
            _loc8_ = this.floorY;
            _loc7_ = 7000 + Engine.rnd(-1500,1500);
            this.curAngle = Engine.rndFloat(0,6.28);
         }
         super(_loc5_,WorldRestaurant.getScreenX(param1,param2),_loc8_,_loc9_,_loc6_,_loc7_);
         if(this.nada && content != null && content.totalFrames >= this.nadaDir)
         {
            content.gotoAndStop(this.nadaDir);
         }
      }

      override public function tick(param1:uint) : void
      {
         super.tick(param1);
         if(this.nada)
         {
            this.curAngle += 0.07;
            y -= this.xOffset;
            this.xOffset = Math.sin(this.curAngle) * 4;
            y += this.xOffset;
            return;
         }
         if(this.sobe)
         {
            this.curAngle += 0.08;
            x -= this.xOffset;
            this.xOffset = Math.sin(this.curAngle) * 14;
            x += this.xOffset;
            return;
         }
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
