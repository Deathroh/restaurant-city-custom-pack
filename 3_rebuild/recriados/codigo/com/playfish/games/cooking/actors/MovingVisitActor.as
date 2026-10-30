package com.playfish.games.cooking.actors
{
   import com.playfish.games.cooking.Engine;
   import com.playfish.games.cooking.PathFinder;
   import com.playfish.games.cooking.WorldRestaurant;
   import com.playfish.games.cooking.utils.RandomBasket;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;

   // Recriado (2026-10-28): modo robo (Monster Robot, funcao "RobotWalker"), ligado por startRobot().
   // Anda uma casa por vez, sem vai-e-volta (ver robotStep) e, a cada 4 a 7 casas, para de 1 a 3 s.
   // Arte (RCR_MonsterRobotAndando): um quadro so, com as pecas mc_af/mc_ac (andando de frente/costas) e
   // mc_pf/mc_pc (parado); robotShow() liga a certa e espelha. Sem startRobot() tudo continua como antes.
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

      public var robot:Boolean = false;

      private var robotSteps:int = 0;

      private var robotDir:int = 2;

      // Casa do robo em inteiros, atualizada a cada passo (em vez de recalcular pela posicao na tela).
      private var robotTX:int = 0;

      private var robotTY:int = 0;

      // Rota: casas andadas na direcao atual, quantas seguir antes de virar (1 a 3) e as ultimas casas visitadas.
      private var robotRun:int = 0;

      private var robotRunMax:int = 2;

      private var robotTrail:Array = [];

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
         if(this.robot)
         {
            this.idleTimer = Engine.rnd(1000,3001);
            this.robotShow(false,this.robotDir);
            return;
         }
         this.idleTimer = 2000;
         content.gotoAndStop(STAND_STILL);
      }

      // ---- modo robo ----------------------------------------------------------

      // param1: giro do item (getRotationCount 0..3). Os angulos do Monster Robot sao frente espelhada (baixo-direita),
      // frente (baixo-esquerda), costas (cima-esquerda) e costas espelhada (cima-direita): giro + 1 = direcao do
      // robo (1 RIGHT, 2 DOWN, 3 LEFT, 4 UP). Ele comeca olhando e andando para onde o item foi virado (2026-10-29;
      // antes todos comecavam em DOWN).
      public function startRobot(param1:int = 1) : void
      {
         this.robot = true;
         this.robotDir = (param1 % 4 + 4) % 4 + 1;
         this.robotSteps = Engine.rnd(4,8);
         this.idle();
      }

      // Comeca na casa livre mais perto do item (anel por anel, ate 10 casas); sem nenhuma, numa casa livre qualquer.
      public function placeNear(param1:int, param2:int) : void
      {
         var _loc3_:int = 1;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc3_ <= 10)
         {
            _loc4_ = -_loc3_;
            while(_loc4_ <= _loc3_)
            {
               _loc5_ = _loc3_ - Math.abs(_loc4_);
               if(this.tileBasket.contains(WorldRestaurant.getTileIndex(param1 + _loc4_,param2 + _loc5_)))
               {
                  this.robotPlace(param1 + _loc4_,param2 + _loc5_);
                  return;
               }
               if(_loc5_ != 0 && this.tileBasket.contains(WorldRestaurant.getTileIndex(param1 + _loc4_,param2 - _loc5_)))
               {
                  this.robotPlace(param1 + _loc4_,param2 - _loc5_);
                  return;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         this.setInitialRandomLocation();
         this.robotPlace(tileX,tileY);
      }

      private function robotPlace(param1:int, param2:int) : void
      {
         this.robotTX = param1;
         this.robotTY = param2;
         setTilePosition(param1,param2);
      }

      private function robotTryMove(param1:int, param2:int, param3:int) : Boolean
      {
         var _loc4_:Point = this.getDestinationFromOption(param1);
         var _loc5_:int = param2 + _loc4_.x;
         var _loc6_:int = param3 + _loc4_.y;
         if(!this.tileBasket.contains(WorldRestaurant.getTileIndex(_loc5_,_loc6_)))
         {
            return false;
         }
         this.robotDir = param1;
         this.robotTX = _loc5_;
         this.robotTY = _loc6_;
         this.moveTo(WorldRestaurant.getScreenX(_loc5_,_loc6_),WorldRestaurant.getScreenY(_loc5_,_loc6_));
         this.robotShow(true,param1);
         return true;
      }

      // Liga so a peca do desenho certo (mc_af/mc_ac andando, mc_pf/mc_pc parado; f = frente, c = costas) e
      // espelha pelo scaleX. A frente olha para baixo e a esquerda; as costas, para cima e a esquerda.
      // Sem troca de quadro: no Ruffle, gotoAndStop entre quadros de angulo as vezes nao trocava o desenho.
      private function robotShow(param1:Boolean, param2:int) : void
      {
         var _loc3_:Boolean = param2 == WALK_LEFT || param2 == WALK_UP;
         var _loc4_:String = (param1 ? "mc_a" : "mc_p") + (_loc3_ ? "c" : "f");
         var _loc5_:Array = ["mc_af","mc_ac","mc_pf","mc_pc"];
         var _loc6_:DisplayObject = null;
         var _loc7_:int = 0;
         while(_loc7_ < _loc5_.length)
         {
            _loc6_ = content.getChildByName(_loc5_[_loc7_]);
            if(_loc6_)
            {
               _loc6_.visible = _loc5_[_loc7_] == _loc4_;
            }
            _loc7_++;
         }
         content.scaleX = param2 == WALK_RIGHT || param2 == WALK_UP ? -1 : 1;
      }

      // Proxima casa (2026-10-28, pedido da dona: nada de vai-e-volta na mesma rota):
      // - sem meia-volta: a direcao oposta so vale se for a unica saida (beco);
      // - evita as ultimas 6 casas por onde passou (se ainda houver outra opcao);
      // - segue reto de 1 a 3 casas e entao e obrigado a virar.
      private function robotStep() : Boolean
      {
         var _loc1_:int = this.robotTX;
         var _loc2_:int = this.robotTY;
         var _loc3_:Array = [WALK_RIGHT,WALK_DOWN,WALK_LEFT,WALK_UP];
         var _loc4_:int = robotOpposite(this.robotDir);
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Point = null;
         while(_loc9_ < _loc3_.length)
         {
            _loc8_ = int(_loc3_[_loc9_]);
            _loc10_ = this.getDestinationFromOption(_loc8_);
            if(_loc8_ != _loc4_ && this.tileBasket.contains(WorldRestaurant.getTileIndex(_loc1_ + _loc10_.x,_loc2_ + _loc10_.y)))
            {
               _loc6_.push(_loc8_);
               if(this.robotTrail.indexOf(WorldRestaurant.getTileIndex(_loc1_ + _loc10_.x,_loc2_ + _loc10_.y)) < 0)
               {
                  _loc5_.push(_loc8_);
               }
            }
            _loc9_++;
         }
         _loc7_ = _loc5_.length > 0 ? _loc5_ : _loc6_;
         if(_loc7_.length == 0)
         {
            _loc7_ = [_loc4_];
         }
         if(this.robotRun < this.robotRunMax && _loc7_.indexOf(this.robotDir) >= 0)
         {
            _loc8_ = this.robotDir;
         }
         else
         {
            if(_loc7_.length > 1 && _loc7_.indexOf(this.robotDir) >= 0)
            {
               _loc7_.splice(_loc7_.indexOf(this.robotDir),1);
            }
            _loc8_ = int(_loc7_[Engine.rnd(0,_loc7_.length)]);
         }
         if(_loc8_ != this.robotDir)
         {
            this.robotRun = 0;
            this.robotRunMax = Engine.rnd(1,4);
         }
         this.robotTrail.push(WorldRestaurant.getTileIndex(_loc1_,_loc2_));
         if(this.robotTrail.length > 6)
         {
            this.robotTrail.shift();
         }
         if(this.robotTryMove(_loc8_,_loc1_,_loc2_))
         {
            this.robotRun++;
            return true;
         }
         return false;
      }

      private static function robotOpposite(param1:int) : int
      {
         if(param1 == WALK_RIGHT)
         {
            return WALK_LEFT;
         }
         if(param1 == WALK_LEFT)
         {
            return WALK_RIGHT;
         }
         if(param1 == WALK_UP)
         {
            return WALK_DOWN;
         }
         return WALK_UP;
      }

      private function robotTick(param1:uint) : void
      {
         if(this.state == STATE_WALK)
         {
            if(reachedPathEnd())
            {
               this.robotSteps--;
               if(this.robotSteps <= 0)
               {
                  this.robotSteps = Engine.rnd(4,8);
                  this.idle();
               }
               else if(!this.robotStep())
               {
                  this.idle();
               }
            }
         }
         else
         {
            this.idleTimer -= param1;
            if(this.idleTimer < 0)
            {
               this.state = STATE_WALK;
               if(!this.robotStep())
               {
                  this.idle();
               }
            }
         }
      }

      override public function tick(param1:uint) : void
      {
         var _loc2_:MovieClip = null;
         super.tick(param1);
         if(this.robot)
         {
            this.robotTick(param1);
            return;
         }
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
