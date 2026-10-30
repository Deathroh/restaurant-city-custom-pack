package com.playfish.games.cooking.itemfunctions
{
   import com.playfish.games.cooking.PerfTrace;
   import com.playfish.games.cooking.RoomItem;
   import com.playfish.games.cooking.WorldRestaurantPlay;
   import com.playfish.games.cooking.actors.MovingVisitActor;

   public class RoomItemFunction
   {

      protected var roomItem:RoomItem;

      // recriado (2026-10-28): funcao "RobotWalker" (Monster Robot). Ao abrir o restaurante, o item parado
      // some e no lugar dele um MovingVisitActor no modo robo, com a arte <classe>Andando, passeia pelo salao.
      // Ao sair do modo de jogo (destroy), o ator sai e o item volta a aparecer. Sem walkerClass, nada muda.
      private var walkerClass:String;

      private var walker:MovingVisitActor;

      private var walkerWorld:WorldRestaurantPlay;

      public function RoomItemFunction(param1:RoomItem)
      {
         super();
         this.roomItem = param1;
      }
      
      public static function create(param1:String, param2:RoomItem) : RoomItemFunction
      {
         var _loc3_:Class = null;
         switch(param1)
         {
            case "PoshCustomers":
               _loc3_ = PoshCustomers;
               break;
            case "ZombieCustomers":
               _loc3_ = ZombieCustomers;
               break;
            case "BananaTrash":
               _loc3_ = BananaTrash;
               break;
            case "SeaShellTrash":
               _loc3_ = SeaShellTrash;
               break;
            case "BunnyCustomers":
               _loc3_ = BunnyCustomers;
               break;
            case "ClockArms":
               _loc3_ = ClockArms;
               break;
            case "BubbleGeyser":
               _loc3_ = BubbleGeyser;
               break;
            case "LeafFootprint":
               _loc3_ = LeafFootprint;
               break;
            case "SnowFootprint":
               _loc3_ = SnowFootprint;
               break;
            case "AddCustomerWaitTime":
               _loc3_ = AddCustomerWaitTime;
               break;
            case "AddMaxDemand1":
               _loc3_ = AddMaxDemand1;
               break;
            case "CrystalTrash":
               _loc3_ = CrystalTrash;
               break;
            case "SnowGenerator":
               _loc3_ = SnowGenerator;
               break;
            case "SantaElfCustomers":
               _loc3_ = SantaElfCustomers;
               break;
            case "AddMaxDemand2":
               _loc3_ = AddMaxDemand2;
               break;
            case "HeartGenerator":
               _loc3_ = HeartGenerator;
               break;
            case "PetalGenerator":
               // recriado (2026-10-26): petalas de cerejeira caindo pelo salao (Cherry Blossom Tree)
               return new SnowGenerator(param2,true);
            case "RobotWalker":
               // recriado (2026-10-28): o Monster Robot passeia pelo salao
               var _loc4_:RoomItemFunction = new RoomItemFunction(param2);
               _loc4_.walkerClass = param2.itemConfig.className + "Andando";
               return _loc4_;
         }
         if(_loc3_)
         {
            return new _loc3_(param2);
         }
         return null;
      }
      
      public function init(param1:WorldRestaurantPlay) : void
      {
         if(this.walkerClass)
         {
            this.walkerWorld = param1;
            this.walker = new MovingVisitActor(this.walkerClass,param1);
            this.walker.placeNear(this.roomItem.tileX,this.roomItem.tileY);
            this.walker.startRobot(this.roomItem.getRotationCount());
            this.walker.mouseEnabled = false;
            this.walker.mouseChildren = false;
            param1.room.addObject(this.walker);
            this.roomItem.visible = false;
            PerfTrace.mark("[RCR] RobotWalker: item em " + this.roomItem.tileX + "," + this.roomItem.tileY + "; robo comeca em " + this.walker.tileX + "," + this.walker.tileY);
         }
      }

      public function destroy() : void
      {
         if(this.walker)
         {
            this.walkerWorld.room.removeObject(this.walker);
            this.walker.destroy();
            this.walker = null;
            this.roomItem.visible = true;
         }
      }
      
      public function tick(param1:uint) : void
      {
      }
   }
}

