package com.playfish.games.cooking.actors
{
   import com.playfish.games.cooking.*;
   import com.playfish.games.cooking.usertask.ClearEmptyPlateTask;
   import com.playfish.games.cooking.utils.ProtectedInt;
   
   public class Waitor extends EmployeeActor
   {
      
      private static const ANIMATION_USED:Array = [Avatar3D.ANIMATION_IDLE,Avatar3D.ANIMATION_WALK,Avatar3D.ANIMATION_WAITOR_WALK,Avatar3D.ANIMATION_WAITOR_WORKING,Avatar3D.ANIMATION_DEAD];
      
      private static const MAX_WALK_SPEED_Y:Number = 0.03;
      
      private static const MIN_WALK_SPEED_Y:Number = 0.01;
      
      private static const ACTION_DELAY_MAX:ProtectedInt = new ProtectedInt(6000);
      
      private static const ACTION_DELAY_MIN:ProtectedInt = new ProtectedInt(2000);
      
      private static const DRINK_MAKING_DELAY_MAX:ProtectedInt = new ProtectedInt(24000);
      
      private static const DRINK_MAKING_DELAY_MIN:ProtectedInt = new ProtectedInt(12000);
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_SERVING:int = 1;
      
      public static const STATE_MOVING_BACK:int = 2;
      
      public static const STATE_MOVING_TO_GET_ORDER:int = 3;
      
      public static const STATE_MOVING_TO_GET_EMPTY_PLATE:int = 4;
      
      public static const STATE_MOVING_TO_GET_DRINK_ORDER:int = 5;
      
      public static const STATE_DEAD:int = 6;
      
      private var delayTimer:int;
      
      private var emptyPlate:DishOrder;
      
      public var drinkItem:RoomItem;
      
      private var step:int;
      
      public var order:DishOrder;
      
      private var state:int = 0;
      
      private var servableChairs:Array = new Array();
      
      public var kitchen:RoomItem;
      
      private var reachableKitchenItems:Array = new Array();
      
      private var reachableDrinkItems:Array = new Array();
      
      private var pathToCustomer:Array;
      
      public function Waitor(param1:RoomItem, param2:GameUserEmployee, param3:WorldRestaurantPlay)
      {
         this.kitchen = param1;
         this.restaurant = param3;
         this.restaurantPlay = param3;
         this.setInitialTilePosition();
         super(WorldRestaurant.getScreenX(tileX,tileY),WorldRestaurant.getScreenY(tileX,tileY),param2,param3,ANIMATION_USED);
      }
      
      private function onRemove() : void
      {
         if(Boolean(this.order) && Boolean(this.order.customer))
         {
            if(this.order.recipe.type == Recipe.MENU_RECIPE_DRINK)
            {
               restaurantPlay.orders.push(this.order);
               this.order.customer.state = Customer.STATE_WAITING;
            }
            else if(this.state != STATE_SERVING)
            {
               restaurantPlay.completedOrders.push(this.order);
            }
            else
            {
               this.order.customer.state = Customer.STATE_WAITING;
            }
            this.order = null;
         }
         if(this.drinkItem)
         {
            restaurantPlay.setRoomItemState(this.drinkItem,"close");
            this.drinkItem.waiter = null;
            this.drinkItem = null;
         }
         if(this.emptyPlate)
         {
            restaurantPlay.emptyPlates.push(this.emptyPlate);
            this.emptyPlate = null;
         }
      }
      
      private function getDelay(param1:int, param2:int) : int
      {
         var _loc3_:Number = employeeUser.workTime / GameUserEmployee.MAX_WORK_TIME * 100;
         if(_loc3_ >= 80)
         {
            return param1;
         }
         if(_loc3_ < 20)
         {
            return param2;
         }
         return param2 - (param2 - param1) * (_loc3_ - 20) / 60;
      }
      
      public function addReachableKitchenItems(param1:RoomItem) : void
      {
         if(this.reachableKitchenItems.indexOf(param1) == -1)
         {
            this.reachableKitchenItems.push(param1);
         }
      }
      
      public function setWalkSpeed() : void
      {
         var _loc1_:Number = employeeUser.workTime / GameUserEmployee.MAX_WORK_TIME * 100;
         if(_loc1_ >= 80)
         {
            moveSpeedY = MAX_WALK_SPEED_Y;
         }
         else if(_loc1_ < 20)
         {
            moveSpeedY = MIN_WALK_SPEED_Y;
         }
         else
         {
            moveSpeedY = MIN_WALK_SPEED_Y + (MAX_WALK_SPEED_Y - MIN_WALK_SPEED_Y) * (_loc1_ - 20) / 60;
         }
         moveSpeedX = moveSpeedY * 2;
      }
      
      public function addServableChair(param1:RoomItem) : void
      {
         if(this.servableChairs.indexOf(param1) == -1)
         {
            this.servableChairs.push(param1);
         }
      }
      
      public function setNormalWalkSpeed() : void
      {
         moveSpeedY = DEFAULT_MOVE_SPEED_Y;
         moveSpeedX = DEFAULT_MOVE_SPEED_X;
      }
      
      public function canReachDrinkItem(param1:RoomItem) : Boolean
      {
         return this.reachableDrinkItems.indexOf(param1) != -1;
      }
      
      private function setInitialTilePosition() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = this.kitchen.tileX;
         var _loc4_:int = this.kitchen.tileY;
         var _loc5_:Array = new Array();
         _loc5_.push([-1,0]);
         _loc5_.push([-1,-1]);
         _loc5_.push([-1,1]);
         _loc5_.push([0,-1]);
         _loc5_.push([0,1]);
         _loc5_.push([1,-1]);
         _loc5_.push([1,1]);
         this.rotateOffsets(_loc5_,this.kitchen.getRotationCount());
         var _loc6_:int = -1;
         var _loc7_:int = -1;
         var _loc8_:Number = 0;
         while(_loc8_ < _loc5_.length)
         {
            _loc1_ = _loc5_[_loc8_][0] + _loc3_;
            _loc2_ = _loc5_[_loc8_][1] + _loc4_;
            if(restaurant.isWalkable(_loc1_,_loc2_))
            {
               if(_loc6_ == -1)
               {
                  _loc6_ = _loc1_;
                  _loc7_ = _loc2_;
               }
               if(!restaurantPlay.isOccupiedByEmployeeActor(_loc1_,_loc2_))
               {
                  tileX = _loc1_;
                  tileY = _loc2_;
                  return;
               }
            }
            _loc8_++;
         }
         if(_loc6_ == -1 && _loc7_ == -1)
         {
            tileX = Engine.rnd(-4,-1);
            tileY = Engine.rnd(1,restaurant.numTilesY);
         }
         else
         {
            tileX = _loc6_;
            tileY = _loc7_;
         }
      }
      
      public function clearServableChairs() : void
      {
         this.servableChairs.splice(0,this.servableChairs.length);
         this.reachableDrinkItems.splice(0,this.reachableDrinkItems.length);
         this.reachableKitchenItems.splice(0,this.reachableKitchenItems.length);
      }
      
      public function addReachableDrinkItems(param1:RoomItem) : void
      {
         if(this.reachableDrinkItems.indexOf(param1) == -1)
         {
            this.reachableDrinkItems.push(param1);
         }
      }
      
      override public function tick(param1:uint) : void
      {
         var _loc2_:RoomItem = null;
         var _loc3_:RoomItem = null;
         super.tick(param1);
         this.setWalkSpeed();
         if(this.state != STATE_IDLE)
         {
            if(this.state == STATE_MOVING_BACK)
            {
               if(reachedPathEnd())
               {
                  this.state = STATE_IDLE;
                  setAnimation(Avatar3D.ANIMATION_IDLE);
               }
            }
            else if(this.state == STATE_MOVING_TO_GET_ORDER)
            {
               if(this.order == null)
               {
                  this.moveBack();
               }
               else if(this.step == 0)
               {
                  if(reachedPathEnd())
                  {
                     this.step = 1;
                     face(WorldRestaurant.getScreenX(this.order.tileX,this.order.tileY),WorldRestaurant.getScreenY(this.order.tileX,this.order.tileY));
                     setAnimation(Avatar3D.ANIMATION_WAITOR_WORKING);
                  }
               }
               else if(this.step == 1)
               {
                  this.delayTimer -= param1;
                  if(this.delayTimer <= 0)
                  {
                     this.serveCustomer();
                  }
               }
            }
            else if(this.state == STATE_MOVING_TO_GET_DRINK_ORDER)
            {
               if(this.order == null)
               {
                  this.moveBack();
               }
               else if(this.step == 0)
               {
                  if(reachedPathEnd())
                  {
                     this.step = 1;
                     face(WorldRestaurant.getScreenX(this.drinkItem.tileX,this.drinkItem.tileY),WorldRestaurant.getScreenY(this.drinkItem.tileX,this.drinkItem.tileY));
                     setAnimation(Avatar3D.ANIMATION_WAITOR_WORKING);
                     restaurantPlay.setRoomItemState(this.drinkItem,"open");
                  }
               }
               else if(this.step == 1)
               {
                  this.delayTimer -= param1;
                  if(this.delayTimer <= 0)
                  {
                     restaurantPlay.setRoomItemState(this.drinkItem,"close");
                     this.serveCustomer();
                  }
               }
            }
            else if(this.state == STATE_MOVING_TO_GET_EMPTY_PLATE)
            {
               if(this.step == 0)
               {
                  if(this.emptyPlate.inUserTaskQueue)
                  {
                     this.moveBack();
                  }
                  else if(reachedPathEnd())
                  {
                     this.step = 1;
                     if(!restaurantPlay.visitMode)
                     {
                        ClearEmptyPlateTask.removeUserTaskListener(this.emptyPlate);
                     }
                     face(WorldRestaurant.getScreenX(this.emptyPlate.tileX,this.emptyPlate.tileY),WorldRestaurant.getScreenY(this.emptyPlate.tileX,this.emptyPlate.tileY));
                     setAnimation(Avatar3D.ANIMATION_WAITOR_WORKING);
                  }
               }
               else if(this.step == 1)
               {
                  this.delayTimer -= param1;
                  if(this.delayTimer <= 0)
                  {
                     restaurantPlay.clearEmptyPlate(this.emptyPlate);
                     this.emptyPlate = null;
                     this.moveBack();
                  }
               }
            }
            else if(this.state == STATE_SERVING)
            {
               if(this.order == null)
               {
                  this.moveBack();
               }
               else if(reachedPathEnd())
               {
                  _loc2_ = this.order.customer.chair;
                  _loc3_ = restaurant.getTableForChair(_loc2_);
                  if(_loc3_)
                  {
                     face(WorldRestaurant.getScreenX(_loc3_.tileX,_loc3_.tileY),WorldRestaurant.getScreenY(_loc3_.tileX,_loc3_.tileY));
                     this.order.tileX = _loc3_.tileX;
                     this.order.tileY = _loc3_.tileY;
                     this.order.x = WorldRestaurant.getScreenX(_loc3_.tileX,_loc3_.tileY);
                     this.order.y = WorldRestaurant.getScreenY(_loc3_.tileX,_loc3_.tileY) + WorldRestaurant.tileHeightHalf - restaurant.getTileTopHeight(_loc3_.tileX,_loc3_.tileY);
                     this.order.drawPriority = _loc3_.drawPriority;
                     restaurant.room.addObject(this.order);
                     this.order.customer.eatOrder();
                  }
                  else
                  {
                     Engine.showMessage("order delivered to a place with no table");
                     this.order.customer.leave();
                  }
                  this.order = null;
                  this.moveBack();
               }
            }
            if(this.state == STATE_DEAD)
            {
               if(employeeUser.workTime > 0)
               {
                  setEmotion(-1);
                  this.state = STATE_IDLE;
                  setAnimation(Avatar3D.ANIMATION_IDLE);
               }
            }
         }
      }
      
      public function canServe(param1:Customer) : Boolean
      {
         return param1.chair != null && this.servableChairs.indexOf(param1.chair) != -1;
      }
      
      public function canReachKitchenItem(param1:RoomItem) : Boolean
      {
         return this.reachableKitchenItems.indexOf(param1) != -1;
      }
      
      private function rotateOffsets(param1:Array, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         param2 %= 4;
         if(param2 != 0)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               if(param2 == 1)
               {
                  _loc4_ = Number(param1[_loc3_][1]);
                  param1[_loc3_][1] = param1[_loc3_][0];
                  param1[_loc3_][0] = -_loc4_;
               }
               else if(param2 == 2)
               {
                  param1[_loc3_][0] = -param1[_loc3_][0];
                  param1[_loc3_][1] = -param1[_loc3_][1];
               }
               else if(param2 == 3)
               {
                  _loc4_ = Number(param1[_loc3_][1]);
                  param1[_loc3_][1] = -param1[_loc3_][0];
                  param1[_loc3_][0] = _loc4_;
               }
               _loc3_++;
            }
         }
      }
      
      public function canServeChair(param1:RoomItem) : Boolean
      {
         return param1 != null && this.servableChairs.indexOf(param1) != -1;
      }
      
      public function moveBack() : void
      {
         this.order = null;
         this.emptyPlate = null;
         if(this.drinkItem)
         {
            this.drinkItem.waiter = null;
            this.drinkItem = null;
         }
         var _loc1_:Array = restaurantPlay.getSortedKitchens(this.kitchen);
         var _loc2_:Number = 0;
         while(_loc2_ < _loc1_.length)
         {
            if(moveToRoomItem(_loc1_[_loc2_],true))
            {
               this.kitchen = _loc1_[_loc2_];
               this.state = STATE_MOVING_BACK;
               setAnimation(Avatar3D.ANIMATION_WALK);
               return;
            }
            _loc2_++;
         }
         setAnimation(Avatar3D.ANIMATION_IDLE);
         this.state = STATE_IDLE;
      }
      
      public function getOrderFromDrinkItem(param1:DishOrder, param2:Array, param3:RoomItem) : void
      {
         this.drinkItem = param3;
         param3.waiter = this;
         this.state = STATE_MOVING_TO_GET_DRINK_ORDER;
         setMovePath(param2);
         this.step = 0;
         this.delayTimer = restaurantPlay.getModifiedOperateTime(param3,this.getDelay(DRINK_MAKING_DELAY_MIN.value,DRINK_MAKING_DELAY_MAX.value));
         this.order = param1;
         param1.customer.waitForFood();
         setAnimation(Avatar3D.ANIMATION_WALK);
      }
      
      override public function setDead() : void
      {
         if(this.state != STATE_DEAD)
         {
            super.setDead();
            setEmotion(EMOTION_NEED_FOOD);
            setAnimation(Avatar3D.ANIMATION_DEAD);
            this.onRemove();
            this.state = STATE_DEAD;
         }
      }
      
      public function serveCustomer() : void
      {
         if(this.order.kitchen)
         {
            restaurantPlay.setRoomItemState(this.order.kitchen,"idle");
            this.order.kitchen = null;
         }
         if(this.drinkItem)
         {
            this.drinkItem.waiter = null;
            this.drinkItem = null;
         }
         if(this.pathToCustomer == null)
         {
            this.pathToCustomer = restaurantPlay.getPathToCustomer(tileX,tileY,this.order.customer);
         }
         if(this.pathToCustomer)
         {
            this.state = STATE_SERVING;
            this.pathToCustomer.pop();
            setMovePath(this.pathToCustomer);
            setAnimation(Avatar3D.ANIMATION_WAITOR_WALK);
            this.order.customer.waitForFood();
         }
         else
         {
            setAnimation(Avatar3D.ANIMATION_IDLE);
            this.state = STATE_IDLE;
         }
         this.pathToCustomer = null;
      }
      
      public function getOrderFromKitchen(param1:DishOrder, param2:Array = null, param3:Array = null) : void
      {
         this.pathToCustomer = param3;
         if(param2 != null)
         {
            setMovePath(param2);
            this.state = STATE_MOVING_TO_GET_ORDER;
         }
         else if(moveToRoomItem(param1.kitchen,true))
         {
            this.state = STATE_MOVING_TO_GET_ORDER;
         }
         if(this.state == STATE_MOVING_TO_GET_ORDER)
         {
            this.step = 0;
            this.delayTimer = this.getDelay(ACTION_DELAY_MIN.value,ACTION_DELAY_MAX.value);
            this.order = param1;
            this.kitchen = param1.kitchen;
            setAnimation(Avatar3D.ANIMATION_WALK);
         }
      }
      
      public function doGetEmptyPlate(param1:DishOrder, param2:Array) : void
      {
         this.delayTimer = this.getDelay(ACTION_DELAY_MIN.value,ACTION_DELAY_MAX.value);
         this.step = 0;
         this.state = STATE_MOVING_TO_GET_EMPTY_PLATE;
         this.emptyPlate = param1;
         setMovePath(param2);
         setAnimation(Avatar3D.ANIMATION_WALK);
      }
      
      public function isFree() : Boolean
      {
         return this.state == STATE_IDLE || this.state == STATE_MOVING_BACK;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.onRemove();
      }
      
      public function hasReachableDrinkItems() : Boolean
      {
         return this.reachableDrinkItems.length > 0;
      }
   }
}

