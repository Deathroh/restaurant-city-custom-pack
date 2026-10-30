package com.playfish.games.cooking.actors
{
   import com.playfish.external.ExternalPage;
   import com.playfish.games.cooking.*;
   import com.playfish.games.cooking.usertask.ClearEmptyPlateTask;
   import com.playfish.games.cooking.utils.ProtectedInt;
   import com.playfish.games.cooking.utils.RandomBasket;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class Customer extends AvatarActor
   {
      
      private static const ANIMATION_USED:Array = [Avatar3D.ANIMATION_IDLE,Avatar3D.ANIMATION_WALK,Avatar3D.ANIMATION_SIT,Avatar3D.ANIMATION_COOKING,Avatar3D.ANIMATION_EAT];
      
      public static const STATE_WALKING:int = 0;
      
      public static const STATE_DECIDING:int = 1;
      
      public static const STATE_ORDERING:int = 2;
      
      public static const STATE_WAITING:int = 3;
      
      public static const STATE_WAITING_FOR_FOOD:int = 4;
      
      public static const STATE_EATING:int = 5;
      
      public static const STATE_PAYING:int = 6;
      
      public static const STATE_ANGRY:int = 7;
      
      public static const STATE_LEAVING:int = 8;
      
      public static const STATE_LEFT:int = 9;
      
      public static const STATE_WAITING_TO_SIT:int = 10;
      
      public static const STATE_PEDESTRIAN:int = 11;
      
      public static const STATE_TOO_MUCH_TRASH:int = 12;
      
      public static const STATE_NO_TABLE:int = 13;
      
      public static const STATE_PLAYING_INTERACTIVE_ITEM:int = 14;
      
      public static const STATE_WALKING_TO_TOILET:int = 15;
      
      public static const STATE_ON_TOILET:int = 16;
      
      public static const STATE_NO_CLEAN_TABLE:int = 17;
      
      public static const STATE_WALKING_TO_SINK:int = 18;
      
      public static const STATE_USING_SINK:int = 19;
      
      public static const STATE_WALKING_TO_ENTRANCE:int = 20;
      
      public static const STATE_RESTAURANT_CLOSED:int = 21;
      
      public static const EMOTION_NO_SEAT:int = 0;
      
      public static const EMOTION_DIRTY:int = 1;
      
      public static const EMOTION_WAIT_TOO_LONG:int = 2;
      
      public static const EMOTION_DECOR:int = 3;
      
      public static const EMOTION_NO_TABLE:int = 4;
      
      public static const EMOTION_NO_CLEAN_TABLE:int = 5;
      
      public static const EMOTION_NO_TOILET:int = 6;
      
      public static const EMOTION_WAIT_TOO_LONG_FOR_DRINK:int = 7;
      
      private static const EATING_TIME:ProtectedInt = new ProtectedInt(25000);
      
      private static const PAYING_TIME:ProtectedInt = new ProtectedInt(2000);
      
      private static const INTERACTIVE_ITEM_PLAYING_TIME:ProtectedInt = new ProtectedInt(30000);
      
      private static const WAITING_FOR_ORDER_TIME:ProtectedInt = new ProtectedInt(10000);
      
      private static const WAITING_FOR_TABLE_TIME:ProtectedInt = new ProtectedInt(20000);
      
      private static const WAITING_FOR_FOOD_TIME:ProtectedInt = new ProtectedInt(120000);
      
      private static const WAITING_FOR_CHAIR_TIME:ProtectedInt = new ProtectedInt(5000);
      
      private static const TOILET_TIME:ProtectedInt = new ProtectedInt(10000);
      
      private static const SINK_TIME:ProtectedInt = new ProtectedInt(4000);
      
      public var state:int = -1;
      
      public var interactiveItem:RoomItem;
      
      public var door:RoomItem;
      
      public var effectTimer:int;
      
      private var timer:int;
      
      public var sinkItem:RoomItem;
      
      private var chairOverlay:MovieClip;
      
      public var chair:RoomItem;
      
      public var order:DishOrder;
      
      public var entranceTileX:int;
      
      public var entranceTileY:int;
      
      private var emotion:GameObject;
      
      public function Customer(param1:int, param2:int, param3:GameUser, param4:WorldRestaurantPlay)
      {
         if(param3.customerAvatarItemsGenerator != param4.customerAvatarItemsGenerator)
         {
            param3.usedAvatarItems.splice(0,param3.usedAvatarItems.length);
            param3.clearAnimationFrames();
            param3.customerAvatarItemsGenerator = param4.customerAvatarItemsGenerator;
         }
         super(param1,param2,param3,param4,ANIMATION_USED);
         if(param3.userInfo != null)
         {
            if(param3.userInfo.playCount == 0)
            {
               this.addInviteFriendBadge();
            }
            else
            {
               this.addPlayingFriendBadge();
            }
            addSelectionEffect("FriendSelection");
         }
         else
         {
            mouseEnabled = false;
            mouseChildren = false;
         }
         param4.createOrderForCustomer(this);
         show();
      }
      
      public function walkToChair(param1:RoomItem, param2:Array) : void
      {
         this.leaveCurrentChair();
         this.setChair(param1);
         this.state = STATE_WALKING;
         setAnimation(Avatar3D.ANIMATION_WALK);
         setMovePath(param2);
      }
      
      public function setChair(param1:RoomItem) : void
      {
         this.chair = param1;
         param1.customer = this;
      }
      
      public function onRestaurantClosed() : void
      {
         this.state = STATE_RESTAURANT_CLOSED;
         this.timer = 2000;
      }
      
      public function waitForFood() : void
      {
         this.timer = WAITING_FOR_FOOD_TIME.value + restaurantPlay.customerWaitTimeModifier;
         this.state = STATE_WAITING_FOR_FOOD;
      }
      
      private function addPlayingFriendBadge() : void
      {
         var _loc1_:AnimatedObject = new AnimatedObject("SpeechBubbleAnimPortrait");
         var _loc2_:DisplayObject = GameWorld.getUserFaceImage(user);
         if(_loc2_ != null)
         {
            _loc1_.getChildMovieClipInstance("mc_portrait").mc_face.addChild(_loc2_);
         }
         _loc1_.getChildMovieClipInstance("mc_happiness").visible = false;
         var _loc3_:TextField = _loc1_.getChildMovieClipInstance("mc_name").tf_name;
         _loc3_.mouseEnabled = false;
         _loc3_.text = user.firstName;
         addMouseOverBadge(_loc1_);
      }
      
      private function setEmotion(param1:int) : void
      {
         var _loc2_:MovieClip = null;
         if(param1 == -1)
         {
            if(this.emotion)
            {
               removeObject(this.emotion);
               this.emotion = null;
            }
         }
         else
         {
            _loc2_ = Engine.getMovieClip("Emotions");
            _loc2_.gotoAndStop(param1 + 1);
            this.emotion = new GameObject("SpeechBubbleAnim");
            this.emotion.mouseEnabled = false;
            this.emotion.mouseChildren = false;
            this.emotion.getChildMovieClipInstance("mc_content").addChild(_loc2_);
            this.emotion.type = param1;
            this.emotion.y = -WorldRestaurant.tileHeight - 10;
            this.emotion.numLoops = 1;
            addObject(this.emotion);
         }
      }
      
      public function gotoSink() : Boolean
      {
         var _loc1_:RandomBasket = null;
         var _loc2_:RoomItem = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:Array = restaurantPlay.getEmptySinks().sort(this.compareRoomItemDistance);
         if(_loc5_.length > 0)
         {
            _loc1_ = new RandomBasket();
            _loc1_.addItemArray(_loc5_);
            _loc2_ = null;
            while(true)
            {
               _loc2_ = _loc1_.getNextItem() as RoomItem;
               if(_loc2_ == null)
               {
                  break;
               }
               _loc3_ = WorldRestaurant.getFacingTile(_loc2_.tileX,_loc2_.tileY,_loc2_.getRotationCount());
               _loc4_ = getPathTo(_loc3_.x,_loc3_.y,false);
               if(_loc4_ != null)
               {
                  setMovePath(_loc4_);
                  this.state = STATE_WALKING_TO_SINK;
                  setAnimation(Avatar3D.ANIMATION_WALK);
                  this.leaveCurrentChair();
                  this.sinkItem = _loc2_;
                  this.sinkItem.customer = this;
                  return true;
               }
            }
         }
         return false;
      }
      
      private function checkForFreeChair(param1:Boolean, param2:Boolean) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:Object = this.getPathToRandomValidEmptyChair(param1,param2);
         if(_loc4_ != null)
         {
            this.walkToChair(_loc4_.item,_loc4_.path);
            this.setEmotion(-1);
            return true;
         }
         _loc3_ = restaurantPlay.getPathToRandomInteractiveItem(this,restaurantPlay.getEmptyInteractiveItems());
         if(_loc3_)
         {
            this.walkToInteractiveItem(_loc3_.item,_loc3_.path);
            this.setEmotion(-1);
            return true;
         }
         return false;
      }
      
      private function onInviteClick(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.CLICK,this.onInviteClick);
         removeMouseOverBadge();
         this.addPlayingFriendBadge();
         var _loc2_:ExternalPage = GameWorld.onInviteClicked();
      }
      
      public function leaveCurrentChair() : void
      {
         if(this.chairOverlay != null)
         {
            removeChild(this.chairOverlay);
            this.chairOverlay = null;
         }
         if(this.chair != null)
         {
            this.chair.customer = null;
            this.chair = null;
         }
      }
      
      override public function tick(param1:uint) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:RoomItem = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         super.tick(param1);
         if(this.state == STATE_WALKING_TO_ENTRANCE)
         {
            if(reachedPathEnd())
            {
               if(restaurantPlay.restaurantClosed)
               {
                  this.onRestaurantClosed();
               }
               else
               {
                  _loc2_ = restaurantPlay.gameUser.trashCount.value;
                  if(_loc2_ > 0 && Engine.rnd(0,20) < _loc2_)
                  {
                     this.onTooMuchTrash();
                  }
                  else
                  {
                     if(restaurantPlay.waitingChairQueue.length > 0)
                     {
                        _loc3_ = this.getPathToRandomValidEmptyChair(true,false);
                     }
                     else
                     {
                        _loc3_ = this.getPathToRandomValidEmptyChair(false,false);
                     }
                     if(_loc3_)
                     {
                        this.walkToChair(_loc3_.item,_loc3_.path);
                     }
                     else
                     {
                        _loc4_ = restaurantPlay.getPathToRandomInteractiveItem(this,restaurantPlay.getEmptyInteractiveItems());
                        if(_loc4_)
                        {
                           this.walkToInteractiveItem(_loc4_.item,_loc4_.path);
                        }
                        else
                        {
                           this.onNoSeat();
                        }
                     }
                  }
                  if(this.door)
                  {
                     restaurantPlay.openDoor(this.door);
                  }
               }
            }
         }
         else if(this.state == STATE_WAITING_TO_SIT)
         {
            if(this.timer <= 0)
            {
               this.leaveUnhappy();
            }
            else
            {
               if(restaurantPlay.waitingChairQueue.length > 0)
               {
                  this.checkForFreeChair(true,false);
               }
               else
               {
                  this.checkForFreeChair(false,false);
               }
               if(!this.emotion && reachedPathEnd())
               {
                  this.setEmotion(EMOTION_NO_SEAT);
                  setAnimation(Avatar3D.ANIMATION_IDLE);
               }
            }
         }
         else if(this.state == STATE_TOO_MUCH_TRASH)
         {
            if(this.timer <= 0)
            {
               this.leaveUnhappy();
            }
            else if(!this.emotion && reachedPathEnd())
            {
               this.setEmotion(EMOTION_DIRTY);
            }
         }
         else if(this.state == STATE_RESTAURANT_CLOSED)
         {
            if(this.timer <= 0)
            {
               this.leave();
            }
         }
         else if(this.state == STATE_NO_TABLE)
         {
            if(this.timer <= 0)
            {
               this.leaveUnhappy();
            }
            else if(restaurantPlay.waitingChairQueue.indexOf(this) == 0)
            {
               if(this.checkForFreeChair(false,true))
               {
                  restaurantPlay.waitingChairQueue.splice(0,1);
               }
            }
         }
         else if(this.state == STATE_NO_CLEAN_TABLE)
         {
            if(this.timer <= 0)
            {
               this.leaveUnhappy();
            }
            else
            {
               _loc5_ = restaurant.getTableForChair(this.chair);
               if(Boolean(_loc5_) && restaurant.isTableFree(_loc5_))
               {
                  this.setEmotion(-1);
                  restaurantPlay.addOrderFromCustomer(this);
                  this.order.table = _loc5_;
                  _loc5_.tableTopOrder = this.order;
                  this.state = STATE_WAITING;
               }
            }
         }
         else if(this.state == STATE_WALKING)
         {
            if(reachedPathEnd())
            {
               if(this.chair)
               {
                  this.sitOnChair(this.chair);
                  this.timer = 1000;
                  this.state = STATE_DECIDING;
               }
               else if(this.interactiveItem)
               {
                  _loc6_ = (this.interactiveItem.getRotationCount() + 2) % 4;
                  setDirection(WorldRestaurant.getActorDirectionFromItemRotation(_loc6_));
                  restaurantPlay.setRoomItemState(this.interactiveItem,"on");
                  setAnimation(Avatar3D.ANIMATION_COOKING);
                  this.timer = INTERACTIVE_ITEM_PLAYING_TIME.value;
                  this.state = STATE_PLAYING_INTERACTIVE_ITEM;
               }
            }
         }
         else if(this.state == STATE_PLAYING_INTERACTIVE_ITEM)
         {
            if(this.timer <= 0)
            {
               restaurantPlay.setRoomItemState(this.interactiveItem,"off");
               restaurantPlay.setRoomItemUsageCount(this.interactiveItem,this.interactiveItem.usageCount + 1);
               restaurantPlay.onCustomerPayForFunctional(this.interactiveItem);
               this.interactiveItem.customer = null;
               this.interactiveItem = null;
               this.leave();
            }
         }
         else if(this.state == STATE_DECIDING)
         {
            if(this.timer <= 0)
            {
               _loc5_ = restaurant.getTableForChair(this.chair);
               if(_loc5_ == null)
               {
                  this.setEmotion(EMOTION_NO_TABLE);
                  this.timer = WAITING_FOR_TABLE_TIME.value + restaurantPlay.customerWaitTimeModifier;
                  this.state = STATE_NO_TABLE;
                  restaurantPlay.waitingChairQueue.push(this);
               }
               else if(!restaurant.isTableFree(_loc5_))
               {
                  this.setEmotion(EMOTION_NO_CLEAN_TABLE);
                  this.timer = WAITING_FOR_ORDER_TIME.value + restaurantPlay.customerWaitTimeModifier;
                  this.state = STATE_NO_CLEAN_TABLE;
               }
               else
               {
                  restaurantPlay.addOrderFromCustomer(this);
                  this.order.table = _loc5_;
                  _loc5_.tableTopOrder = this.order;
                  this.timer = WAITING_FOR_ORDER_TIME.value + restaurantPlay.customerWaitTimeModifier;
                  this.state = STATE_WAITING;
               }
            }
         }
         else if(this.state == STATE_WAITING || this.state == STATE_WAITING_FOR_FOOD)
         {
            if(this.timer <= 0)
            {
               if(this.order.recipe.type == Recipe.MENU_RECIPE_DRINK)
               {
                  this.setEmotion(EMOTION_WAIT_TOO_LONG_FOR_DRINK);
               }
               else
               {
                  this.setEmotion(EMOTION_WAIT_TOO_LONG);
               }
               this.leaveUnhappy();
            }
         }
         else if(this.state == STATE_EATING)
         {
            _loc7_ = EATING_TIME.value;
            this.order.setFrame(1 + (this.order.getFrameCount() - 1) * (_loc7_ - this.timer) / _loc7_);
            if(this.timer <= 0)
            {
               setAnimation(Avatar3D.ANIMATION_SIT);
               restaurantPlay.emptyPlates.push(this.order);
               if(!restaurantPlay.visitMode)
               {
                  ClearEmptyPlateTask.addUserTaskListener(this.order);
               }
               this.order = null;
               this.timer = PAYING_TIME.value;
               this.state = STATE_PAYING;
            }
         }
         else if(this.state == STATE_PAYING)
         {
            if(this.timer <= 0)
            {
               if(restaurant.gameUser.level.value >= GameWorld.TOILET_START_LEVEL && Engine.rnd(0,3) == 0)
               {
                  this.gotoToilet();
               }
               else
               {
                  this.leaveHappy();
               }
            }
         }
         else if(this.state == STATE_LEAVING)
         {
            if(this.door)
            {
               if(tileX > 0 && tileY > 0 && Math.abs(this.door.tileX - tileX) + Math.abs(this.door.tileY - tileY) <= 1)
               {
                  restaurantPlay.openDoor(this.door);
               }
            }
            if(reachedPathEnd())
            {
               this.state = STATE_LEFT;
               if(this.emotion != null)
               {
                  this.setEmotion(-1);
               }
               restaurantPlay.removeCustomer(this);
            }
         }
         else if(this.state == STATE_ANGRY)
         {
            if(this.timer <= 0)
            {
               this.leaveUnhappy();
            }
         }
         else if(this.state == STATE_PEDESTRIAN)
         {
            if(speedX == 0 && speedY == 0)
            {
               restaurantPlay.removeCustomer(this);
            }
         }
         else if(this.state == STATE_WALKING_TO_TOILET)
         {
            if(reachedPathEnd())
            {
               this.sitOnChair(this.chair);
               this.state = STATE_ON_TOILET;
               this.timer = restaurantPlay.getModifiedOperateTime(this.chair,TOILET_TIME.value);
               setAnimation(Avatar3D.ANIMATION_SIT);
            }
         }
         else if(this.state == STATE_ON_TOILET)
         {
            if(this.timer <= 0)
            {
               restaurantPlay.setRoomItemUsageCount(this.chair,this.chair.usageCount + 1);
               if(!this.gotoSink())
               {
                  this.leaveHappy();
               }
            }
         }
         else if(this.state == STATE_WALKING_TO_SINK)
         {
            if(reachedPathEnd())
            {
               _loc6_ = (this.sinkItem.getRotationCount() + 2) % 4;
               setDirection(WorldRestaurant.getActorDirectionFromItemRotation(_loc6_));
               this.state = STATE_USING_SINK;
               this.timer = SINK_TIME.value;
               setAnimation(Avatar3D.ANIMATION_COOKING);
            }
         }
         else if(this.state == STATE_USING_SINK)
         {
            if(this.timer <= 0)
            {
               this.leaveHappy();
            }
         }
         if(this.timer > 0)
         {
            this.timer -= param1;
         }
         if(this.effectTimer > 0)
         {
            this.effectTimer -= param1;
         }
      }
      
      public function onNoSeat() : void
      {
         this.timer = WAITING_FOR_CHAIR_TIME.value + restaurantPlay.customerWaitTimeModifier;
         this.state = STATE_WAITING_TO_SIT;
         this.moveToFrontOfEntrance();
      }
      
      private function compareRoomItemDistance(param1:RoomItem, param2:RoomItem) : int
      {
         var _loc3_:int = Math.abs(param1.tileX - tileX) + Math.abs(param1.tileY - tileY);
         var _loc4_:int = Math.abs(param2.tileX - tileX) + Math.abs(param2.tileY - tileY);
         if(_loc3_ < _loc4_)
         {
            return -1;
         }
         if(_loc3_ == _loc4_)
         {
            return 0;
         }
         return 1;
      }
      
      public function leaveUnhappy() : void
      {
         var _loc1_:GameObject = null;
         restaurantPlay.addDemand(WorldRestaurantPlay.DEMAND_BONUS_UNHAPPY_CUSTOMER);
         if(restaurant.gameUser == GameWorld.gameUser)
         {
            GameWorld.gameUser.awards.addValue(GameAwards.AWARD_UNHAPPY_CUSTOMERS,1);
         }
         _loc1_ = new GameObject("Popularity");
         _loc1_.getChildMovieClipInstance("mc_icon").gotoAndStop(2);
         _loc1_.x = 0;
         _loc1_.y = -WorldRestaurant.tileHeight;
         _loc1_.drawPriority = 100;
         _loc1_.numLoops = 1;
         _loc1_.removeWhenComplete = true;
         addObject(_loc1_);
         this.leave();
      }
      
      public function leave() : void
      {
         if(this.sinkItem != null)
         {
            this.sinkItem.customer = null;
            this.sinkItem = null;
         }
         var _loc1_:int = restaurantPlay.waitingChairQueue.indexOf(this);
         if(_loc1_ != -1)
         {
            restaurantPlay.waitingChairQueue.splice(_loc1_,1);
         }
         this.leaveCurrentChair();
         if(moveToTile(this.entranceTileX,this.entranceTileY,false))
         {
            setAnimation(Avatar3D.ANIMATION_WALK);
         }
         this.state = STATE_LEAVING;
         restaurantPlay.onCustomerLeave(this);
      }
      
      private function addInviteFriendBadge() : void
      {
         var _loc1_:AnimatedObject = new AnimatedObject("SpeechBubbleAnimFriendInvite");
         var _loc2_:MovieClip = _loc1_.getChildMovieClipInstance("mc_content");
         var _loc3_:DisplayObject = GameWorld.getUserFaceImage(user);
         if(_loc3_ != null)
         {
            _loc2_.mc_portrait.mc_face.addChild(_loc3_);
         }
         GameWorld.textHandler.setTextFieldWithId(_loc2_.tf_text,"ClickToInviteMe");
         _loc2_.tf_text.mouseEnabled = false;
         var _loc4_:TextField = _loc1_.getChildMovieClipInstance("mc_name").tf_name;
         _loc4_.mouseEnabled = false;
         _loc4_.text = user.firstName;
         addEventListener(MouseEvent.CLICK,this.onInviteClick,false,0,true);
         addMouseOverBadge(_loc1_);
      }
      
      public function onTooMuchTrash() : void
      {
         this.timer = 2000;
         this.state = STATE_TOO_MUCH_TRASH;
         this.moveToFrontOfEntrance();
      }
      
      public function setPedestrian(param1:int, param2:int) : void
      {
         this.state = STATE_PEDESTRIAN;
         moveTo(WorldRestaurant.getScreenX(param1,param2),WorldRestaurant.getScreenY(param1,param2));
         setAnimation(Avatar3D.ANIMATION_WALK);
      }
      
      public function reset(param1:int, param2:int, param3:WorldRestaurantPlay) : void
      {
         this.restaurant = param3;
         setPosition(param1,param2);
         this.state = -1;
         this.timer = 0;
      }
      
      public function gotoToilet() : void
      {
         var _loc1_:RandomBasket = null;
         var _loc2_:RoomItem = null;
         var _loc3_:Array = restaurantPlay.getEmptyToiletSeats().sort(this.compareRoomItemDistance);
         if(_loc3_.length > 0)
         {
            _loc1_ = new RandomBasket();
            _loc1_.addItemArray(_loc3_);
            _loc2_ = null;
            while(true)
            {
               _loc2_ = _loc1_.getNextItem() as RoomItem;
               if(_loc2_ == null)
               {
                  break;
               }
               if(moveToRoomItem(_loc2_,false))
               {
                  this.state = STATE_WALKING_TO_TOILET;
                  setAnimation(Avatar3D.ANIMATION_WALK);
                  this.leaveCurrentChair();
                  this.setChair(_loc2_);
                  return;
               }
            }
         }
         this.setEmotion(EMOTION_NO_TOILET);
         this.leave();
      }
      
      public function walkToInteractiveItem(param1:RoomItem, param2:Array) : void
      {
         this.leaveCurrentChair();
         this.interactiveItem = param1;
         param1.customer = this;
         this.state = STATE_WALKING;
         setAnimation(Avatar3D.ANIMATION_WALK);
         setMovePath(param2);
      }
      
      public function eatOrder() : void
      {
         if(!restaurantPlay.silentTick)
         {
            restaurantPlay.eatingSound.play(1);
         }
         setAnimation(Avatar3D.ANIMATION_EAT);
         this.timer = EATING_TIME.value;
         this.state = STATE_EATING;
      }
      
      public function sitOnChair(param1:RoomItem) : void
      {
         this.chairOverlay = Engine.getMovieClip(param1.itemConfig.className + "Overlay");
         if(this.chairOverlay != null)
         {
            this.chairOverlay.gotoAndStop(param1.getRotationCount() + 1);
            addChild(this.chairOverlay);
         }
         setDirection(WorldRestaurant.getActorDirectionFromItemRotation(param1.getRotationCount()));
         setAnimation(Avatar3D.ANIMATION_SIT);
      }
      
      public function leaveHappy() : void
      {
         restaurantPlay.addDemand(WorldRestaurantPlay.DEMAND_BONUS_HAPPY_CUSTOMER);
         if(restaurant.gameUser == GameWorld.gameUser)
         {
            GameWorld.gameUser.awards.addValue(GameAwards.AWARD_HAPPY_CUSTOMERS,1);
         }
         var _loc1_:GameObject = new GameObject("Popularity");
         _loc1_.getChildMovieClipInstance("mc_icon").gotoAndStop(1);
         _loc1_.x = 0;
         _loc1_.y = -WorldRestaurant.tileHeight;
         _loc1_.drawPriority = 100;
         _loc1_.numLoops = 1;
         _loc1_.removeWhenComplete = true;
         addObject(_loc1_);
         this.leave();
      }
      
      private function moveToFrontOfEntrance() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.entranceTileY == 0)
         {
            _loc1_ = this.entranceTileX;
            _loc2_ = this.entranceTileY + 1;
         }
         else
         {
            _loc1_ = this.entranceTileX + 1;
            _loc2_ = this.entranceTileY;
         }
         setAnimation(Avatar3D.ANIMATION_WALK);
         moveTo(WorldRestaurant.getScreenX(_loc1_,_loc2_),WorldRestaurant.getScreenY(_loc1_,_loc2_));
      }
      
      public function walkToEntrance(param1:int, param2:int, param3:RoomItem) : void
      {
         this.door = param3;
         this.entranceTileX = param1;
         this.entranceTileY = param2;
         this.state = STATE_WALKING_TO_ENTRANCE;
         if(param2 == 0)
         {
            setMovePath([[-1,-1],[param1,-1],[param1,param2]]);
         }
         else
         {
            setMovePath([[-1,param2],[param1,param2]]);
         }
         setAnimation(Avatar3D.ANIMATION_WALK);
      }
      
      public function getPathToRandomValidEmptyChair(param1:Boolean, param2:Boolean) : Object
      {
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         if(!param1)
         {
            _loc3_ = restaurantPlay.getEmptyChairs(true,true,this.order);
            if(_loc3_.length > 0)
            {
               _loc4_ = restaurantPlay.getPathToRandomRoomItem(this,_loc3_);
            }
            if(_loc4_ == null)
            {
               _loc3_ = restaurantPlay.getEmptyChairs(true,false,this.order);
               if(_loc3_.length > 0)
               {
                  _loc4_ = restaurantPlay.getPathToRandomRoomItem(this,_loc3_);
               }
            }
            if(_loc4_ == null)
            {
               _loc3_ = restaurantPlay.getEmptyChairs(true,true,null);
               if(_loc3_.length > 0)
               {
                  _loc4_ = restaurantPlay.getPathToRandomRoomItem(this,_loc3_);
               }
            }
            if(_loc4_ == null)
            {
               _loc3_ = restaurantPlay.getEmptyChairs(true,false,null);
               if(_loc3_.length > 0)
               {
                  _loc4_ = restaurantPlay.getPathToRandomRoomItem(this,_loc3_);
               }
            }
         }
         if(!param2 && _loc4_ == null)
         {
            _loc3_ = restaurantPlay.getEmptyChairs(false,false,null);
            if(_loc3_.length > 0)
            {
               _loc4_ = restaurantPlay.getPathToRandomRoomItem(this,_loc3_);
            }
         }
         return _loc4_;
      }
   }
}

