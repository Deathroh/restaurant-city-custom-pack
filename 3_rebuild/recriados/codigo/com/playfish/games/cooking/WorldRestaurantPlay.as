package com.playfish.games.cooking
{
   import com.playfish.games.cooking.actors.*;
   import com.playfish.games.cooking.arcadegame.cave.*;
   import com.playfish.games.cooking.arcadegame.snake.*;
   import com.playfish.games.cooking.debug.DebugDailyBonus;
   import com.playfish.games.cooking.events.FriendListEvent;
   import com.playfish.games.cooking.events.GameEvent;
   import com.playfish.games.cooking.extension.restaurant.TutorialExtension;
   import com.playfish.games.cooking.foodking.*;
   import com.playfish.games.cooking.ui.*;
   import com.playfish.games.cooking.ui.mail.*;
   import com.playfish.games.cooking.usertask.*;
   import com.playfish.games.cooking.utils.ProtectedInt;
   import com.playfish.games.cooking.utils.RandomBasket;
   import com.playfish.games.cooking.visitactivities.VisitActivity;
   import com.playfish.rpc.cooking.Mail;
   import com.playfish.rpc.cooking.RpcClient;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.geom.Rectangle;
   import flash.utils.*;
   
   public class WorldRestaurantPlay extends WorldRestaurant
   {
      
      public static var restaurantClosedTimer:int;
      
      public static var instance:WorldRestaurantPlay;
      
      public static var firstVisitIngredientReward:IngredientItem;
      
      public static var dailyIngredientMail:MailItem = null;
      
      public static var specialDayPresentMails:Array = new Array();
      
      public static var showOnSaleCashIngredientsPopUp:Boolean = true;
      
      public static const HAPPINESS_DECREASE_RATE_CHEF:ProtectedInt = new ProtectedInt(3 * 60 * 60 * 1000);
      
      public static const HAPPINESS_DECREASE_RATE_WAITOR:ProtectedInt = new ProtectedInt(3 * 60 * 60 * 1000);
      
      public static const HAPPINESS_DECREASE_RATE_CLEANER:ProtectedInt = new ProtectedInt(3 * 60 * 60 * 1000);
      
      public static const HAPPINESS_INCREASE_RATE_REST:ProtectedInt = new ProtectedInt(1 * 60 * 60 * 1000);
      
      public static const REST_WORK_TIME_INCREASE_MULTIPLYER:ProtectedInt = new ProtectedInt(3);
      
      public static const CUSTOMERS_PER_MINUTE_PER_DEMAND:Number = 0.05;
      
      public static const DEMAND_BONUS_HAPPY_CUSTOMER:Number = 1;
      
      public static const DEMAND_BONUS_UNHAPPY_CUSTOMER:Number = -1;
      
      private static const NUM_CACHED_CUSTOMERS:int = 15;
      
      public static const PEDESTRAIN_CREATE_TIMER:int = 10000;
      
      public static const CAR_CREATE_TIMER:int = 10000;
      
      public static const PEDESTRIAN_START_TILE_POSITION:Array = [[-1,-20],[-1,35]];
      
      public static const PEDESTRIAN_END_TILE_POSITION:Array = [[-1,35],[-1,-20]];
      
      public static const CAR_START_TILE_POSITION:Array = [[-7,-20]];
      
      public static const CAR_END_TILE_POSITION:Array = [[-7,35]];
      
      private static var cachedCustomerUsers:Array = new Array();
      
      private static const DEFAULT_TRASH_ITEMS:Array = ["BananaPeel","PizzaSlice","SodaCan","ChickenLeg","AppleCore"];
      
      public var buttonChangeMenu:MovieClip;
      
      private var customerTimer:int;
      
      private var drinkItems:Array = new Array();
      
      private var beds:Array = new Array();
      
      public var buttonMarket:MovieClip;
      
      private var bgMusicId:int;
      
      public var buttonPhoto:MovieClip;
      
      public var maxTrashCoins:int = 1;
      
      private var sinks:Array = new Array();
      
      public var buttonAward:MovieClip;
      
      private var chairs:Array = new Array();
      
      public var buttonFolder:MovieClip;
      
      public var customers:Array = new Array();
      
      public var buttonDecorate:MovieClip;
      
      private var ingredientShop:MovieClip;
      
      private const DEBUG_PLAYER:Boolean = false;
      
      public var buttonMessage:MovieClip;
      
      public var buttonDiscord:MovieClip;

      public var buttonOwnExchange:MovieClip;
      
      public var cleaners:Array = new Array();
      
      public var coinPickUpSound:GameSound = new GameSound("SfxCoinPickUp",GameSound.TYPE_SOUND);
      
      private var doors:Array = new Array();
      
      public var buttonBookmark:MovieClip;
      
      public var uiLevelBar:MovieClip;
      
      private var unreadMailCount:int = 0;
      
      public var trashCount:ProtectedInt = new ProtectedInt(0);
      
      public var trashObjects:Array = new Array();
      
      public var maxDemand:int = 500;
      
      public var customerWaitTimeModifier:int = 0;
      
      public var buttonMusicPlayer:MovieClip;
      
      public var showRestaurantClosedToolTip:Boolean = false;
      
      private var bgMusic:GameSound;
      
      private var achievementItem:RoomItem;
      
      public var orders:Array = new Array();
      
      public var uiButton:MovieClip;
      
      public var uiPopularity:MovieClip;
      
      private var enableRating:Boolean = false;
      
      public var userTaskQueue:UserTaskQueue = new UserTaskQueue();
      
      public var trashMap:Array = new Array();
      
      public var restaurantClosed:Boolean = false;
      
      public var completedOrders:Array = new Array();
      
      private var menuItem:RoomItem;
      
      private var debugPlayer:AvatarActor;
      
      private var foodKing:FoodKing;
      
      public var uiVisitBanner:MovieClip;
      
      public var buttonAvatar:MovieClip;
      
      private var carCreateTimer:int;
      
      private var curCountryIndex:int = 0;
      
      private var kitchens:Array = new Array();
      
      public var waitors:Array = new Array();
      
      public var trashItems:Array = new Array();
      
      private var mailItem:RoomItem;
      
      public var employeeActors:Array = new Array();
      
      public var chefs:Array = new Array();
      
      private var pedestrianCreateTimer:int;
      
      private var curFriendsList:WorldFriendsList = WorldStreet.streetUserList;
      
      private var zoomLever:ZoomLever;
      
      public var waitingChairQueue:Array = new Array();
      
      private var visitActivity:VisitActivity = null;
      
      public var buttonGift:MovieClip;
      
      public var visitMode:Boolean = false;
      
      public var silentTick:Boolean = false;
      
      public var cookingSound:GameSound = new GameSound("SfxCooking",GameSound.TYPE_SOUND);
      
      public var cashSound:GameSound = new GameSound("SfxCash",GameSound.TYPE_SOUND);
      
      public var eatingSound:GameSound = new GameSound("SfxEating",GameSound.TYPE_SOUND);
      
      public var customerAvatarItemsGenerator:Function = GameUser.getRandomCustomerAvatarItems;
      
      public var coinDropSound:GameSound = new GameSound("SfxCoinDrop",GameSound.TYPE_SOUND);
      
      public var emptyPlates:Array = new Array();
      
      public var buttonStreet:MovieClip;
      
      public var folderButtonHandler:FolderButton;
      
      public var levelBar:LevelBar;
      
      private var nextCustomer:Customer;
      
      private var interactiveItems:Array = new Array();
      
      public function WorldRestaurantPlay(param1:GameUser, param2:Boolean = false, param3:Boolean = false)
      {
         var _loc4_:int = getTimer();
         PerfTrace.mark("WorldRestaurantPlay constructor begin visitMode=" + param2 + " employees=" + param1.employeeUsers.length);
         this.visitMode = param2;
         this.enableRating = param3;
         super(param1);
         PerfTrace.slow("WorldRestaurantPlay constructor/super",_loc4_,5);
         PerfTrace.mark("WorldRestaurantPlay constructor end");
      }
      
      public static function setRating(param1:MovieClip, param2:GameUser) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:Number = 0;
         if(param2.userInfo.nbVote > 0)
         {
            _loc4_ = param2.userInfo.totalMark / param2.userInfo.nbVote;
         }
         var _loc5_:int = 0;
         while(_loc5_ < 5)
         {
            _loc3_ = param1["mc_star" + _loc5_];
            _loc3_.stop();
            _loc3_.mc_content.mc_mask.scaleX = 1 - Math.min(1,_loc4_ - _loc5_);
            _loc5_++;
         }
         GameWorld.textHandler.setReplaceString("votes",param2.userInfo.nbVote.toString());
         GameWorld.textHandler.setReplaceString("rating",_loc4_.toFixed(2));
         param1.toolTip = new ToolTip(param1,GameWorld.textHandler.getTextFromId("ToolTipVotesAverageRating"));
      }
      
      public function onButtonAwardClick(param1:MouseEvent) : void
      {
         this.showAwardPopUp();
      }
      
      private function onButtonMarketClick(param1:MouseEvent) : void
      {
         this.showIngredientShop();
      }
      
      public function activityCompleted() : void
      {
         var _loc1_:int = GameWorld.getVisitRewardAmount();
         GameWorld.cashPanel.addCoins(_loc1_);
         this.addGourmetPoints(Math.min(_loc1_,GameWorld.MAX_VISIT_ACTIVITY_GP));
         GameWorld.saveProfileHandler.completedActivityFor(gameUser.userInfo.id);
         GameWorld.addVisitedFriendToday(gameUser.userInfo.id);
      }
      
      public function onButtonDecorateClick(param1:MouseEvent) : void
      {
         this.destroy();
         var _loc2_:WorldRestaurantEditor = new WorldRestaurantEditor(gameUser);
         _loc2_.room.x = room.x;
         _loc2_.room.y = room.y;
         Engine.setActiveWorld(_loc2_);
         param1.stopImmediatePropagation();
      }
      
      public function addChef(param1:GameUserEmployee) : void
      {
         var _loc2_:RoomItem = null;
         var _loc3_:int = 0;
         var _loc4_:ChefActor = null;
         if(this.kitchens.length > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < this.kitchens.length)
            {
               if(!this.isKitchenOccupied(this.kitchens[_loc3_]))
               {
                  _loc2_ = this.kitchens[_loc3_];
                  break;
               }
               _loc3_++;
            }
            if(_loc2_ != null)
            {
               this.removeActor(param1);
               _loc4_ = new ChefActor(_loc2_,param1,this);
               this.chefs.push(_loc4_);
               this.addEmployeeActor(_loc4_);
               this.calculateServableTables();
               return;
            }
         }
         var _loc5_:EmployeeActor = this.getEmployeeActor(param1);
         if(_loc5_ == null || !(_loc5_ is IdleEmployee))
         {
            _loc5_ = this.addIdleActor(param1);
         }
         _loc5_.setEmotion(EmployeeActor.EMOTION_NEED_STOVE);
      }
      
      public function onButtonHireFriendsClick(param1:MouseEvent) : void
      {
         this.destroy();
         WorldHire.open();
      }
      
      public function getSortedKitchens(param1:RoomItem) : Array
      {
         var _loc2_:RoomItem = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = new Array();
         var _loc9_:int = 0;
         while(_loc9_ < this.kitchens.length)
         {
            _loc2_ = this.kitchens[_loc9_];
            _loc3_ = 1;
            _loc4_ = this.getWaitorCountForKitchen(_loc2_);
            _loc5_ = 0;
            while(_loc5_ < _loc8_.length)
            {
               _loc6_ = 1;
               _loc7_ = this.getWaitorCountForKitchen(_loc8_[_loc5_]);
               if(_loc3_ > _loc6_)
               {
                  _loc8_.splice(_loc5_,0,_loc2_);
                  break;
               }
               if(_loc3_ == _loc6_)
               {
                  if(_loc4_ < _loc7_)
                  {
                     _loc8_.splice(_loc5_,0,_loc2_);
                     break;
                  }
                  if(_loc4_ == _loc7_ && _loc2_ == param1)
                  {
                     _loc8_.splice(_loc5_,0,_loc2_);
                     break;
                  }
               }
               _loc5_++;
            }
            if(_loc5_ == _loc8_.length)
            {
               _loc8_.push(_loc2_);
            }
            _loc9_++;
         }
         return _loc8_;
      }
      
      private function getWaitorCountForKitchen(param1:RoomItem) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this.waitors.length)
         {
            if(this.waitors[_loc3_].kitchen == param1)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function onFireUser(param1:GameUserEmployee) : void
      {
         if(!this.visitMode)
         {
            this.removeActor(param1);
            this.refreshEmployeeCount();
            this.calculateServableTables();
            this.refreshRestaurantClosedState();
         }
      }
      
      public function addWaitor(param1:GameUserEmployee) : void
      {
         var _loc2_:Waitor = null;
         if(this.kitchens.length > 0)
         {
            this.removeActor(param1);
            _loc2_ = new Waitor(this.getSortedKitchens(null)[0],param1,this);
            this.waitors.push(_loc2_);
            this.addEmployeeActor(_loc2_);
            this.calculateServableTables();
            return;
         }
         var _loc3_:EmployeeActor = this.getEmployeeActor(param1);
         if(!_loc3_ || !(_loc3_ is IdleEmployee))
         {
            _loc3_ = this.addIdleActor(param1);
         }
         _loc3_.setEmotion(EmployeeActor.EMOTION_NEED_STOVE);
      }
      
      public function enablePlots() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < plots.length)
         {
            plots[_loc1_].enable(this.visitMode);
            _loc1_++;
         }
      }
      
      private function getEmployeeActor(param1:GameUserEmployee) : EmployeeActor
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.employeeActors.length)
         {
            if(this.employeeActors[_loc2_].employeeUser == param1)
            {
               return this.employeeActors[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      private function getClosestFreeWaitor(param1:int, param2:int, param3:Customer) : Object
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:Waitor = null;
         var _loc7_:int = 0;
         while(_loc7_ < this.waitors.length)
         {
            if(Boolean(this.waitors[_loc7_].isFree()) && (Boolean(param3 == null) || Boolean(this.waitors[_loc7_].canServe(param3))))
            {
               _loc4_ = this.waitors[_loc7_].getPathTo(param1,param2,true);
               if(_loc4_)
               {
                  if(_loc5_ == null || _loc4_.length < _loc5_.length)
                  {
                     _loc6_ = this.waitors[_loc7_];
                     _loc5_ = _loc4_;
                  }
               }
            }
            _loc7_++;
         }
         if(_loc6_ == null)
         {
            return null;
         }
         return {
            "waitor":_loc6_,
            "path":_loc5_
         };
      }
      
      private function onAchievementItemClick(param1:MouseEvent) : void
      {
         if(!moveGesture)
         {
            this.showAwardPopUp();
         }
      }
      
      public function onButtonPerkClick(param1:MouseEvent) : void
      {
      }
      
      public function addDemand(param1:int) : void
      {
         this.setDemand(gameUser.getDemandPoints() + param1);
      }
      
      public function createEmployeeActor(param1:GameUserEmployee) : void
      {
         var _loc2_:EmployeeActor = null;
         switch(param1.job)
         {
            case GameUserEmployee.JOB_COOK:
               this.addChef(param1);
               break;
            case GameUserEmployee.JOB_WAITOR:
               this.addWaitor(param1);
               break;
            case GameUserEmployee.JOB_CLEANER:
               this.addCleaner(param1);
               break;
            case GameUserEmployee.JOB_REST:
               this.addRestingEmployee(param1);
               break;
            case GameUserEmployee.JOB_NONE:
               _loc2_ = this.addIdleActor(param1);
               _loc2_.setEmotion(EmployeeActor.EMOTION_NEED_JOB);
         }
      }
      
      private function getValidOutsideAreaEntrances() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < numOutsideTilesY)
         {
            _loc1_ = numTilesY + _loc3_;
            if(isWalkable(1,_loc1_))
            {
               _loc2_.push(_loc1_);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function alreadyHelpedCurrentFriend() : Boolean
      {
         return GameWorld.gameUser.hasVisitedToday(gameUser);
      }
      
      public function onButtonMessageClick(param1:MouseEvent) : void
      {
         var _loc2_:WorldMail = null;
         if(GameWorld.gameUser.level.value > 0)
         {
            _loc2_ = new WorldMail();
            _loc2_.show();
         }
      }
      
      private function initDiscordButton() : void
      {
         var _loc1_:Rectangle = null;
         if(this.uiButton == null || this.buttonMessage == null)
         {
            return;
         }
         this.buttonDiscord = new MovieClip();
         this.buttonDiscord.addChild(RcDiscordIcon.createIcon(46));
         _loc1_ = this.buttonMessage.getBounds(this.uiButton);
         this.buttonDiscord.x = _loc1_.x + _loc1_.width / 2 - 68;
         this.buttonDiscord.y = _loc1_.y + _loc1_.height / 2;
         setButtonMode(this.buttonDiscord,true);
         this.buttonDiscord.toolTip = new ToolTip(this.buttonDiscord,"Join the Restaurant City Reborn Discord community!");
         this.buttonDiscord.addEventListener(MouseEvent.CLICK,this.onDiscordButtonClick,false,0,true);
         this.buttonDiscord.addEventListener(MouseEvent.ROLL_OVER,this.onDiscordButtonOver,false,0,true);
         this.buttonDiscord.addEventListener(MouseEvent.ROLL_OUT,this.onDiscordButtonOut,false,0,true);
         this.uiButton.addChild(this.buttonDiscord);
      }
      
      private function onDiscordButtonOver(param1:MouseEvent) : void
      {
         if(this.buttonDiscord)
         {
            this.buttonDiscord.scaleX = 1.1;
            this.buttonDiscord.scaleY = 1.1;
         }
      }
      
      private function onDiscordButtonOut(param1:MouseEvent) : void
      {
         if(this.buttonDiscord)
         {
            this.buttonDiscord.scaleX = 1;
            this.buttonDiscord.scaleY = 1;
         }
      }
      
      public function onDiscordButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:RcOpenDiscordPage = new RcOpenDiscordPage();
         _loc2_.show();
      }

      // Restaurant City Arquivo (2026-10-28): in-restaurant ingredient exchange.
      // The game's own trade icon, right of the market button.
      private function initOwnExchangeButton() : void
      {
         var _loc1_:Rectangle = null;
         if(this.uiButton == null || this.buttonMarket == null)
         {
            return;
         }
         this.buttonOwnExchange = new MovieClip();
         this.buttonOwnExchange.addChild(centeredIcon("TradeIcon",46,0,0));
         this.buttonOwnExchange.mouseChildren = false;
         _loc1_ = this.buttonMarket.getBounds(this.uiButton);
         this.buttonOwnExchange.x = _loc1_.x + _loc1_.width + 34;
         this.buttonOwnExchange.y = _loc1_.y + _loc1_.height / 2;
         setButtonMode(this.buttonOwnExchange,true);
         this.buttonOwnExchange.toolTip = new ToolTip(this.buttonOwnExchange,"Swap ingredients: 3 of yours for 1 new one");
         this.buttonOwnExchange.addEventListener(MouseEvent.CLICK,this.onOwnExchangeButtonClick,false,0,true);
         this.buttonOwnExchange.addEventListener(MouseEvent.ROLL_OVER,this.onOwnExchangeButtonOver,false,0,true);
         this.buttonOwnExchange.addEventListener(MouseEvent.ROLL_OUT,this.onOwnExchangeButtonOut,false,0,true);
         this.uiButton.addChild(this.buttonOwnExchange);
      }

      private static function centeredIcon(param1:String, param2:Number, param3:Number, param4:Number) : MovieClip
      {
         var _loc5_:MovieClip = Engine.getMovieClip(param1);
         _loc5_.gotoAndStop(1);
         _loc5_.mouseEnabled = false;
         var _loc6_:Rectangle = _loc5_.getBounds(_loc5_);
         _loc5_.scaleX = param2 / Math.max(_loc6_.width,_loc6_.height);
         _loc5_.scaleY = _loc5_.scaleX;
         _loc5_.x = param3 - (_loc6_.left + _loc6_.width / 2) * _loc5_.scaleX;
         _loc5_.y = param4 - (_loc6_.top + _loc6_.height / 2) * _loc5_.scaleY;
         return _loc5_;
      }

      private function onOwnExchangeButtonOver(param1:MouseEvent) : void
      {
         if(this.buttonOwnExchange)
         {
            this.buttonOwnExchange.scaleX = 1.1;
            this.buttonOwnExchange.scaleY = 1.1;
         }
      }

      private function onOwnExchangeButtonOut(param1:MouseEvent) : void
      {
         if(this.buttonOwnExchange)
         {
            this.buttonOwnExchange.scaleX = 1;
            this.buttonOwnExchange.scaleY = 1;
         }
      }

      public function onOwnExchangeButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:WorldTradePanel = new WorldTradePanel(GameWorld.gameUser,false,true);
         _loc2_.show();
      }
      
      private function onTrashMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:BaseObject = BaseObject(param1.currentTarget);
         _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onTrashMouseDown);
         room.removeObject(_loc2_);
         var _loc3_:GameObject = GameObject(_loc2_.trashObject);
         this.removeTrashObject(_loc3_);
         param1.stopImmediatePropagation();
      }
      
      override public function onLevelUp(param1:GameEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ChefActor = null;
         var _loc4_:int = GameWorld.gameUser.level.value;
         if(GameWorld.LEVEL_THRESHOLDS[_loc4_].roomSizeY > GameWorld.LEVEL_THRESHOLDS[_loc4_ - 1].roomSizeY)
         {
            _loc2_ = 0;
            while(_loc2_ < this.chefs.length)
            {
               _loc3_ = this.chefs[_loc2_];
               if(isTileInOutsideArea(_loc3_.tileX,_loc3_.tileY))
               {
                  _loc3_.setPosition(getScreenX(_loc3_.tileX,_loc3_.tileY + 1),getScreenY(_loc3_.tileX,_loc3_.tileY + 1));
               }
               _loc2_++;
            }
         }
         super.onLevelUp(param1);
         this.refreshEmployeeCount();
         if(this.levelBar)
         {
            this.levelBar.refresh();
         }
      }
      
      private function getWaiterForDrinkOrder(param1:DishOrder) : Object
      {
         var _loc2_:Waitor = null;
         var _loc3_:int = 0;
         var _loc4_:RoomItem = null;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         if(this.drinkItems.length <= 0)
         {
            return null;
         }
         var _loc7_:Array = null;
         var _loc8_:Waitor = null;
         var _loc9_:RoomItem = null;
         var _loc10_:Customer = param1.customer;
         var _loc11_:int = 0;
         while(_loc11_ < this.waitors.length)
         {
            _loc2_ = this.waitors[_loc11_];
            if(_loc2_.isFree() && _loc2_.canServe(_loc10_))
            {
               _loc3_ = 0;
               while(_loc3_ < this.drinkItems.length)
               {
                  _loc4_ = this.drinkItems[_loc3_];
                  if(!_loc4_.waiter && _loc2_.canReachDrinkItem(_loc4_))
                  {
                     _loc5_ = getFacingTile(_loc4_.tileX,_loc4_.tileY,_loc4_.getRotationCount());
                     if(isWalkable(_loc5_.x,_loc5_.y))
                     {
                        _loc6_ = _loc2_.getPathTo(_loc5_.x,_loc5_.y,false);
                        if(Boolean(_loc6_) && (_loc7_ == null || _loc6_.length < _loc7_.length))
                        {
                           _loc8_ = _loc2_;
                           _loc7_ = _loc6_;
                           _loc9_ = _loc4_;
                        }
                     }
                  }
                  _loc3_++;
               }
            }
            _loc11_++;
         }
         if(_loc8_ == null)
         {
            return null;
         }
         return {
            "waitor":_loc8_,
            "path":_loc7_,
            "drinkItem":_loc9_
         };
      }
      
      public function getPlayingMusicForUser(param1:GameUser) : UserItem
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(param1.musicId > 0)
         {
            _loc2_ = GameWorld.interiorItemDatabase.getItemFromGroupWithId(param1.musicId,"Music");
            if(Boolean(_loc2_) && _loc2_.cost > 0)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.musicItems.length)
               {
                  if(param1.musicItems[_loc3_].itemConfig.id == param1.musicId)
                  {
                     break;
                  }
                  _loc3_++;
               }
               if(_loc3_ >= param1.musicItems.length)
               {
                  _loc2_ = null;
               }
            }
         }
         if(_loc2_ == null)
         {
            _loc2_ = GameWorld.interiorItemDatabase.getItems("Music")[1];
         }
         return new UserItem(_loc2_);
      }
      
      public function getPathToCustomer(param1:int, param2:int, param3:Customer) : Array
      {
         var _loc4_:RoomItem = param3.chair;
         var _loc5_:Object = getFacingTile(_loc4_.tileX,_loc4_.tileY,_loc4_.getRotationCount());
         var _loc6_:PathFinder = new PathFinder(param1,param2,_loc5_.x,_loc5_.y,this,true);
         var _loc7_:int = _loc6_.processOpenList(-1);
         if(_loc7_ == PathFinder.PROCESS_STATE_NO_PATH)
         {
            _loc6_ = new PathFinder(param1,param2,_loc4_.tileX,_loc4_.tileY,this,true);
            _loc7_ = _loc6_.processOpenList(-1);
         }
         if(_loc7_ == PathFinder.PROCESS_STATE_FOUND)
         {
            return _loc6_.getFinalPath();
         }
         return null;
      }
      
      private function getNextCustomer(param1:int, param2:int) : Customer
      {
         var _loc3_:Customer = null;
         var _loc4_:GameUser = null;
         var _loc5_:int = 0;
         Debug.out("cachedCustomerUsers=" + cachedCustomerUsers.length + " customers.length=" + this.customers.length);
         if(Engine.rnd(0,20) == 0)
         {
            _loc4_ = this.getRandomFreeFriendUser();
            if(_loc4_)
            {
               _loc4_.employerUser = null;
               _loc3_ = new Customer(param1,param2,_loc4_,this);
            }
         }
         if(_loc3_ == null)
         {
            if(cachedCustomerUsers.length > 0 && cachedCustomerUsers.length + this.customers.length >= NUM_CACHED_CUSTOMERS)
            {
               _loc5_ = Engine.rnd(0,cachedCustomerUsers.length);
               _loc3_ = new Customer(param1,param2,cachedCustomerUsers[_loc5_],this);
               cachedCustomerUsers.splice(_loc5_,1);
            }
            else
            {
               _loc3_ = new Customer(param1,param2,new GameUser(null),this);
            }
         }
         return _loc3_;
      }
      
      private function onButtonGiftInviteClick(param1:MouseEvent) : void
      {
         var _loc2_:GiftInviteFoodPopUp = new GiftInviteFoodPopUp();
         _loc2_.show();
         GameWorld.setFirstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_GIFT_INVITE_FOOD);
         if(this.uiButton.mc_gift)
         {
            this.uiButton.mc_gift.mc_new.visible = false;
         }
      }
      
      public function removeCustomer(param1:Customer) : void
      {
         param1.hide();
         room.removeObject(param1);
         var _loc2_:int = this.customers.indexOf(param1);
         if(_loc2_ != -1)
         {
            this.customers.splice(_loc2_,1);
         }
         if(param1.user.userInfo == null)
         {
            cachedCustomerUsers.push(param1.user);
         }
         else
         {
            param1.destroy();
         }
      }
      
      public function onCustomerPay(param1:DishOrder) : void
      {
         if(gameUser == GameWorld.gameUser)
         {
            GameWorld.cashPanel.addCoins(param1.recipe.cost);
            GameWorld.saveProfileHandler.addPaidMeal(param1.recipe.cost);
            this.addGourmetPoints(GameWorld.GOURMET_POINTS_PER_DISH + GameWorld.GOURMET_POINTS_PER_DISH_LEVEL * (param1.recipe.level - 1));
         }
      }
      
      public function getPathToRandomRoomItem(param1:RestaurantActor, param2:Array) : Object
      {
         var _loc3_:PathFinder = null;
         var _loc4_:RandomBasket = new RandomBasket();
         _loc4_.addItemArray(param2);
         var _loc5_:RoomItem = null;
         while(true)
         {
            _loc5_ = RoomItem(_loc4_.getNextItem());
            if(!_loc5_)
            {
               break;
            }
            _loc3_ = new PathFinder(param1.tileX,param1.tileY,_loc5_.tileX,_loc5_.tileY,this);
            if(_loc3_.processOpenList(-1) == PathFinder.PROCESS_STATE_FOUND)
            {
               return {
                  "item":_loc5_,
                  "path":_loc3_.getFinalPath()
               };
            }
         }
         return null;
      }
      
      private function moveClosestFreeWaitorToCookedOrder(param1:DishOrder) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:Object = this.getClosestFreeWaitor(param1.kitchen.tileX,param1.kitchen.tileY,param1.customer);
         if(_loc6_ != null)
         {
            _loc6_.path.pop();
            if(_loc6_.path.length > 0)
            {
               _loc5_ = _loc6_.path[_loc6_.path.length - 1];
               _loc2_ = int(_loc5_[0]);
               _loc3_ = int(_loc5_[1]);
            }
            else
            {
               _loc2_ = int(_loc6_.waitor.tileX);
               _loc3_ = int(_loc6_.waitor.tileY);
            }
            _loc4_ = this.getPathToCustomer(_loc2_,_loc3_,param1.customer);
            if(_loc4_ != null)
            {
               _loc6_.waitor.getOrderFromKitchen(param1,_loc6_.path,_loc4_);
               return true;
            }
         }
         return false;
      }
      
      public function onButtonStreetClick(param1:MouseEvent) : void
      {
         this.destroy();
         GameWorld.fadeToWorld(new WorldStreet(gameUser,false,true));
      }
      
      private function showMusicStore() : void
      {
         var _loc1_:WorldMusicShopPopUp = null;
         if(!this.visitMode)
         {
            GameWorld.setFirstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_MUSIC_PLAYER);
            if(this.uiButton.buttonMusicPlayer)
            {
               this.uiButton.buttonMusicPlayer.mc_new.visible = false;
            }
            _loc1_ = new WorldMusicShopPopUp(this);
            _loc1_.show();
         }
      }
      
      private function getPath(param1:int, param2:int, param3:int, param4:int) : Array
      {
         var _loc5_:PathFinder = new PathFinder(param1,param2,param3,param4,this,true);
         if(_loc5_.processOpenList(-1) == PathFinder.PROCESS_STATE_FOUND)
         {
            return null;
         }
         return null;
      }
      
      private function onMailItemClick(param1:MouseEvent) : void
      {
         if(!moveGesture)
         {
            if(this.visitMode)
            {
               this.onButtonWriteMessageClick(null);
            }
            else
            {
               this.onButtonMessageClick(null);
            }
         }
      }
      
      private function onPerksClicked(param1:MouseEvent) : void
      {
      }
      
      public function onMoveDebugPlayer(param1:MouseEvent) : void
      {
         var _loc2_:int = getTileIndexX(room.mouseX,room.mouseY);
         var _loc3_:int = getTileIndexY(room.mouseX,room.mouseY);
         this.debugPlayer.moveTo(getScreenX(_loc2_,_loc3_),getScreenY(_loc2_,_loc3_));
      }
      
      override public function showNotify() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:WorldPopUp = null;
         var _loc5_:WorldEarningPopUp = null;
         var _loc6_:int = getTimer();
         PerfTrace.mark("WorldRestaurantPlay.showNotify begin visitMode=" + this.visitMode);
         super.showNotify();
         instance = this;
         if(this.visitMode)
         {
            _loc6_ = getTimer();
            this.curFriendsList.y = Engine.getStageBottom();
            addObject(this.curFriendsList);
            this.curFriendsList.addEventListener(FriendListEvent.USER_CLICKED,this.onFriendListUserClicked,false,0,true);
            PerfTrace.slow("WorldRestaurantPlay.showNotify friends list",_loc6_,5);
         }
         else
         {
            _loc6_ = getTimer();
            GameWorld.hiredFriendsPanel.y = Engine.getStageBottom();
            GameWorld.hiredFriendsPanel.refreshInviteIcons();
            addObject(GameWorld.hiredFriendsPanel);
            PerfTrace.slow("WorldRestaurantPlay.showNotify hired panel",_loc6_,5);
         }
         _loc6_ = getTimer();
         addObject(GameWorld.cashPanel);
         this.restoreHudLayers();
         PerfTrace.slow("WorldRestaurantPlay.showNotify hud/cash",_loc6_,5);
         _loc6_ = getTimer();
         this.playBgMusic(this.getPlayingMusicForUser(gameUser).itemConfig);
         PerfTrace.slow("WorldRestaurantPlay.showNotify bg music",_loc6_,5);
         this.silentTick = true;
         var _loc7_:int = 1;
         var _loc8_:int = 250;
         var _loc9_:Number = 0;
         _loc6_ = getTimer();
         while(_loc9_ < _loc7_)
         {
            tickBase(_loc8_);
            _loc9_++;
         }
         PerfTrace.slow("WorldRestaurantPlay.showNotify warmup ticks " + _loc7_,_loc6_,5);
         this.silentTick = false;
         _loc6_ = getTimer();
         this.displayGameStartUpPopUps();
         PerfTrace.slow("WorldRestaurantPlay.showNotify startup popups",_loc6_,5);
         if(firstVisitIngredientReward != null)
         {
            _loc6_ = getTimer();
            _loc1_ = Engine.getMovieClip("FirstFriendVisitBonusAnim");
            _loc2_ = _loc1_.mc_content;
            GameWorld.textHandler.setTextFieldWithId(_loc2_.tf_title,"FirstFriendVisitBonus");
            GameWorld.textHandler.setTextFieldWithId(_loc2_.tf_ingredient,"IngredientBonus");
            _loc3_ = Engine.getMovieClip(firstVisitIngredientReward.itemConfig.className);
            _loc3_.stop();
            _loc2_.mc_icon.removeChildAt(0);
            _loc2_.mc_icon.addChild(_loc3_);
            _loc2_.mc_rarity.gotoAndStop(firstVisitIngredientReward.rarity);
            _loc2_.tf_name.text = firstVisitIngredientReward.itemConfig.name;
            setButtonMode(_loc1_.mc_tick,true);
            _loc4_ = new WorldPopUp(_loc1_,_loc2_.mc_tick,null);
            _loc4_.show();
            firstVisitIngredientReward = null;
            PerfTrace.slow("WorldRestaurantPlay.showNotify first visit reward",_loc6_,5);
         }
         if(this.visitMode && WorldStreet.streetType == WorldStreet.STREET_TYPE_FRIENDS)
         {
            GameWorld.addAwardValue(GameAwards.AWARD_VISIT,1);
         }
         if(!this.visitMode)
         {
            _loc6_ = getTimer();
            GameWorld.tickOfflineTime();
            GameWorld.offlineEarningTimer = -1;
            GameWorld.settingOverlay.showSaveButton();
            if(GameWorld.offlineEarning > 0)
            {
               _loc5_ = new WorldEarningPopUp(GameWorld.offlineEarning,GameWorld.offlineGourmetPoints);
               _loc5_.y = canvasHeight / 2;
               _loc5_.queueToShow();
            }
            GameWorld.offlineEarning = 0;
            GameWorld.offlineGourmetPoints = 0;
            GameWorld.checkLevelUp();
            PerfTrace.slow("WorldRestaurantPlay.showNotify owner rewards",_loc6_,5);
         }
         _loc6_ = getTimer();
         Engine.instance.stage.addEventListener(Event.FULLSCREEN,this.onFullScreen,false,0,true);
         this.onFullScreen(null);
         PerfTrace.slow("WorldRestaurantPlay.showNotify fullscreen/layout",_loc6_,5);
         if(FoodKingPopUp.blackSheepItems.length > 0)
         {
            _loc6_ = getTimer();
            this.foodKing = new FoodKing(this,null);
            this.foodKing.addToRestaurant();
            PerfTrace.slow("WorldRestaurantPlay.showNotify food king",_loc6_,5);
         }
         PerfTrace.mark("WorldRestaurantPlay.showNotify end");
      }
      
      public function displayGameStartUpPopUps() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:MovieClip = null;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:DailyBonusPopUp = null;
         var _loc6_:int = 0;
         var _loc7_:FoodKingItem = null;
         var _loc8_:WorldPopUp = null;
         var _loc9_:int = 0;
         var _loc10_:Mail = null;
         var _loc11_:MailItem = null;
         var _loc12_:SpecialDayPresentMail = null;
         var _loc13_:GameStartMessageMail = null;
         var _loc14_:MailItem = null;
         var _loc15_:NewspaperMail = null;
         if(!this.visitMode && gameUser.level.value > 0)
         {
            if(dailyIngredientMail != null || Boolean(DebugDailyBonus.daysLoggedInARow))
            {
               _loc5_ = new DailyBonusPopUp(dailyIngredientMail);
               _loc5_.queueToShow();
               if(!DebugDailyBonus.daysLoggedInARow)
               {
                  GameWorld.saveProfileHandler.addDeletedMail(dailyIngredientMail);
                  dailyIngredientMail = null;
               }
            }
            if(GameWorld.receivedFeedItems != null)
            {
               _loc6_ = 0;
               while(_loc6_ < GameWorld.receivedFeedItems.length)
               {
                  _loc7_ = GameWorld.receivedFeedItems[_loc6_];
                  if(_loc7_.mailType == RpcClient.MAIL_FOOD_KING_ITEM)
                  {
                     _loc1_ = Engine.getMovieClip("BlackSheepRewardPopupAnim");
                  }
                  else
                  {
                     _loc1_ = Engine.getMovieClip("GenericRewardPopupAnim");
                  }
                  _loc2_ = _loc1_.mc_content;
                  _loc8_ = new FoodKingRewardPopUp(_loc7_,_loc1_,_loc2_.mc_skip,null);
                  _loc8_.queueToShow();
                  _loc6_++;
               }
               GameWorld.receivedFeedItems = null;
            }
            if(GameWorld.invalidFeedItems != null)
            {
               _loc9_ = 0;
               while(_loc9_ < GameWorld.invalidFeedItems.length)
               {
                  _loc10_ = GameWorld.invalidFeedItems[_loc9_];
                  if(_loc10_.type == RpcClient.FOOD_KING_FEED_EXCEPTION)
                  {
                     _loc1_ = Engine.getMovieClip("BlackSheepRewardPopupAnim");
                  }
                  else
                  {
                     _loc1_ = Engine.getMovieClip("GenericRewardPopupAnim");
                  }
                  _loc2_ = _loc1_.mc_content;
                  GameWorld.textHandler.setTextFieldWithId(_loc2_.tf_text,_loc10_.message,true);
                  _loc2_.tf_text.mouseEnabled = true;
                  _loc2_.mc_rarity.stop();
                  _loc2_.mc_rarity.visible = false;
                  _loc2_.tf_name.visible = false;
                  _loc2_.mc_share.stop();
                  _loc2_.mc_share.visible = false;
                  _loc2_.mc_item.stop();
                  _loc2_.mc_item.visible = false;
                  _loc2_.mc_share.stop();
                  _loc2_.mc_share.visible = false;
                  _loc2_.tf_shareText.visible = false;
                  _loc2_.mc_skip.stop();
                  _loc2_.mc_skip.visible = false;
                  _loc2_.mc_share.stop();
                  _loc2_.mc_share.visible = false;
                  _loc8_ = new WorldPopUp(_loc1_,_loc2_.mc_tick,null);
                  _loc8_.queueToShow();
                  _loc9_++;
               }
               GameWorld.invalidFeedItems = null;
            }
            if(specialDayPresentMails != null)
            {
               for each(_loc11_ in specialDayPresentMails)
               {
                  if(_loc11_.mailObject.globalItemIds[0] > 0)
                  {
                     _loc12_ = new SpecialDayPresentMail(_loc11_,null);
                     _loc12_.queueToShow();
                  }
                  else
                  {
                     _loc13_ = new GameStartMessageMail(_loc11_);
                     _loc13_.queueToShow();
                  }
                  GameWorld.saveProfileHandler.addDeletedMail(_loc11_);
               }
               specialDayPresentMails = null;
            }
            _loc3_ = gameUser.getNewMailItems();
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc14_ = _loc3_[_loc4_];
               if(_loc14_.newsletterId != -1 && !_loc14_.mailObject.read)
               {
                  _loc15_ = new NewspaperMail(_loc14_,null);
                  _loc15_.queueToShow();
               }
               _loc4_++;
            }
         }
      }
      
      public function getModifiedOperateTime(param1:RoomItem, param2:int) : int
      {
         if(param1.operateTimePercentage != 100)
         {
            param2 *= param1.operateTimePercentage / 100;
         }
         return param2;
      }
      
      private function onItemWithInfoTextClick(param1:MouseEvent) : void
      {
         var _loc2_:RoomItem = null;
         var _loc3_:WorldItemInfoPopUp = null;
         if(!moveGesture)
         {
            _loc2_ = RoomItem(param1.currentTarget);
            if(this.visitMode || !_loc2_.isBroken())
            {
               _loc3_ = new WorldItemInfoPopUp(_loc2_.itemConfig,gameUser);
               _loc3_.show();
            }
         }
      }
      
      private function showIngredientShop() : void
      {
         var _loc1_:WorldIngredientShopPopUp = null;
         if(GameWorld.gameUser.level.value >= GameWorld.INGREDIENT_MARKET_UNLOCK_LEVEL)
         {
            GameWorld.setFirstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_INGRADIANT_SHOP);
            if(this.uiButton.buttonMarket)
            {
               this.uiButton.buttonMarket.mc_new.visible = false;
            }
            _loc1_ = new WorldIngredientShopPopUp();
            _loc1_.show();
         }
      }
      
      public function hasTrash() : Boolean
      {
         var _loc1_:int = numTilesX * numTilesY;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(this.trashMap[_loc2_])
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function addEmployeeActor(param1:EmployeeActor) : void
      {
         var employeeActor:EmployeeActor = null;
         employeeActor = param1;
         room.addObject(employeeActor);
         this.employeeActors.push(employeeActor);
         employeeActor.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            onActorClicked(employeeActor);
         });
      }
      
      public function getEmptyChairs(param1:Boolean, param2:Boolean, param3:DishOrder) : Array
      {
         var _loc4_:RoomItem = null;
         var _loc5_:RoomItem = null;
         var _loc6_:Array = new Array();
         var _loc7_:int = 0;
         while(_loc7_ < this.chairs.length)
         {
            _loc4_ = this.chairs[_loc7_];
            if(!_loc4_.toilet && _loc4_.customer == null)
            {
               if(!param1)
               {
                  _loc6_.push(_loc4_);
               }
               else if(this.canChairOrder(_loc4_,param3))
               {
                  _loc5_ = getTableForChair(_loc4_);
                  if(_loc5_ != null)
                  {
                     if(param2)
                     {
                        if(isTableFree(_loc5_) && _loc5_.rcrLugarLivre(_loc4_))
                        {
                           _loc6_.push(_loc4_);
                        }
                     }
                     else
                     {
                        _loc6_.push(_loc4_);
                     }
                  }
               }
            }
            _loc7_++;
         }
         return _loc6_;
      }
      
      public function createOrderForCustomer(param1:Customer) : void
      {
         var _loc2_:int = 0;
         if(gameUser.level.value >= GameWorld.DRINK_START_LEVEL)
         {
            _loc2_ = Engine.rnd(0,Recipe.NUM_MENU_RECIPE_TYPE);
         }
         else
         {
            _loc2_ = Engine.rnd(0,Recipe.NUM_MENU_RECIPE_TYPE - 1);
         }
         var _loc3_:Array = gameUser.getSelectedRecipes(_loc2_);
         var _loc4_:int = Engine.rnd(0,_loc3_.length);
         var _loc5_:DishOrder = new DishOrder(_loc3_[_loc4_]);
         _loc5_.customer = param1;
         param1.order = _loc5_;
      }
      
      public function addCoin(param1:Number, param2:Number, param3:int) : void
      {
         var _loc4_:Coin = null;
         GameWorld.cashPanel.addCoins(param3);
         var _loc5_:Number = 0;
         while(_loc5_ < param3)
         {
            _loc4_ = new Coin(param1,param2,this);
            room.addObject(_loc4_);
            _loc5_++;
         }
      }
      
      private function getBestFreeChef(param1:DishOrder) : ChefActor
      {
         var _loc2_:ChefActor = null;
         var _loc3_:ChefActor = null;
         var _loc4_:int = -1;
         var _loc5_:int = 0;
         while(_loc5_ < this.chefs.length)
         {
            _loc3_ = this.chefs[_loc5_];
            if(_loc3_.isFree() && _loc3_.canServe(param1.customer) && _loc3_.employeeUser.workTime > _loc4_)
            {
               _loc2_ = _loc3_;
               _loc4_ = _loc3_.employeeUser.workTime;
            }
            _loc5_++;
         }
         return _loc2_;
      }
      
      public function addCleaner(param1:GameUserEmployee) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:RoomItem = null;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:RoomItem = null;
         var _loc10_:Array = null;
         var _loc11_:RoomItem = null;
         var _loc12_:Array = null;
         this.removeActor(param1);
         var _loc13_:RandomBasket = new RandomBasket();
         _loc13_.addItemArray(this.getToiletSeats());
         while(true)
         {
            _loc4_ = RoomItem(_loc13_.getNextItem());
            if(!_loc4_)
            {
               _loc6_ = this.getEmployeeActorFreeTiles();
               if(_loc6_.length > 0)
               {
                  _loc7_ = int(_loc6_[Engine.rnd(0,_loc6_.length)]);
                  _loc2_ = getTileXFromTileIndex(_loc7_);
                  _loc3_ = getTileYFromTileIndex(_loc7_);
               }
               else
               {
                  _loc2_ = Engine.rnd(-4,-1);
                  _loc3_ = Engine.rnd(1,numTilesY);
               }
               break;
            }
            _loc5_ = getFacingTile(_loc4_.tileX,_loc4_.tileY,_loc4_.getRotationCount());
            if(isWalkable(_loc5_.x,_loc5_.y))
            {
               _loc2_ = int(_loc5_.x);
               _loc3_ = int(_loc5_.y);
               break;
            }
         }
         var _loc14_:CleanerEmployee = new CleanerEmployee(_loc2_,_loc3_,param1,this);
         this.cleaners.push(_loc14_);
         this.addEmployeeActor(_loc14_);
         if(_loc2_ > 0 && _loc3_ > 0)
         {
            _loc8_ = 0;
            while(_loc8_ < this.chairs.length)
            {
               _loc9_ = this.chairs[_loc8_];
               if(_loc9_.toilet)
               {
                  _loc10_ = _loc14_.getPathTo(_loc9_.tileX,_loc9_.tileY,false);
                  if(_loc10_ != null)
                  {
                     _loc14_.reachableToiletSeats.push(_loc9_);
                  }
               }
               _loc8_++;
            }
            _loc8_ = 0;
            while(_loc8_ < this.interactiveItems.length)
            {
               _loc11_ = this.interactiveItems[_loc8_];
               _loc12_ = _loc14_.getPathTo(_loc11_.tileX,_loc11_.tileY,false);
               if(_loc12_ != null)
               {
                  _loc14_.reachableFunctionalItems.push(_loc11_);
               }
               _loc8_++;
            }
         }
      }
      
      override public function addGourmetPoints(param1:Number) : void
      {
         super.addGourmetPoints(param1);
         var _loc2_:GameObject = new GameObject("GourmetPointAdded");
         var _loc3_:int = Math.floor(param1 * 10) % 10;
         var _loc4_:String = "+" + Math.floor(param1);
         if(_loc3_ != 0)
         {
            _loc4_ += "." + _loc3_;
         }
         _loc2_.getChildMovieClipInstance("mc_content").tf_amount.text = _loc4_;
         _loc2_.y += Engine.getStageY();
         _loc2_.drawPriority = SCORE_POPUP_PRIORITY;
         _loc2_.numLoops = 1;
         _loc2_.removeWhenComplete = true;
         Engine.worldContainer.addObject(_loc2_);
         if(this.levelBar)
         {
            this.levelBar.refresh();
         }
      }
      
      public function addRandomTrash() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:RandomBasket = new RandomBasket();
         var _loc7_:int = 0;
         while(_loc7_ < numTilesY)
         {
            _loc1_ = 0;
            while(_loc1_ < numTilesX)
            {
               _loc2_ = getTileIndex(_loc1_,_loc7_);
               if(!this.trashMap[_loc2_] && isWalkable(_loc1_,_loc7_) && !wallMap[_loc2_])
               {
                  _loc6_.addItems(_loc2_);
               }
               _loc1_++;
            }
            _loc7_++;
         }
         _loc7_ = numTilesY;
         while(_loc7_ < numTilesY + numOutsideTilesY)
         {
            _loc1_ = 1;
            while(_loc1_ < numTilesX)
            {
               _loc2_ = getTileIndex(_loc1_,_loc7_);
               if(!this.trashMap[_loc2_] && isWalkable(_loc1_,_loc7_))
               {
                  _loc6_.addItems(_loc2_);
               }
               _loc1_++;
            }
            _loc7_++;
         }
         if(_loc6_.length() > 0)
         {
            _loc3_ = int(_loc6_.getNextItem());
            _loc4_ = getTileXFromTileIndex(_loc3_);
            _loc5_ = getTileYFromTileIndex(_loc3_);
            if(this.trashItems.length == 0)
            {
               this.trashItems = DEFAULT_TRASH_ITEMS;
            }
            this.addTrashObject(this.trashItems[Engine.rnd(0,this.trashItems.length)],_loc4_,_loc5_);
         }
      }
      
      private function addIdleActor(param1:GameUserEmployee) : EmployeeActor
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.removeActor(param1);
         var _loc5_:Array = this.getEmployeeActorFreeTiles();
         if(_loc5_.length > 0)
         {
            _loc4_ = int(_loc5_[Engine.rnd(0,_loc5_.length)]);
            _loc2_ = getTileXFromTileIndex(_loc4_);
            _loc3_ = getTileYFromTileIndex(_loc4_);
         }
         else
         {
            _loc2_ = Engine.rnd(-4,-1);
            _loc3_ = Engine.rnd(1,numTilesY);
         }
         var _loc6_:int = getScreenX(_loc2_,_loc3_);
         var _loc7_:int = getScreenY(_loc2_,_loc3_);
         var _loc8_:IdleEmployee = new IdleEmployee(_loc6_,_loc7_,param1,this);
         this.addEmployeeActor(_loc8_);
         return _loc8_;
      }
      
      public function onCustomerPayForFunctional(param1:RoomItem) : void
      {
         var _loc2_:GameObject = null;
         if(gameUser == GameWorld.gameUser)
         {
            GameWorld.cashPanel.addCoins(GameWorld.COINS_PAYOUT_FUNCTIONAL_ITEMS);
            GameWorld.saveProfileHandler.addPaidFunctional(GameWorld.COINS_PAYOUT_FUNCTIONAL_ITEMS);
            this.addGourmetPoints(GameWorld.GOURMET_POINTS_PER_FUNCTIONAL_ITEM_PAYOUT);
            _loc2_ = new GameObject("MoneyFunctional");
            _loc2_.getChildMovieClipInstance("mc_money").tf_money.text = "$" + GameWorld.GOURMET_POINTS_PER_FUNCTIONAL_ITEM_PAYOUT;
            _loc2_.x = param1.x;
            _loc2_.y = param1.y;
            _loc2_.drawPriority = SCORE_POPUP_PRIORITY;
            _loc2_.numLoops = 1;
            _loc2_.removeWhenComplete = true;
            room.addObject(_loc2_);
            if(!this.silentTick)
            {
               this.cashSound.play(1);
            }
         }
      }
      
      public function refreshRestaurantClosedState() : void
      {
         var _loc1_:Boolean = this.restaurantClosed;
         this.restaurantClosed = gameUser.isRestaurantClosed();
         if(!this.visitMode)
         {
            this.uiPopularity.mc_closed.visible = this.restaurantClosed;
            if(!this.restaurantClosed)
            {
               this.showRestaurantClosedToolTip = false;
            }
            else if(gameUser.level.value > 0 && !_loc1_)
            {
               this.showRestaurantClosedToolTip = true;
            }
         }
         Debug.out("restaurantClosed=" + this.restaurantClosed);
      }
      
      public function getDoorState(param1:RoomItem) : String
      {
         var _loc2_:MovieClip = param1.getChildMovieClipInstance("mc_content");
         if(_loc2_)
         {
            return _loc2_.currentLabel;
         }
         return null;
      }
      
      public function getEmptySinks() : Array
      {
         var _loc1_:RoomItem = null;
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this.sinks.length)
         {
            _loc1_ = this.sinks[_loc3_];
            if(_loc1_.customer == null)
            {
               _loc2_.push(_loc1_);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function getEmptyToiletSeats() : Array
      {
         var _loc1_:RoomItem = null;
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this.chairs.length)
         {
            _loc1_ = this.chairs[_loc3_];
            if(_loc1_.customer == null && _loc1_.toilet && !_loc1_.isBroken())
            {
               _loc2_.push(_loc1_);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function onChefFinishOrder(param1:ChefActor) : void
      {
         this.completedOrders.push(param1.cookingOrder);
         param1.cookingOrder = null;
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         this.zoomLever.setZoomLevel(ZoomLever.zoomLevel - param1.delta / Math.abs(param1.delta),false);
      }
      
      public function onButtonAvatarClick(param1:MouseEvent) : void
      {
         this.destroy();
         GameWorld.fadeToWorld(new WorldCustomiseAvatar(GameWorld.gameUser,GameWorld.gameUser));
      }
      
      private function onIngredientShopClick(param1:MouseEvent) : void
      {
         if(!moveGesture)
         {
            this.showIngredientShop();
         }
      }
      
      public function getPathToRandomInteractiveItem(param1:RestaurantActor, param2:Array) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:PathFinder = null;
         var _loc5_:RandomBasket = new RandomBasket();
         _loc5_.addItemArray(param2);
         var _loc6_:RoomItem = null;
         while(true)
         {
            _loc6_ = RoomItem(_loc5_.getNextItem());
            if(!_loc6_)
            {
               break;
            }
            _loc3_ = getInteractiveItemUserTile(_loc6_);
            if(isWalkable(_loc3_.x,_loc3_.y))
            {
               _loc4_ = new PathFinder(param1.tileX,param1.tileY,_loc3_.x,_loc3_.y,this);
               if(_loc4_.processOpenList(-1) == PathFinder.PROCESS_STATE_FOUND)
               {
                  return {
                     "item":_loc6_,
                     "path":_loc4_.getFinalPath()
                  };
               }
            }
         }
         return null;
      }
      
      public function hasPathToCustomerChair(param1:int, param2:int, param3:RoomItem) : Boolean
      {
         var _loc4_:Object = getFacingTile(param3.tileX,param3.tileY,param3.getRotationCount());
         var _loc5_:PathFinder = new PathFinder(param1,param2,_loc4_.x,_loc4_.y,this,true);
         var _loc6_:int = _loc5_.processOpenList(-1);
         if(_loc6_ == PathFinder.PROCESS_STATE_NO_PATH)
         {
            _loc5_ = new PathFinder(param1,param2,param3.tileX,param3.tileY,this,true);
            _loc6_ = _loc5_.processOpenList(-1);
         }
         return _loc6_ == PathFinder.PROCESS_STATE_FOUND;
      }
      
      public function refreshDemand() : void
      {
         if(this.uiPopularity)
         {
            this.uiPopularity.mc_popularity.tf_demand.text = (gameUser.getDemandPoints() / 10).toFixed(1) + " / " + this.maxDemand / 10;
         }
      }
      
      public function playBgMusic(param1:Object) : void
      {
         if(param1.id != this.bgMusicId)
         {
            if(this.bgMusic != null)
            {
               this.bgMusic.stop();
               this.bgMusic = null;
            }
            if(Boolean(param1.className) && param1.className.length > 0)
            {
               this.bgMusic = new GameSound(param1.className,GameSound.TYPE_MUSIC);
               this.bgMusic.play(-1);
            }
            this.bgMusicId = param1.id;
         }
      }
      
      public function openDoor(param1:RoomItem) : void
      {
         var _loc2_:String = null;
         var _loc3_:MovieClip = param1.getChildMovieClipInstance("mc_content");
         if(_loc3_)
         {
            _loc2_ = this.getDoorState(param1);
            if(_loc2_ == "closing" || _loc2_ == "closed")
            {
               this.setRoomItemState(param1,"opening");
            }
            param1.doorTimer = 1500;
         }
      }
      
      private function onFullScreen(param1:Event) : void
      {
         if(this.visitMode)
         {
            this.curFriendsList.y = Engine.getStageBottom();
            this.uiVisitBanner.x = Engine.getStageRight();
            this.uiVisitBanner.y = Engine.getStageY();
         }
         else
         {
            GameWorld.hiredFriendsPanel.y = Engine.getStageBottom();
            this.uiPopularity.x = Engine.getStageRight();
            this.uiPopularity.y = Engine.getStageY();
         }
         this.uiButton.y = Engine.getStageBottom();
         this.uiButton.mc_zoom.x = Engine.getStageRight() - 16;
         this.uiLevelBar.y = Engine.getStageY();
         this.buttonGift.x = Engine.getStageX() + this.buttonGift.width / 2;
         if(this.buttonBookmark != null)
         {
            this.buttonBookmark.x = Engine.getStageX() + this.buttonBookmark.width / 2;
         }
         this.restoreHudLayers();
      }
      
      private function restoreHudLayers() : void
      {
         if(buttonLayer)
         {
            buttonLayer.visible = true;
            buttonLayer.alpha = 1;
            buttonLayer.drawPriority = 20000;
         }
         if(this.uiButton)
         {
            this.uiButton.visible = true;
            this.uiButton.alpha = 1;
            this.uiButton.y = Engine.getStageBottom();
            if(this.uiButton.mc_zoom)
            {
               this.uiButton.mc_zoom.x = Engine.getStageRight() - 16;
            }
            if(Boolean(buttonLayer) && this.uiButton.parent != buttonLayer)
            {
               buttonLayer.addChild(this.uiButton);
            }
         }
         if(this.uiLevelBar)
         {
            this.uiLevelBar.visible = true;
            this.uiLevelBar.alpha = 1;
            this.uiLevelBar.y = Engine.getStageY();
            if(Boolean(buttonLayer) && this.uiLevelBar.parent != buttonLayer)
            {
               buttonLayer.addChild(this.uiLevelBar);
            }
         }
         if(this.uiPopularity)
         {
            this.uiPopularity.visible = true;
            this.uiPopularity.alpha = 1;
            this.uiPopularity.x = Engine.getStageRight();
            this.uiPopularity.y = Engine.getStageY();
            if(Boolean(buttonLayer) && Boolean(!this.visitMode) && this.uiPopularity.parent != buttonLayer)
            {
               buttonLayer.addChild(this.uiPopularity);
            }
         }
         if(this.uiVisitBanner)
         {
            this.uiVisitBanner.visible = true;
            this.uiVisitBanner.alpha = 1;
            this.uiVisitBanner.x = Engine.getStageRight();
            this.uiVisitBanner.y = Engine.getStageY();
            if(Boolean(buttonLayer) && Boolean(this.visitMode) && this.uiVisitBanner.parent != buttonLayer)
            {
               buttonLayer.addChild(this.uiVisitBanner);
            }
         }
         if(GameWorld.cashPanel)
         {
            GameWorld.cashPanel.visible = true;
            GameWorld.cashPanel.alpha = 1;
            addObject(GameWorld.cashPanel);
         }
         if(!this.visitMode && Boolean(GameWorld.hiredFriendsPanel))
         {
            GameWorld.hiredFriendsPanel.visible = true;
            GameWorld.hiredFriendsPanel.alpha = 1;
            GameWorld.hiredFriendsPanel.y = Engine.getStageBottom();
            GameWorld.hiredFriendsPanel.show();
            addObject(GameWorld.hiredFriendsPanel);
         }
      }
      
      public function hideRateButton() : void
      {
         this.uiButton.buttonRate.visible = false;
      }
      
      public function setRoomItemUsageCount(param1:RoomItem, param2:int) : void
      {
         param1.usageCount = param2;
         if(param1.toilet)
         {
            if(param1.isBroken())
            {
               param2 = int(param1.itemConfig.breakCount);
               if(param1.toiletWater == null)
               {
                  param1.toiletWater = new BaseObject("ToiletWater");
                  param1.toiletWater.x = param1.x;
                  param1.toiletWater.y = param1.y;
                  param1.toiletWater.drawPriority = WorldRestaurant.SHADOW_DRAW_PRIORITY - 1;
                  room.addObject(param1.toiletWater);
                  param1.toiletStatus = new BaseObject("CleanerNeeded");
                  param1.toiletStatus.x = param1.x;
                  param1.toiletStatus.y = param1.y - tileHeight;
                  param1.toiletStatus.drawPriority = param1.drawPriority;
                  room.addObject(param1.toiletStatus);
                  if(!this.visitMode)
                  {
                     FixToiletTask.addUserTaskListener(param1);
                  }
               }
            }
            else
            {
               if(param1.toiletWater != null)
               {
                  room.removeObject(param1.toiletWater);
                  room.removeObject(param1.toiletStatus);
                  param1.toiletWater = null;
                  param1.toiletStatus = null;
               }
               if(!this.visitMode)
               {
                  FixToiletTask.removeUserTaskListener(param1);
               }
            }
         }
         else if(param1.interactive)
         {
            if(param1.isBroken())
            {
               param2 = int(param1.itemConfig.breakCount);
               this.setRoomItemState(param1,"broken");
               if(!this.visitMode)
               {
                  FixFunctionalItemTask.addUserTaskListener(param1);
               }
            }
            else
            {
               this.setRoomItemState(param1,"off");
               if(!this.visitMode)
               {
                  FixFunctionalItemTask.removeUserTaskListener(param1);
               }
            }
         }
         param1.usageCount = param2;
      }
      
      override public function init() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:UserItem = null;
         var _loc3_:MovieClip = null;
         var _loc4_:RoomItem = null;
         var _loc5_:String = null;
         var _loc6_:GameUserEmployee = null;
         var _loc7_:RandomBasket = null;
         var _loc8_:Boolean = false;
         var _loc9_:GameUserEmployee = null;
         var _loc10_:int = getTimer();
         PerfTrace.mark("WorldRestaurantPlay.init begin visitMode=" + this.visitMode + " placedItems=" + placedItems.length);
         super.init();
         PerfTrace.slow("WorldRestaurantPlay.init super",_loc10_,5);
         _loc10_ = getTimer();
         if(!this.visitMode)
         {
            canvasHeight = Engine.STAGE_HEIGHT - GameWorld.hiredFriendsPanel.getSceneHeight();
            this.uiButton = Engine.getMovieClip("RoomUiButton");
            this.uiPopularity = Engine.getMovieClip("RoomUiPopularity");
            this.uiLevelBar = Engine.getMovieClip("RoomUiLevelBar");
            this.buttonStreet = this.uiButton.buttonStreet;
            this.buttonDecorate = this.uiButton.buttonDecorate;
            this.buttonChangeMenu = this.uiButton.buttonChangeMenu;
            this.buttonMessage = this.uiButton.buttonMessage;
            this.buttonMarket = this.uiButton.buttonMarket;
            this.buttonPhoto = this.uiButton.buttonPhoto;
            this.buttonGift = this.uiButton.mc_gift;
            this.buttonBookmark = this.uiButton.mc_bookmark;
            this.buttonFolder = this.uiButton.mc_folder;
            this.buttonAvatar = this.buttonFolder.mc_content.buttonAvatar;
            this.buttonAward = this.buttonFolder.mc_content.buttonAward;
            this.buttonMusicPlayer = this.buttonFolder.mc_content.buttonMusicPlayer;
            this.buttonStreet.toolTip = new ToolTip(this.buttonStreet,GameWorld.textHandler.getTextFromId("ToolTipStreet"));
            this.buttonAvatar.toolTip = new ToolTip(this.buttonAvatar,GameWorld.textHandler.getTextFromId("ToolTipDressYourself"),true);
            this.buttonDecorate.toolTip = new ToolTip(this.buttonDecorate,GameWorld.textHandler.getTextFromId("ToolTipRedecorate"));
            this.buttonChangeMenu.toolTip = new ToolTip(this.buttonChangeMenu,GameWorld.textHandler.getTextFromId("ToolTipChangeMenu"));
            this.buttonMessage.toolTip = new ToolTip(this.buttonMessage,GameWorld.textHandler.getTextFromId("ToolTipMailBox"));
            this.buttonAward.toolTip = new ToolTip(this.buttonAward,GameWorld.textHandler.getTextFromId("ToolTipAwards"),true);
            this.buttonMarket.toolTip = new ToolTip(this.buttonMarket,GameWorld.textHandler.getTextFromId("ToolTipIngredientMarket"));
            this.buttonMusicPlayer.toolTip = new ToolTip(this.buttonMusicPlayer,GameWorld.textHandler.getTextFromId("ToolTipMusicPlayer"),true);
            this.buttonBookmark.toolTip = new ToolTip(this.buttonBookmark,GameWorld.textHandler.getTextFromId("ToolTipBookmark"));
            this.uiLevelBar.mc_level.toolTip = new ToolTip(this.uiLevelBar.mc_level,GameWorld.textHandler.getTextFromId("ToolTipGourmetPointsAndLevel"));
            this.uiPopularity.mc_popularity.buttonMode = true;
            setHandCursor(this.uiPopularity.mc_popularity,true);
            this.uiPopularity.mc_popularity.toolTip = new ToolTip(this.uiPopularity.mc_popularity,GameWorld.textHandler.getTextFromId("ToolTipPopularity"));
            this.uiPopularity.mc_popularity.addEventListener(MouseEvent.CLICK,this.onPopularityClick,false,0,true);
            this.uiPopularity.mc_closed.buttonMode = true;
            setHandCursor(this.uiPopularity.mc_closed,true);
            this.uiPopularity.mc_closed.toolTip = new ToolTip(this.uiPopularity.mc_closed,GameWorld.textHandler.getTextFromId("ToolTipRestaurantClosed"));
            setButtonMode(this.buttonStreet,true);
            setButtonMode(this.buttonAvatar,true);
            setButtonMode(this.buttonDecorate,true);
            setButtonMode(this.buttonChangeMenu,true);
            setButtonMode(this.buttonMessage,true);
            setButtonMode(this.buttonAward,true);
            setButtonMode(this.buttonMarket,true);
            setButtonMode(this.buttonMusicPlayer,true);
            setButtonMode(this.buttonBookmark,true);
            this.buttonStreet.addEventListener(MouseEvent.CLICK,this.onButtonStreetClick,false,0,true);
            this.buttonAvatar.addEventListener(MouseEvent.CLICK,this.onButtonAvatarClick,false,0,true);
            this.buttonDecorate.addEventListener(MouseEvent.CLICK,this.onButtonDecorateClick,false,0,true);
            this.buttonChangeMenu.addEventListener(MouseEvent.CLICK,this.onButtonChangeMenuClick,false,0,true);
            this.buttonMessage.addEventListener(MouseEvent.CLICK,this.onButtonMessageClick,false,0,true);
            this.buttonAward.addEventListener(MouseEvent.CLICK,this.onButtonAwardClick,false,0,true);
            this.buttonMarket.addEventListener(MouseEvent.CLICK,this.onButtonMarketClick,false,0,true);
            this.buttonMusicPlayer.addEventListener(MouseEvent.CLICK,this.onButtonMusicPlayerClick,false,0,true);
            this.buttonBookmark.addEventListener(MouseEvent.CLICK,this.onButtonBookmarkClick,false,0,true);
            this.initDiscordButton();
            this.initOwnExchangeButton();
            this.buttonMarket.mc_new.mouseChildren = false;
            this.buttonMarket.tf_sale.mouseEnabled = false;
            if(!GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_INGRADIANT_SHOP))
            {
               this.buttonMarket.mc_new.visible = false;
            }
            else
            {
               this.buttonMarket.tf_sale.visible = false;
            }
            this.buttonMusicPlayer.mc_new.mouseChildren = false;
            if(!GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_MUSIC_PLAYER))
            {
               this.buttonMusicPlayer.mc_new.visible = false;
            }
            if(GameWorld.lastBookmarkPopUpTime == -1 || GameWorld.serverTime.time / 1000 - GameWorld.lastBookmarkPopUpTime < 12 * 60 * 60)
            {
               this.buttonBookmark.visible = false;
            }
            else if(!GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_BOOKMARK))
            {
               this.buttonBookmark.mc_new.visible = false;
            }
            this.buttonFolder.mc_new.visible = false;
            this.folderButtonHandler = new FolderButton(this.buttonFolder);
            buttonLayer.addChild(this.uiPopularity);
            PerfTrace.slow("WorldRestaurantPlay.init owner UI",_loc10_,5);
         }
         else
         {
            canvasHeight = Engine.STAGE_HEIGHT - this.curFriendsList.getSceneHeight();
            this.uiButton = Engine.getMovieClip("RoomVisitUiButton");
            this.uiVisitBanner = Engine.getMovieClip("RoomVisitUiBanner");
            this.uiLevelBar = Engine.getMovieClip("RoomUiLevelBar");
            this.buttonGift = this.uiButton.mc_gift;
            this.buttonBookmark = this.uiButton.mc_bookmark;
            setButtonMode(this.uiButton.buttonStreet,true);
            setButtonMode(this.uiButton.buttonWriteMessage,true);
            setButtonMode(this.uiButton.buttonTrade,true);
            setButtonMode(this.uiButton.buttonRate,true);
            this.uiButton.buttonStreet.addEventListener(MouseEvent.CLICK,this.onButtonStreetClick);
            this.uiButton.buttonStreet.toolTip = new ToolTip(this.uiButton.buttonStreet,GameWorld.textHandler.getTextFromId("ToolTipStreet"));
            if(WorldStreet.streetType == WorldStreet.STREET_TYPE_FRIENDS)
            {
               this.uiButton.buttonWriteMessage.addEventListener(MouseEvent.CLICK,this.onButtonWriteMessageClick);
               this.uiButton.buttonTrade.addEventListener(MouseEvent.CLICK,this.onButtonTradeClick);
               this.uiButton.buttonRate.visible = false;
               this.uiButton.buttonWriteMessage.toolTip = new ToolTip(this.uiButton.buttonWriteMessage,GameWorld.textHandler.getTextFromId("ToolTipLeaveAMessage"));
               this.uiButton.buttonTrade.toolTip = new ToolTip(this.uiButton.buttonTrade,GameWorld.textHandler.getTextFromId("ToolTipTradeIngredients"));
            }
            else
            {
               if(this.enableRating)
               {
                  this.uiButton.buttonRate.addEventListener(MouseEvent.CLICK,this.onButtonRateClick);
                  this.uiButton.buttonRate.toolTip = new ToolTip(this.uiButton.buttonRate,GameWorld.textHandler.getTextFromId("ToolTipRateThisRestaurant"));
               }
               else
               {
                  this.uiButton.buttonRate.visible = false;
               }
               this.uiButton.buttonWriteMessage.visible = false;
               this.uiButton.buttonTrade.visible = false;
               if(gameUser.rated)
               {
                  this.uiButton.buttonRate.visible = false;
               }
            }
            _loc1_ = GameWorld.getUserFaceImage(gameUser);
            if(_loc1_ != null)
            {
               this.uiVisitBanner.mc_frame.mc_face.addChild(_loc1_);
            }
            _loc2_ = gameUser.getUsedBuildingBannerItem();
            if(_loc2_ != null)
            {
               _loc3_ = Engine.getMovieClip(_loc2_.itemConfig.className);
               _loc3_.tf_name.text = gameUser.bannerText;
               _loc3_.x = this.uiVisitBanner.mc_banner.x;
               _loc3_.y = this.uiVisitBanner.mc_banner.y;
               _loc3_.scaleX = this.uiVisitBanner.mc_banner.scaleX;
               _loc3_.scaleY = this.uiVisitBanner.mc_banner.scaleY;
               this.uiVisitBanner.addChildAt(_loc3_,this.uiVisitBanner.getChildIndex(this.uiVisitBanner.mc_banner));
               this.uiVisitBanner.mc_banner.visible = false;
            }
            else
            {
               this.uiVisitBanner.mc_banner.tf_name.text = gameUser.bannerText;
            }
            setRating(this.uiVisitBanner.mc_userStars,gameUser);
            if(!gameUser.userInfo.isInStreet)
            {
               this.uiVisitBanner.mc_userStars.visible = false;
            }
            buttonLayer.addChild(this.uiVisitBanner);
            PerfTrace.slow("WorldRestaurantPlay.init visit UI",_loc10_,5);
         }
         _loc10_ = getTimer();
         this.enablePlots();
         setButtonMode(this.uiButton.buttonPhoto,true);
         this.uiButton.buttonPhoto.toolTip = new ToolTip(this.uiButton.buttonPhoto,GameWorld.textHandler.getTextFromId("ToolTipPhoto"));
         this.uiButton.buttonPhoto.addEventListener(MouseEvent.CLICK,this.onButtonPhotoClick,false,0,true);
         this.uiButton.buttonPhoto.mc_new.mouseEnabled = false;
         if(!GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_PHOTO))
         {
            this.uiButton.buttonPhoto.mc_new.visible = false;
         }
         setButtonMode(this.buttonGift,true);
         this.buttonGift.toolTip = new ToolTip(this.buttonGift,GameWorld.textHandler.getTextFromId("SendFreeFoodToFriends"));
         this.buttonGift.addEventListener(MouseEvent.CLICK,this.onButtonGiftInviteClick,false,0,true);
         this.buttonGift.mc_new.mouseEnabled = false;
         if(!GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_GIFT_INVITE_FOOD))
         {
            this.buttonGift.mc_new.visible = false;
         }
         setRating(this.uiLevelBar.mc_stars,GameWorld.gameUser);
         if(!GameWorld.gameUser.userInfo.isInStreet)
         {
            this.uiLevelBar.mc_stars.visible = false;
         }
         this.zoomLever = new ZoomLever(this.uiButton.mc_zoom,this);
         buttonLayer.addChild(this.uiButton);
         buttonLayer.addChild(this.uiLevelBar);
         this.restoreHudLayers();
         PerfTrace.slow("WorldRestaurantPlay.init shared UI",_loc10_,5);
         _loc10_ = getTimer();
         var _loc11_:int = 0;
         while(_loc11_ < placedItems.length)
         {
            _loc4_ = placedItems[_loc11_];
            if(_loc4_.chairItem)
            {
               this.chairs.push(_loc4_);
            }
            else if(_loc4_.doorItem)
            {
               this.doors.push(_loc4_);
            }
            else if(_loc4_.kitchen)
            {
               this.kitchens.push(_loc4_);
            }
            else if(_loc4_.interactive)
            {
               this.interactiveItems.push(_loc4_);
            }
            else if(_loc4_.sink)
            {
               this.sinks.push(_loc4_);
            }
            else if(_loc4_.drink)
            {
               this.drinkItems.push(_loc4_);
            }
            else if(_loc4_.bed)
            {
               this.beds.push(_loc4_);
            }
            if(_loc4_.menuItem)
            {
               this.menuItem = _loc4_;
            }
            else if(_loc4_.achievementItem)
            {
               this.achievementItem = _loc4_;
            }
            else if(_loc4_.mailItem)
            {
               this.mailItem = _loc4_;
            }
            else if(_loc4_.musicPlayer)
            {
               _loc4_.buttonMode = true;
               _loc4_.toolTip = new ToolTip(_loc4_,GameWorld.textHandler.getTextFromId("ToolTipMusicPlayer"));
               _loc4_.addEventListener(MouseEvent.CLICK,this.onMusicPlayerClick,false,0,true);
            }
            if(_loc4_.itemConfig.breakCount)
            {
               this.setRoomItemUsageCount(_loc4_,Engine.rnd(0,int(_loc4_.itemConfig.breakCount) + 1));
            }
            if(_loc4_.itemConfig.infoText)
            {
               _loc4_.buttonMode = true;
               _loc5_ = _loc4_.itemConfig.name;
               if(_loc4_.itemConfig.arcadeGame)
               {
                  _loc5_ += "\n\n" + GameWorld.textHandler.getTextFromId("ClickToPlay");
               }
               _loc4_.toolTip = new ToolTip(_loc4_,_loc5_);
               _loc4_.addEventListener(MouseEvent.CLICK,this.onItemWithInfoTextClick,false,0,true);
            }
            _loc4_.initFunctions(this);
            _loc11_++;
         }
         PerfTrace.slow("WorldRestaurantPlay.init classify/initFunctions",_loc10_,5);
         _loc10_ = getTimer();
         this.ingredientShop = roadLayer.mc_ingredientShop;
         this.ingredientShop.buttonMode = true;
         this.ingredientShop.toolTip = new ToolTip(this.ingredientShop,GameWorld.textHandler.getTextFromId("ToolTipIngredientMarket"));
         this.ingredientShop.addEventListener(MouseEvent.CLICK,this.onIngredientShopClick,false,0,true);
         _loc11_ = 0;
         while(_loc11_ < gameUser.employeeUsers.length)
         {
            _loc6_ = gameUser.employeeUsers[_loc11_];
            if(_loc6_.gameUser.employerUser != gameUser)
            {
               _loc6_.gameUser.employerUser = gameUser;
               _loc6_.gameUser.clearAnimationFrames();
            }
            _loc11_++;
         }
         PerfTrace.slow("WorldRestaurantPlay.init employee ownership refresh",_loc10_,5);
         _loc10_ = getTimer();
         if(this.DEBUG_PLAYER)
         {
            this.debugPlayer = new AvatarActor(0,0,new GameUser(null),this,[Avatar3D.ANIMATION_IDLE,Avatar3D.ANIMATION_WALK]);
            this.debugPlayer.setAnimation(Avatar3D.ANIMATION_IDLE);
            room.addObject(this.debugPlayer);
            room.addEventListener(MouseEvent.MOUSE_DOWN,this.onMoveDebugPlayer);
         }
         this.levelBar = new LevelBar(this.uiLevelBar.mc_level,GameWorld.gameUser);
         this.uiLevelBar.mc_level.buttonMode = true;
         this.uiLevelBar.mc_level.addEventListener(MouseEvent.CLICK,this.onLevelBarClick,false,0,true);
         this.uiLevelBar.cacheAsBitmap = true;
         if(this.achievementItem)
         {
            this.achievementItem.toolTip = new ToolTip(this.achievementItem,GameWorld.textHandler.getTextFromId("ToolTipAwards"));
            this.achievementItem.addEventListener(MouseEvent.CLICK,this.onAchievementItemClick);
            this.achievementItem.buttonMode = true;
         }
         if(this.menuItem)
         {
            this.menuItem.toolTip = new ToolTip(this.menuItem,GameWorld.textHandler.getTextFromId("ToolTipRestaurantMenu"));
            this.menuItem.addEventListener(MouseEvent.CLICK,this.onMenuItemClick);
            this.menuItem.buttonMode = true;
         }
         if(this.mailItem)
         {
            this.mailItem.toolTip = new ToolTip(this.mailItem,GameWorld.textHandler.getTextFromId("ToolTipMailBox"));
            this.mailItem.addEventListener(MouseEvent.CLICK,this.onMailItemClick);
            this.mailItem.buttonMode = true;
         }
         this.refreshDemand();
         PerfTrace.slow("WorldRestaurantPlay.init HUD handlers",_loc10_,5);
         _loc10_ = getTimer();
         _loc11_ = 0;
         while(_loc11_ < gameUser.trashCount.value)
         {
            this.addRandomTrash();
            _loc11_++;
         }
         PerfTrace.slow("WorldRestaurantPlay.init trash count=" + gameUser.trashCount.value,_loc10_,5);
         _loc10_ = getTimer();
         _loc11_ = 0;
         while(_loc11_ < trees.length)
         {
            if(trees[_loc11_].canBeShaken())
            {
               trees[_loc11_].buttonMode = true;
               trees[_loc11_].addEventListener(MouseEvent.MOUSE_DOWN,this.onTreeMouseDown,false,0,true);
            }
            _loc11_++;
         }
         PerfTrace.slow("WorldRestaurantPlay.init trees",_loc10_,5);
         _loc10_ = getTimer();
         if(!this.visitMode)
         {
            this.refreshEmployeeCount();
            this.refreshMails();
         }
         PerfTrace.slow("WorldRestaurantPlay.init employee/mail refresh",_loc10_,5);
         _loc10_ = getTimer();
         if(this.visitMode && WorldStreet.streetType == WorldStreet.STREET_TYPE_FRIENDS)
         {
            if(!this.alreadyHelpedCurrentFriend() && !this.maxActivitesForTodayReached())
            {
               _loc7_ = new RandomBasket(0,VisitActivity.ACTIVITY_STRINGS.length);
               _loc8_ = false;
               while(!_loc8_ && _loc7_.length() > 0)
               {
                  this.visitActivity = VisitActivity.create(int(_loc7_.getNextItem()));
                  this.visitActivity.init(this);
                  _loc8_ = this.visitActivity.run();
               }
               if(!_loc8_)
               {
                  Debug.out("Error -- No activity selected for user!");
               }
            }
         }
         PerfTrace.slow("WorldRestaurantPlay.init visit activity",_loc10_,5);
         _loc10_ = getTimer();
         gameUser.refreshBedStatusForRestingEmployees();
         _loc11_ = 0;
         while(_loc11_ < gameUser.employeeUsers.length)
         {
            _loc9_ = gameUser.employeeUsers[_loc11_];
            this.createEmployeeActor(_loc9_);
            _loc11_++;
         }
         PerfTrace.slow("WorldRestaurantPlay.init create employees",_loc10_,5);
         _loc10_ = getTimer();
         this.refreshRestaurantClosedState();
         if(!this.visitMode)
         {
            addRestaurantExtension(new TutorialExtension(this));
         }
         PerfTrace.slow("WorldRestaurantPlay.init final extensions",_loc10_,5);
         PerfTrace.mark("WorldRestaurantPlay.init end chairs=" + this.chairs.length + " kitchens=" + this.kitchens.length + " employees=" + gameUser.employeeUsers.length);
      }
      
      private function hasValidEntrances() : Boolean
      {
         var _loc1_:RoomItem = null;
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.doors.length)
         {
            _loc1_ = this.doors[_loc3_];
            _loc2_ = getFacingTile(_loc1_.getEntranceTileX(),_loc1_.getEntranceTileY(),_loc1_.getRotationCount());
            if(isWalkable(_loc2_.x,_loc2_.y))
            {
               return true;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < numOutsideTilesY)
         {
            if(isWalkable(1,numTilesY + _loc3_))
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function getChefCountForKitchen(param1:RoomItem) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this.chefs.length)
         {
            if(this.chefs[_loc3_].kitchen == param1)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      override public function hideNotify() : void
      {
         var _loc1_:int = getTimer();
         PerfTrace.mark("WorldRestaurantPlay.hideNotify begin");
         super.hideNotify();
         if(this.visitMode)
         {
            this.curFriendsList.removeEventListener(FriendListEvent.USER_CLICKED,this.onFriendListUserClicked);
            removeObject(this.curFriendsList);
         }
         else
         {
            removeObject(GameWorld.hiredFriendsPanel);
            GameWorld.offlineEarningTimer = getTimer();
         }
         removeObject(GameWorld.cashPanel);
         GameWorld.settingOverlay.hideSaveButton();
         if(this.bgMusic != null)
         {
            this.bgMusic.stop();
         }
         instance = null;
         Engine.instance.stage.removeEventListener(Event.FULLSCREEN,this.onFullScreen);
         PerfTrace.slow("WorldRestaurantPlay.hideNotify end",_loc1_,5);
      }
      
      public function addTrashObject(param1:String, param2:int, param3:int) : void
      {
         var _loc4_:int = getTileIndex(param2,param3);
         this.trashMap[_loc4_] = true;
         var _loc5_:GameObject = new GameObject(param1);
         _loc5_.tileIndex = _loc4_;
         _loc5_.tileX = param2;
         _loc5_.tileY = param3;
         _loc5_.className = param1;
         _loc5_.x = getScreenX(param2,param3);
         _loc5_.y = getScreenY(param2,param3) + tileHeightHalf;
         _loc5_.drawPriority = getTileDrawPriority(param2,param3);
         _loc5_.buttonMode = true;
         room.addObject(_loc5_);
         this.trashObjects.push(_loc5_);
         ++this.trashCount.value;
      }
      
      private function onLevelBarClick(param1:MouseEvent) : void
      {
         GameWorld.showNextLevelPopUp(GameWorld.gameUser.level.value);
      }
      
      private function getRandomFreeFriendUser() : GameUser
      {
         var _loc1_:Array = GameWorld.cachedGameUsers[RpcClient.USER_CONTEXT_FRIENDS | RpcClient.TIME_CONTEXT_ALL];
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            _loc2_[_loc3_] = _loc1_[_loc3_];
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < this.customers.length)
         {
            if(this.customers[_loc3_].user.userInfo)
            {
               _loc2_.splice(_loc2_.indexOf(this.customers[_loc3_].user),1);
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < gameUser.employeeUsers.length)
         {
            _loc2_.splice(_loc2_.indexOf(gameUser.employeeUsers[_loc3_].gameUser),1);
            _loc3_++;
         }
         if(_loc2_.length > 0)
         {
            return _loc2_[Engine.rnd(0,_loc2_.length)];
         }
         return null;
      }
      
      private function onFriendListUserClicked(param1:FriendListEvent) : void
      {
         this.destroy();
         GameWorld.fadeToWorld(new WorldStreet(param1.user,false,false));
      }
      
      private function onButtonPhotoClick(param1:MouseEvent) : void
      {
         this.uiButton.buttonPhoto.mc_new.visible = false;
         var _loc2_:BitmapData = GameWorld.convertToBitmapData(room,1,new Rectangle(-(numTilesY + numOutsideTilesY) * tileWidthHalf + tileWidthHalf / 2,-100,floorLayer.width,floorLayer.height + 110),WorldPhotoPreviewPopUp.MAX_PHOTO_WIDTH,WorldPhotoPreviewPopUp.MAX_PHOTO_HEIGHT);
         var _loc3_:BitmapData = GameWorld.convertToBitmapData(room,room.scaleX,new Rectangle(-room.x + Engine.getStageX(),-room.y + Engine.getStageY(),Engine.getStageWidth(),Engine.getStageHeight() - GameWorld.hiredFriendsPanel.height),WorldPhotoPreviewPopUp.MAX_PHOTO_WIDTH,WorldPhotoPreviewPopUp.MAX_PHOTO_HEIGHT);
         var _loc4_:WorldPhotoPreviewPopUp = new WorldPhotoPreviewPopUp([_loc2_,_loc3_]);
         _loc4_.show();
      }
      
      private function getEmployeeActorFreeTiles() : Array
      {
         var _loc1_:Number = NaN;
         var _loc2_:Array = new Array();
         var _loc3_:Number = 1;
         while(_loc3_ < numTilesX)
         {
            _loc1_ = 1;
            while(_loc1_ < numTilesY)
            {
               if(isWalkable(_loc3_,_loc1_) && !this.isOccupiedByEmployeeActor(_loc3_,_loc1_))
               {
                  _loc2_.push(getTileIndex(_loc3_,_loc1_));
               }
               _loc1_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function showAwardPopUp() : void
      {
         var _loc1_:WorldAwards = null;
         if(GameWorld.gameUser.level.value > 0)
         {
            _loc1_ = new WorldAwards(gameUser.awards);
            _loc1_.show();
         }
      }
      
      public function setDemand(param1:int) : void
      {
         gameUser.setDemandPoints(Math.min(param1,this.maxDemand));
         this.refreshDemand();
      }
      
      private function onTreeMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:RestaurantTreeObject = RestaurantTreeObject(param1.currentTarget);
         if(_loc2_.shake())
         {
            this.addCoin(param1.currentTarget.x,param1.currentTarget.y + 40,GameWorld.SHAKE_TREE_COIN);
            GameWorld.saveProfileHandler.addShakenTree();
         }
      }
      
      public function onButtonTradeClick(param1:MouseEvent) : void
      {
         var _loc2_:WorldTradePanel = new WorldTradePanel(gameUser,false);
         _loc2_.show();
      }
      
      public function onButtonWriteMessageClick(param1:MouseEvent) : void
      {
         var _loc2_:WorldWriteMessage = new WorldWriteMessage(null,this.gameUser,null);
         _loc2_.show();
      }
      
      public function removeVisitActivity() : void
      {
         this.visitActivity = null;
      }
      
      public function setRoomItemState(param1:RoomItem, param2:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:MovieClip = param1.getChildMovieClipInstance("mc_content");
         if(_loc4_)
         {
            _loc4_.gotoAndPlay(param2);
            if(param1.subItemAutoSplit)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.subItems.length)
               {
                  this.setRoomItemState(param1.subItems[_loc3_],param2);
                  _loc3_++;
               }
            }
         }
         _loc4_ = param1.getChildMovieClipInstance("mc_contentReverse");
         var _loc5_:int = 1;
         while(_loc4_)
         {
            _loc4_.gotoAndPlay(param2);
            _loc4_ = param1.getChildMovieClipInstance("mc_content" + _loc5_);
            _loc5_++;
         }
      }
      
      public function onButtonChangeMenuClick(param1:MouseEvent) : void
      {
         if(GameWorld.gameUser.level.value > 0)
         {
            this.destroy();
            GameWorld.fadeToWorld(new WorldRecipeMenu(gameUser));
         }
      }
      
      private function onPopularityClick(param1:MouseEvent) : void
      {
      }
      
      public function addRestingEmployee(param1:GameUserEmployee) : void
      {
         var _loc2_:RoomItem = null;
         var _loc3_:int = 0;
         var _loc4_:RoomItem = null;
         var _loc5_:SleepingEmployee = null;
         this.removeActor(param1);
         if(param1.bedItem != null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.beds.length)
            {
               _loc4_ = this.beds[_loc3_];
               if(_loc4_.serverUid == param1.bedItem.serverUid)
               {
                  _loc2_ = _loc4_;
                  break;
               }
               _loc3_++;
            }
            if(_loc2_)
            {
               param1.bedItem = _loc2_.getUserItem();
               _loc5_ = new SleepingEmployee(param1,_loc2_,this);
               this.addEmployeeActor(_loc5_);
            }
         }
      }
      
      public function addOrderFromCustomer(param1:Customer) : void
      {
         param1.order.chair = param1.chair;
         this.orders.push(param1.order);
      }
      
      public function fixBreakableItem(param1:RoomItem) : void
      {
         this.setRoomItemUsageCount(param1,0);
         var _loc2_:GameObject = new GameObject("Clean");
         _loc2_.removeWhenComplete = true;
         _loc2_.numLoops = 1;
         _loc2_.drawPriority = param1.drawPriority;
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         room.addObject(_loc2_);
         param1.cleaner = null;
      }
      
      private function canChairOrder(param1:RoomItem, param2:DishOrder) : Boolean
      {
         if(param2)
         {
            if(param2.recipe.type == Recipe.MENU_RECIPE_DRINK)
            {
               return param1.canOrderDrink;
            }
            return param1.canOrderFood;
         }
         return true;
      }
      
      private function onButtonBookmarkClick(param1:MouseEvent) : void
      {
         GameWorld.showBookmarkOverlay();
         this.buttonBookmark.visible = false;
         GameWorld.lastBookmarkPopUpTime = GameWorld.serverTime.time / 1000;
         GameWorld.globalRpcs.writeBookmarkCount(GameWorld.lastBookmarkPopUpTime);
         GameWorld.setFirstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_BOOKMARK);
         this.buttonBookmark.mc_new.visible = false;
      }
      
      public function refreshMails() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:MailItem = null;
         var _loc6_:WorldMailCoinBagPopUp = null;
         if(!this.visitMode)
         {
            _loc1_ = gameUser.getNewMailItems();
            this.unreadMailCount = _loc1_.length;
            this.buttonMessage.tf_count.mouseEnabled = false;
            this.buttonMessage.tf_count.text = Math.min(_loc1_.length,99);
            if(this.mailItem)
            {
               _loc3_ = this.mailItem.getChildMovieClipInstance("mc_letterBox");
               _loc4_ = this.mailItem.getChildMovieClipInstance("mc_letterBoxReverse");
               if(this.unreadMailCount == 0)
               {
                  _loc3_.gotoAndStop("off");
                  _loc4_.gotoAndStop("off");
               }
               else
               {
                  _loc3_.gotoAndPlay("on");
                  _loc4_.gotoAndPlay("on");
               }
            }
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               _loc5_ = _loc1_[_loc2_];
               if(_loc5_.type == RpcClient.MAIL_TYPE_CASH)
               {
                  _loc6_ = new WorldMailCoinBagPopUp(_loc5_,null);
                  _loc6_.queueToShow();
                  GameWorld.gameUser.removeMailItem(_loc5_);
               }
               _loc2_++;
            }
         }
      }
      
      public function removeTrashObject(param1:GameObject) : void
      {
         this.trashMap[param1.tileIndex] = false;
         gameUser.trashCount.value = Math.max(gameUser.trashCount.value - 1,0);
         this.trashCount.value = Math.max(this.trashCount.value - 1,0);
         this.trashObjects.splice(this.trashObjects.indexOf(param1),1);
         room.removeObject(param1);
         GameWorld.addAwardValue(GameAwards.AWARD_REMOVE_TRASH,1);
         var _loc2_:GameObject = new GameObject("Trash");
         var _loc3_:MovieClip = _loc2_.getChildMovieClipInstance("mc_content");
         _loc3_.getChildAt(0).visible = false;
         _loc3_.addChild(Engine.getMovieClip(param1.className));
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         _loc2_.setSequence("remove");
         _loc2_.numLoops = 1;
         _loc2_.removeWhenComplete = true;
         _loc2_.drawPriority = int.MAX_VALUE / 2;
         room.addObject(_loc2_);
         var _loc4_:int = Engine.rnd(0,this.maxTrashCoins) + 1;
         this.addCoin(param1.x,param1.y,GameWorld.SHAKE_TREE_COIN * _loc4_);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            GameWorld.saveProfileHandler.addTrash();
            _loc5_++;
         }
         this.addGourmetPoints(GameWorld.GOURMET_POINTS_TRASH);
      }
      
      public function onButtonRateClick(param1:MouseEvent) : void
      {
         var _loc2_:WorldRatePopUp = new WorldRatePopUp(gameUser,this);
         _loc2_.show();
      }
      
      override public function tick(param1:uint) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:RoomItem = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Customer = null;
         var _loc12_:* = 0;
         var _loc13_:DishOrder = null;
         var _loc14_:DishOrder = null;
         var _loc15_:Object = null;
         var _loc16_:Waitor = null;
         var _loc17_:Object = null;
         var _loc18_:ChefActor = null;
         var _loc19_:GameObject = null;
         var _loc20_:BaseObject = null;
         var _loc21_:ToolTip = null;
         super.tick(param1);
         if(this.restaurantClosed)
         {
            if(this.visitMode)
            {
            }
         }
         else if(this.nextCustomer == null)
         {
            if(gameUser.level.value > 0)
            {
               this.customerTimer = 60000 / (Math.min(gameUser.getDemandPoints(),GameWorld.MAX_DEMAND) * CUSTOMERS_PER_MINUTE_PER_DEMAND) + Engine.rnd(-3000,3000);
               if(this.hasValidEntrances())
               {
                  _loc2_ = Engine.rnd(0,PEDESTRIAN_START_TILE_POSITION.length);
                  _loc3_ = int(PEDESTRIAN_START_TILE_POSITION[_loc2_][0]);
                  _loc4_ = int(PEDESTRIAN_START_TILE_POSITION[_loc2_][1]);
                  this.nextCustomer = this.getNextCustomer(getScreenX(_loc3_,_loc4_),getScreenY(_loc3_,_loc4_));
                  this.nextCustomer.hide();
                  this.customers.push(this.nextCustomer);
               }
            }
         }
         else
         {
            this.customerTimer -= param1;
            if(this.customerTimer <= 0)
            {
               _loc5_ = this.getValidDoors();
               _loc6_ = this.getValidOutsideAreaEntrances();
               if(_loc5_.length > 0 && (Engine.rnd(0,2) == 0 || _loc6_.length == 0))
               {
                  _loc7_ = _loc5_[Engine.rnd(0,_loc5_.length)];
                  this.nextCustomer.walkToEntrance(_loc7_.getEntranceTileX(),_loc7_.getEntranceTileY(),_loc7_);
               }
               else
               {
                  _loc8_ = int(_loc6_[Engine.rnd(0,_loc6_.length)]);
                  this.nextCustomer.walkToEntrance(0,_loc8_,null);
               }
               this.nextCustomer.show();
               room.addObject(this.nextCustomer);
               this.nextCustomer = null;
            }
         }
         if(this.customers.length < NUM_CACHED_CUSTOMERS)
         {
            this.pedestrianCreateTimer -= param1;
            if(this.pedestrianCreateTimer <= 0)
            {
               _loc2_ = Engine.rnd(0,PEDESTRIAN_START_TILE_POSITION.length);
               _loc3_ = int(PEDESTRIAN_START_TILE_POSITION[_loc2_][0]);
               _loc4_ = int(PEDESTRIAN_START_TILE_POSITION[_loc2_][1]);
               _loc9_ = int(PEDESTRIAN_END_TILE_POSITION[_loc2_][0]);
               _loc10_ = int(PEDESTRIAN_END_TILE_POSITION[_loc2_][1]);
               _loc11_ = this.getNextCustomer(getScreenX(_loc3_,_loc4_),getScreenY(_loc3_,_loc4_));
               _loc11_.setPedestrian(_loc9_,_loc10_);
               this.customers.push(_loc11_);
               room.addObject(_loc11_);
               this.pedestrianCreateTimer = PEDESTRAIN_CREATE_TIMER;
            }
         }
         if(this.completedOrders.length > 0)
         {
            _loc12_ = int(this.completedOrders.length - 1);
            while(_loc12_ >= 0)
            {
               _loc13_ = this.completedOrders[_loc12_];
               if(this.moveClosestFreeWaitorToCookedOrder(_loc13_))
               {
                  this.completedOrders.splice(_loc12_,1);
               }
               _loc12_--;
            }
         }
         if(this.orders.length > 0)
         {
            _loc12_ = int(this.orders.length - 1);
            while(_loc12_ >= 0)
            {
               _loc14_ = this.orders[_loc12_];
               if(_loc14_.recipe.type == Recipe.MENU_RECIPE_DRINK)
               {
                  _loc15_ = this.getWaiterForDrinkOrder(_loc14_);
                  if(_loc15_ != null)
                  {
                     _loc16_ = _loc15_.waitor;
                     _loc16_.getOrderFromDrinkItem(_loc14_,_loc15_.path,_loc15_.drinkItem);
                     this.orders.splice(_loc12_,1);
                  }
               }
               _loc12_--;
            }
         }
         if(this.emptyPlates.length > 0)
         {
            _loc12_ = 0;
            while(_loc12_ < this.emptyPlates.length)
            {
               _loc13_ = this.emptyPlates[_loc12_];
               _loc17_ = this.getClosestFreeWaitor(_loc13_.tileX,_loc13_.tileY,null);
               if(_loc17_ == null)
               {
                  _loc17_ = this.getClosestFreeWaitor(_loc13_.chair.tileX,_loc13_.chair.tileY,null);
               }
               if(_loc17_)
               {
                  this.emptyPlates.splice(_loc12_,1);
                  _loc17_.path.pop();
                  _loc17_.waitor.doGetEmptyPlate(_loc13_,_loc17_.path);
               }
               else
               {
                  _loc12_++;
               }
            }
         }
         if(this.orders.length > 0)
         {
            _loc12_ = int(this.orders.length - 1);
            while(_loc12_ >= 0)
            {
               _loc13_ = this.orders[_loc12_];
               if(_loc13_.recipe.type != Recipe.MENU_RECIPE_DRINK)
               {
                  _loc18_ = this.getBestFreeChef(_loc13_);
                  if(_loc18_ != null)
                  {
                     _loc18_.cook(_loc13_);
                     this.orders.splice(_loc12_,1);
                  }
               }
               _loc12_--;
            }
         }
         _loc12_ = 0;
         while(_loc12_ < this.doors.length)
         {
            if(this.getDoorState(this.doors[_loc12_]) == "open")
            {
               if(this.doors[_loc12_].doorTimer)
               {
                  this.doors[_loc12_].doorTimer -= param1;
                  if(this.doors[_loc12_].doorTimer <= 0)
                  {
                     this.setRoomItemState(this.doors[_loc12_],"closing");
                  }
               }
            }
            _loc12_++;
         }
         _loc12_ = 0;
         while(_loc12_ < this.trashObjects.length)
         {
            _loc19_ = this.trashObjects[_loc12_];
            if(_loc19_.trashOutline != null)
            {
               if(!_loc19_.hitTestPoint(Engine.instance.stage.mouseX,Engine.instance.stage.mouseY,false))
               {
                  room.removeObject(_loc19_.trashOutline);
                  _loc19_.trashOutline = null;
               }
            }
            else if(_loc19_.hitTestPoint(Engine.instance.stage.mouseX,Engine.instance.stage.mouseY,false))
            {
               _loc20_ = new BaseObject(_loc19_.className + "Outline");
               _loc20_.drawPriority = int.MAX_VALUE / 2;
               _loc20_.x = _loc19_.x;
               _loc20_.y = _loc19_.y;
               _loc20_.trashObject = _loc19_;
               _loc20_.buttonMode = true;
               _loc20_.addEventListener(MouseEvent.MOUSE_DOWN,this.onTrashMouseDown,false,0,true);
               _loc19_.trashOutline = _loc20_;
               room.addObject(_loc20_);
            }
            _loc12_++;
         }
         if(!this.visitMode && !this.silentTick)
         {
            GameWorld.trashTimer -= param1;
            if(GameWorld.trashTimer <= 0)
            {
               gameUser.trashCount.value = Math.min(gameUser.trashCount.value + 1,GameWorld.MAX_TRASH);
               GameWorld.trashTimer = GameWorld.TRASH_APPEAR_RATE.value + Engine.rnd(-GameWorld.TRASH_APPEAR_RATE_RANDOM_DELTA,GameWorld.TRASH_APPEAR_RATE_RANDOM_DELTA);
            }
            if(this.trashCount.value < gameUser.trashCount.value)
            {
               this.addRandomTrash();
            }
            gameUser.tick(param1);
            this.userTaskQueue.tick(param1);
         }
         if(this.visitMode && this.visitActivity != null)
         {
            this.userTaskQueue.tick(param1);
            this.visitActivity.tick(param1);
         }
         if(!this.silentTick)
         {
            if(this.foodKing)
            {
               this.foodKing.tick(param1);
            }
            if(this.showRestaurantClosedToolTip)
            {
               if(WorldPopUp.activePopUp.length == 0)
               {
                  this.showRestaurantClosedToolTip = false;
                  _loc21_ = this.uiPopularity.mc_closed.toolTip;
                  _loc21_.show(5000);
               }
            }
         }
      }
      
      override public function keyDown(param1:int, param2:int) : void
      {
      }
      
      public function getEmptyInteractiveItems() : Array
      {
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.interactiveItems.length)
         {
            if(this.interactiveItems[_loc2_].customer == null && !this.interactiveItems[_loc2_].isBroken())
            {
               _loc1_.push(this.interactiveItems[_loc2_]);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function isStoveAvailable(param1:RoomItem) : Boolean
      {
         var _loc2_:MovieClip = param1.getChildMovieClipInstance("mc_content");
         return _loc2_.currentLabel == "idle";
      }
      
      private function addRestaurantClosedTime(param1:int) : void
      {
         var _loc2_:int = 0;
         restaurantClosedTimer += param1;
         var _loc3_:Number = GameWorld.RESTAURANT_CLOSED_DEMAND_DECREASE_RATE_PER_HOUR * restaurantClosedTimer / GameWorld.HOUR_MILLIS;
         if(_loc3_ >= 1)
         {
            _loc2_ = Math.floor(_loc3_);
            this.addDemand(-_loc2_);
            restaurantClosedTimer -= _loc2_ / GameWorld.RESTAURANT_CLOSED_DEMAND_DECREASE_RATE_PER_HOUR * GameWorld.HOUR_MILLIS;
         }
      }
      
      public function disablePlots() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < plots.length)
         {
            plots[_loc1_].disableClicks();
            _loc1_++;
         }
      }
      
      private function onMusicPlayerClick(param1:MouseEvent) : void
      {
         if(!moveGesture)
         {
            this.showMusicStore();
         }
      }
      
      private function maxActivitesForTodayReached() : Boolean
      {
         var _loc1_:int = GameWorld.getVisitRewardAmount();
         if(_loc1_)
         {
            return false;
         }
         return true;
      }
      
      public function isOccupiedByEmployeeActor(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         while(_loc3_ < this.employeeActors.length)
         {
            if(this.employeeActors[_loc3_].tileX == param1 && this.employeeActors[_loc3_].tileY == param2)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function getToiletSeats() : Array
      {
         var _loc1_:RoomItem = null;
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this.chairs.length)
         {
            _loc1_ = this.chairs[_loc3_];
            if(_loc1_.toilet)
            {
               _loc2_.push(_loc1_);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function onButtonMusicPlayerClick(param1:MouseEvent) : void
      {
         this.showMusicStore();
      }
      
      private function isKitchenOccupied(param1:RoomItem) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.chefs.length)
         {
            if(this.chefs[_loc2_].kitchen == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function onCustomerLeave(param1:Customer) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1.chair != null)
         {
            param1.chair.customer = null;
            param1.chair = null;
         }
         if(param1.order != null)
         {
            _loc2_ = this.orders.indexOf(param1.order);
            if(_loc2_ != -1)
            {
               this.orders.splice(_loc2_,1);
            }
            _loc3_ = this.completedOrders.indexOf(param1.order);
            if(_loc3_ != -1)
            {
               this.completedOrders.splice(_loc3_,1);
            }
            if(param1.order.kitchen)
            {
               this.setRoomItemState(param1.order.kitchen,"idle");
            }
            _loc4_ = 0;
            while(_loc4_ < this.chefs.length)
            {
               if(this.chefs[_loc4_].cookingOrder == param1.order)
               {
                  this.chefs[_loc4_].discardCurrentOrder();
               }
               _loc4_++;
            }
            _loc4_ = 0;
            while(_loc4_ < this.waitors.length)
            {
               if(this.waitors[_loc4_].order == param1.order)
               {
                  this.waitors[_loc4_].order = null;
               }
               _loc4_++;
            }
            if(param1.order.table)
            {
               param1.order.table.tableTopOrder = null;
               param1.order.table.rcrLiberar(param1.order);
            }
            param1.order = null;
         }
      }
      
      private function getValidDoors() : Array
      {
         var _loc1_:RoomItem = null;
         var _loc2_:Object = null;
         var _loc3_:Array = new Array();
         var _loc4_:Number = 0;
         while(_loc4_ < this.doors.length)
         {
            _loc1_ = this.doors[_loc4_];
            _loc2_ = getFacingTile(_loc1_.getEntranceTileX(),_loc1_.getEntranceTileY(),_loc1_.getRotationCount());
            if(isWalkable(_loc2_.x,_loc2_.y))
            {
               _loc3_.push(_loc1_);
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function removeActor(param1:GameUserEmployee) : void
      {
         var _loc2_:EmployeeActor = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:GameUserEmployee = null;
         var _loc7_:int = 0;
         while(_loc7_ < this.employeeActors.length)
         {
            if(this.employeeActors[_loc7_].employeeUser == param1)
            {
               _loc2_ = this.employeeActors[_loc7_];
               this.employeeActors.splice(_loc7_,1);
               break;
            }
            _loc7_++;
         }
         if(_loc2_ != null)
         {
            _loc2_.destroy();
            room.removeObject(_loc2_);
            _loc3_ = this.chefs.indexOf(_loc2_);
            if(_loc3_ != -1)
            {
               this.chefs.splice(_loc3_,1);
               _loc7_ = 0;
               while(_loc7_ < this.employeeActors.length)
               {
                  if(this.employeeActors[_loc7_].emotionType == EmployeeActor.EMOTION_NEED_STOVE)
                  {
                     this.addChef(this.employeeActors[_loc7_].employeeUser);
                     break;
                  }
                  _loc7_++;
               }
            }
            _loc4_ = this.waitors.indexOf(_loc2_);
            if(_loc4_ != -1)
            {
               this.waitors.splice(_loc4_,1);
            }
            _loc5_ = this.cleaners.indexOf(_loc2_);
            if(_loc5_ != -1)
            {
               this.cleaners.splice(_loc5_,1);
            }
            if(_loc2_ is SleepingEmployee)
            {
               _loc7_ = 0;
               while(_loc7_ < gameUser.employeeUsers.length)
               {
                  _loc6_ = gameUser.employeeUsers[_loc7_];
                  if(_loc6_.job == GameUserEmployee.JOB_REST && this.getEmployeeActor(_loc6_) == null)
                  {
                     this.addRestingEmployee(_loc6_);
                     break;
                  }
                  _loc7_++;
               }
            }
         }
      }
      
      public function onHireUser(param1:GameUserEmployee) : void
      {
         if(!this.visitMode)
         {
            this.createEmployeeActor(param1);
            this.refreshRestaurantClosedState();
         }
      }
      
      public function refreshEmployeeCount() : void
      {
         if(this.uiButton.buttonHireFriends)
         {
            if(!this.visitMode)
            {
               this.uiButton.buttonHireFriends.tf_count.mouseEnabled = false;
               this.uiButton.buttonHireFriends.tf_count.text = gameUser.employeeUsers.length + "/" + GameWorld.maxEmployees;
               if(gameUser.employeeUsers.length < GameWorld.maxEmployees)
               {
                  this.uiButton.buttonHireFriends.glowEffect = new GlowEffect(this.uiButton.buttonHireFriends,16777215,0.1,0.8);
               }
               else if(this.uiButton.buttonHireFriends.glowEffect)
               {
                  this.uiButton.buttonHireFriends.glowEffect.remove();
               }
            }
            else if(this.uiButton.buttonHireFriends.glowEffect)
            {
               this.uiButton.buttonHireFriends.glowEffect.remove();
            }
         }
      }
      
      public function clearEmptyPlate(param1:DishOrder) : void
      {
         var _loc2_:GameObject = null;
         room.removeObject(param1);
         this.onCustomerPay(param1);
         if(param1.recipe.type == Recipe.MENU_RECIPE_DRINK)
         {
            _loc2_ = new GameObject("MoneyDrink");
         }
         else
         {
            _loc2_ = new GameObject("Money");
         }
         if(gameUser == GameWorld.gameUser)
         {
            _loc2_.getChildMovieClipInstance("mc_money").tf_money.text = "$" + param1.recipe.cost;
         }
         else
         {
            _loc2_.getChildMovieClipInstance("mc_money").tf_money.visible = false;
         }
         var _loc3_:MovieClip = _loc2_.getChildMovieClipInstance("mc_plate");
         if(_loc3_)
         {
            _loc3_.gotoAndStop(param1.recipe.level);
         }
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         _loc2_.drawPriority = param1.drawPriority;
         _loc2_.numLoops = 1;
         _loc2_.removeWhenComplete = true;
         room.addObject(_loc2_);
         param1.table.tableTopOrder = null;
         param1.table.rcrLiberar(param1);
         param1 = null;
         if(!this.silentTick)
         {
            this.cashSound.play(1);
         }
      }
      
      private function onMenuItemClick(param1:MouseEvent) : void
      {
         if(!moveGesture)
         {
            this.onButtonChangeMenuClick(null);
         }
      }
      
      private function onActorClicked(param1:EmployeeActor) : void
      {
         if(!moveGesture)
         {
            if(!this.visitMode)
            {
               GameWorld.hiredFriendsPanel.showJobPanel(param1.employeeUser);
            }
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         var _loc1_:* = int(this.customers.length - 1);
         while(_loc1_ >= 0)
         {
            this.removeCustomer(this.customers[_loc1_]);
            _loc1_--;
         }
         IsoCacherQueue.clearQueue();
      }
      
      private function calculateServableTables() : void
      {
         var _loc1_:ChefActor = null;
         var _loc2_:Number = NaN;
         var _loc3_:Waitor = null;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:RoomItem = null;
         var _loc7_:Number = 0;
         while(_loc7_ < this.chefs.length)
         {
            this.chefs[_loc7_].clearServableChairs();
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ < this.waitors.length)
         {
            this.waitors[_loc7_].clearServableChairs();
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ < this.chairs.length)
         {
            this.chairs[_loc7_].canOrderDrink = false;
            this.chairs[_loc7_].canOrderFood = false;
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ < this.chefs.length)
         {
            _loc1_ = this.chefs[_loc7_];
            _loc2_ = 0;
            while(_loc2_ < this.waitors.length)
            {
               _loc3_ = this.waitors[_loc2_];
               if(_loc3_.tileX > 0 && _loc3_.tileY > 0)
               {
                  _loc4_ = _loc3_.getPathTo(_loc1_.kitchen.tileX,_loc1_.kitchen.tileY,true);
                  if(_loc4_)
                  {
                     _loc3_.addReachableKitchenItems(_loc1_.kitchen);
                  }
                  _loc5_ = 0;
                  while(_loc5_ < this.chairs.length)
                  {
                     _loc6_ = this.chairs[_loc5_];
                     if(this.hasPathToCustomerChair(_loc3_.tileX,_loc3_.tileY,_loc6_))
                     {
                        _loc3_.addServableChair(_loc6_);
                        if(_loc4_)
                        {
                           _loc1_.addServableChair(_loc6_);
                           _loc6_.canOrderFood = true;
                        }
                     }
                     _loc5_++;
                  }
               }
               _loc2_++;
            }
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ < this.waitors.length)
         {
            _loc3_ = this.waitors[_loc7_];
            _loc2_ = 0;
            while(_loc2_ < this.drinkItems.length)
            {
               if(_loc3_.getPathTo(this.drinkItems[_loc2_].tileX,this.drinkItems[_loc2_].tileY,true) != null)
               {
                  _loc3_.addReachableDrinkItems(this.drinkItems[_loc2_]);
                  _loc5_ = 0;
                  while(_loc5_ < this.chairs.length)
                  {
                     _loc6_ = this.chairs[_loc5_];
                     if(!_loc6_.canOrderDrink && this.hasPathToCustomerChair(_loc3_.tileX,_loc3_.tileY,_loc6_))
                     {
                        _loc6_.canOrderDrink = true;
                     }
                     _loc5_++;
                  }
               }
               _loc2_++;
            }
            _loc7_++;
         }
      }
   }
}

