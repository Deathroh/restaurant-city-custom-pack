package com.playfish.games.cooking.actors
{
   import com.playfish.games.cooking.Engine;
   import com.playfish.games.cooking.PathFinder;
   import com.playfish.games.cooking.WorldRestaurant;
   import com.playfish.games.cooking.utils.RandomBasket;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class MovingVisitActor extends RestaurantActor
   {
      
      public static const WALK_RIGHT:int = 1;
      
      public static const WALK_DOWN:int = 2;
      
      public static const WALK_LEFT:int = 3;
      
      public static const WALK_UP:int = 4;
      
      public static const STAND_STILL:int = 5;
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_WALK:int = 1;
      
      public var idleTimer:int = 2000;
      
      public var tileBasket:RandomBasket = new RandomBasket();
      
      public var state:int = 1;
      
      public function MovingVisitActor(param1:String, param2:WorldRestaurant)
      {
         super(param1,param2);
         moveSpeedX = 0.02;
         moveSpeedY = 0.01;
         content.gotoAndStop(WALK_DOWN);
         this.buildTileBasket();
      }
      
      public function buildTileBasket() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 2;
         while(_loc3_ < restaurant.numTilesY)
         {
            _loc1_ = 2;
            while(_loc1_ < restaurant.numTilesX)
            {
               _loc2_ = WorldRestaurant.getTileIndex(_loc1_,_loc3_);
               if(restaurant.isWalkable(_loc1_,_loc3_) && !restaurant.wallMap[_loc2_])
               {
                  this.tileBasket.addItems(_loc2_);
               }
               _loc1_++;
            }
            _loc3_++;
         }
      }
      
      override public function setPosition(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = x;
         var _loc4_:Number = y;
         x = param1;
         y = param2;
         tileX = WorldRestaurant.getTileIndexX(x,y + WorldRestaurant.tileHeightHalf);
         tileY = WorldRestaurant.getTileIndexY(x,y + WorldRestaurant.tileHeightHalf);
         drawPriority = WorldRestaurant.getTileDrawPriority(tileX,tileY);
      }
      
      override public function moveTo(param1:Number, param2:Number) : void
      {
         super.moveTo(param1,param2);
      }
      
      public function getRandomDestination() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Point = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Array = [WALK_RIGHT,WALK_DOWN,WALK_LEFT,WALK_UP];
         var _loc12_:int = WorldRestaurant.getTileIndexX(x,y);
         var _loc13_:int = WorldRestaurant.getTileIndexY(x,y);
         while(!_loc9_ && !_loc10_)
         {
            _loc1_ = int(_loc11_[Engine.rnd(0,_loc11_.length)]);
            _loc2_ = this.getDestinationFromOption(_loc1_);
            _loc3_ = _loc12_ + _loc2_.x;
            _loc4_ = _loc13_ + _loc2_.y;
            _loc5_ = WorldRestaurant.getTileIndex(_loc3_,_loc4_);
            if(this.tileBasket.contains(_loc5_))
            {
               _loc9_ = true;
               _loc6_ = WorldRestaurant.getScreenX(_loc3_,_loc4_);
               _loc7_ = WorldRestaurant.getScreenY(_loc3_,_loc4_);
               this.moveTo(_loc6_,_loc7_);
               content.gotoAndStop(_loc1_);
            }
            else
            {
               _loc8_ = _loc11_.indexOf(_loc1_);
               _loc11_.splice(_loc8_,1);
               if(_loc11_.length == 0)
               {
                  _loc10_ = true;
               }
            }
         }
         if(_loc10_)
         {
         }
      }
      
      public function getPathTo(param1:int, param2:int, param3:Boolean = false) : Array
      {
         var _loc4_:PathFinder = new PathFinder(tileX,tileY,param1,param2,restaurant,param3);
         if(_loc4_.processOpenList(-1) == PathFinder.PROCESS_STATE_FOUND)
         {
            return _loc4_.getFinalPath();
         }
         return null;
      }
      
      private function getDestinationFromOption(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         if(param1 == WALK_RIGHT)
         {
            _loc2_.x = 1;
            _loc2_.y = 0;
         }
         else if(param1 == WALK_LEFT)
         {
            _loc2_.x = -1;
            _loc2_.y = 0;
         }
         else if(param1 == WALK_UP)
         {
            _loc2_.x = 0;
            _loc2_.y = -1;
         }
         else
         {
            _loc2_.x = 0;
            _loc2_.y = 1;
         }
         return _loc2_;
      }
      
      public function setInitialTilePosition(param1:int, param2:int) : void
      {
         setTilePosition(param1,param2);
      }
      
      public function setInitialRandomLocation() : void
      {
         var _loc1_:int = this.tileBasket.getNextItem() as int;
         var _loc2_:int = WorldRestaurant.getTileXFromTileIndex(_loc1_);
         var _loc3_:int = WorldRestaurant.getTileYFromTileIndex(_loc1_);
         setTilePosition(_loc2_,_loc3_);
      }
      
      public function idle() : void
      {
         this.state = STATE_IDLE;
         this.idleTimer = 2000;
         content.gotoAndStop(STAND_STILL);
      }
      
      override public function tick(param1:uint) : void
      {
         var _loc2_:MovieClip = null;
         super.tick(param1);
         if(this.state == STATE_WALK)
         {
            if(reachedPathEnd())
            {
               if(Engine.rnd(0,2))
               {
                  this.getRandomDestination();
               }
               else
               {
                  this.idle();
               }
            }
         }
         else if(this.state == STATE_IDLE)
         {
            _loc2_ = content.mc_idlepenguin;
            if((this.idleTimer = this.idleTimer - param1) < 0)
            {
               if(Engine.rnd(0,2))
               {
                  this.state = STATE_WALK;
                  this.getRandomDestination();
               }
               else
               {
                  this.idle();
               }
            }
         }
      }
   }
}

