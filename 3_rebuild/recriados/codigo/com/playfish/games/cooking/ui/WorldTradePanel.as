package com.playfish.games.cooking.ui
{
   import com.playfish.games.cooking.*;
   import com.playfish.games.cooking.events.*;
   import com.playfish.games.cooking.rpc.RpcEvent;
   import com.playfish.games.cooking.rpc.RpcRequestManager;
   import com.playfish.games.cooking.rpc.RpcSendMail;
   import com.playfish.games.cooking.rpc.RpcTradeIngredients;
   import com.playfish.rpc.cooking.RpcClient;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class WorldTradePanel extends WorldPopUp
   {

      // Restaurant City Arquivo (2026-10-28): own-restaurant exchange mode. The server
      // (rpc-store.ts, ownExchangeAllowed) decides every swap; this copy of its rule
      // (3 picks buy 1 of rarity <= their average rounded up) only drives the labels,
      // the tick button and the local inventory after an OK.
      private static const OWN_EXCHANGE_ITEMS:int = 3;

      private var ownExchange:Boolean;

      private var ownPicks:Array = new Array();

      private var traderItem:IngredientItem;
      
      private var trader:GameUser;
      
      private var tradeMenuContent:MovieClip;
      
      private var ingredientItemChooser:IngredientItemChooser;
      
      private var traderIngredientItemChooser:IngredientItemChooser;
      
      private var loadingPopUp:WorldLoadingPopUp;
      
      private var secure:Boolean;
      
      private var userItem:IngredientItem;
      
      public function WorldTradePanel(param1:GameUser, param2:Boolean, param3:Boolean = false)
      {
         var _loc4_:DisplayObject = null;
         super(null,null,null);
         this.trader = param1;
         this.secure = param2;
         this.ownExchange = param3;
         var _loc3_:MovieClip = Engine.getMovieClip("TradePopupAnim");
         addChild(_loc3_);
         this.tradeMenuContent = _loc3_.mc_content;
         if(this.ownExchange)
         {
            this.tradeMenuContent.tf_traderName.text = "";
            this.tradeMenuContent.tf_traderIngredients.text = "Pick a new ingredient:";
            this.tradeMenuContent.mc_icon.gotoAndStop("direct");
            this.showOwnExchangeHelp();
            addFrameIcon(this.tradeMenuContent.mc_frame.mc_face);
         }
         else
         {
            this.tradeMenuContent.tf_traderName.text = param1.firstName;
            GameWorld.textHandler.setReplaceString("friend",param1.firstName);
            GameWorld.textHandler.setTextFieldWithId(this.tradeMenuContent.tf_traderIngredients,"FriendsIngredient");
            GameWorld.textHandler.setTextFieldWithId(this.tradeMenuContent.tf_ingredientTrade,"IngredientTradeDirect");
            this.tradeMenuContent.mc_icon.gotoAndStop("direct");
            _loc4_ = GameWorld.getUserFaceImage(param1);
            if(_loc4_)
            {
               this.tradeMenuContent.mc_frame.mc_face.addChild(_loc4_);
            }
         }
         setButtonMode(this.tradeMenuContent.mc_cancel,true);
         this.tradeMenuContent.mc_cancel.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         setButtonMode(this.tradeMenuContent.mc_swap0,true);
         setButtonMode(this.tradeMenuContent.mc_swap1,true);
         setupIngredientIcon(this.tradeMenuContent.mc_swap0,null);
         setupIngredientIcon(this.tradeMenuContent.mc_swap1,null);
         this.ingredientItemChooser = new IngredientItemChooser(GameWorld.gameUser.ingredients,null,false);
         GameWorld.textHandler.setTextFieldWithId(this.ingredientItemChooser.scene.tf_help,"YourCurrentIngredients");
         this.ingredientItemChooser.x = -this.ingredientItemChooser.width / 2;
         this.ingredientItemChooser.y = Engine.STAGE_HEIGHT / 2;
         this.ingredientItemChooser.addEventListener(ItemChooserEvent.EVENT_ITEM_MOUSE_DOWN,this.onItemClick);
         addObject(this.ingredientItemChooser);
         if(this.ownExchange)
         {
            this.traderIngredientItemChooser = new IngredientItemChooser(ownExchangeCatalog(),this.tradeMenuContent,false,false,false);
         }
         else
         {
            this.traderIngredientItemChooser = new IngredientItemChooser(param1.ingredients,this.tradeMenuContent,false,param2);
         }
         this.traderIngredientItemChooser.addEventListener(ItemChooserEvent.EVENT_ITEM_MOUSE_DOWN,this.onTraderItemClick);
         this.disableTradeConfirm();
         if(this.ownExchange)
         {
            this.tradeMenuContent.mc_swap1.addEventListener(MouseEvent.CLICK,this.onOwnPickRemove,false,0,true);
         }
      }

      // Every ingredient of the client catalog, rarest last, as the "you get" list.
      private static function ownExchangeCatalog() : Array
      {
         var _loc1_:Array = new Array();
         var _loc2_:Array = GameWorld.ingredientItemDatabase.getItems("Ingredient");
         var _loc3_:int = 0;
         while(Boolean(_loc2_) && _loc3_ < _loc2_.length)
         {
            _loc1_.push(new IngredientItem(_loc2_[_loc3_]));
            _loc3_++;
         }
         _loc1_.sortOn(["rarity","name"],[Array.NUMERIC,0]);
         return _loc1_;
      }

      // The trade icon in the face frame, where a friend's photo would go.
      private static function addFrameIcon(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = Engine.getMovieClip("TradeIcon");
         _loc2_.gotoAndStop(1);
         _loc2_.mouseEnabled = false;
         var _loc3_:Rectangle = _loc2_.getBounds(_loc2_);
         _loc2_.scaleX = 50 / Math.max(_loc3_.width,_loc3_.height);
         _loc2_.scaleY = _loc2_.scaleX;
         _loc2_.x = -_loc3_.left * _loc2_.scaleX;
         _loc2_.y = -_loc3_.top * _loc2_.scaleY;
         param1.addChild(_loc2_);
      }

      // Highest rarity the current picks can buy: their average rounded up.
      private function ownPicksMaxRarity() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.ownPicks.length)
         {
            _loc1_ += this.ownPicks[_loc2_].rarity;
            _loc2_++;
         }
         return Math.ceil(_loc1_ / OWN_EXCHANGE_ITEMS);
      }

      private function ownPickCount(param1:IngredientItem) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this.ownPicks.length)
         {
            if(this.ownPicks[_loc3_] == param1)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }

      private function isOwnPick(param1:Object) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.ownPicks.length)
         {
            if(this.ownPicks[_loc2_].itemConfig.id == param1.id)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }

      private function onOwnPickAdd(param1:Object) : void
      {
         var _loc2_:IngredientItem = GameWorld.gameUser.getIngredient(param1);
         if(Boolean(_loc2_) && this.ownPicks.length < OWN_EXCHANGE_ITEMS && this.ownPickCount(_loc2_) < _loc2_.count)
         {
            this.ownPicks.push(_loc2_);
         }
         this.updateOwnExchange();
      }

      // Clicking the "Yours" slot takes back the last pick.
      private function onOwnPickRemove(param1:MouseEvent) : void
      {
         if(this.ownPicks.length > 0)
         {
            this.ownPicks.pop();
         }
         this.updateOwnExchange();
      }

      // Up to three small icons side by side in the "Yours" slot.
      private function drawOwnPicks() : void
      {
         var _loc1_:MovieClip = this.tradeMenuContent.mc_swap1;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:Rectangle = null;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         setupIngredientIcon(_loc1_,null);
         if(this.ownPicks.length == 0)
         {
            return;
         }
         _loc5_ = _loc1_.width * 0.3;
         _loc2_ = new MovieClip();
         _loc2_.mouseEnabled = false;
         _loc2_.mouseChildren = false;
         while(_loc6_ < this.ownPicks.length)
         {
            _loc3_ = Engine.getMovieClip(this.ownPicks[_loc6_].className);
            _loc3_.stop();
            _loc4_ = _loc3_.getBounds(_loc3_);
            _loc3_.scaleX = _loc5_ / Math.max(_loc4_.width,_loc4_.height);
            _loc3_.scaleY = _loc3_.scaleX;
            _loc3_.x = (_loc6_ - 1) * _loc5_ * 1.05 - (_loc4_.left + _loc4_.width / 2) * _loc3_.scaleX;
            _loc3_.y = -(_loc4_.top + _loc4_.height / 2) * _loc3_.scaleY;
            _loc2_.addChild(_loc3_);
            _loc6_++;
         }
         _loc1_.image = _loc2_;
         _loc1_.mc_base.addChild(_loc2_);
      }

      private function showOwnExchangeHelp() : void
      {
         this.tradeMenuContent.tf_ingredientTrade.text = "Ingredient Swap: " + OWN_EXCHANGE_ITEMS + " for 1";
      }

      private function updateOwnExchange() : void
      {
         var _loc1_:int = 0;
         this.drawOwnPicks();
         this.tradeMenuContent.tf_traderName.text = this.traderItem ? this.traderItem.name : "";
         this.disableTradeConfirm();
         if(this.ownPicks.length == 0)
         {
            this.showOwnExchangeHelp();
            return;
         }
         if(this.ownPicks.length < OWN_EXCHANGE_ITEMS)
         {
            this.tradeMenuContent.tf_ingredientTrade.text = "Pick " + OWN_EXCHANGE_ITEMS + " of yours: " + this.ownPicks.length + "/" + OWN_EXCHANGE_ITEMS;
            return;
         }
         _loc1_ = this.ownPicksMaxRarity();
         if(!this.traderItem)
         {
            this.tradeMenuContent.tf_ingredientTrade.text = "Now pick up to " + _loc1_ + " stars";
            return;
         }
         if(this.isOwnPick(this.traderItem.itemConfig))
         {
            this.tradeMenuContent.tf_ingredientTrade.text = "Pick a different one";
            return;
         }
         if(this.traderItem.rarity > _loc1_)
         {
            this.tradeMenuContent.tf_ingredientTrade.text = "Too rare: max " + _loc1_ + " stars";
            return;
         }
         this.showOwnExchangeHelp();
         this.enableTradeConfirm();
      }

      private function resetOwnExchange() : void
      {
         setupIngredientIcon(this.tradeMenuContent.mc_swap0,null);
         this.ownPicks = new Array();
         this.traderItem = null;
         this.updateOwnExchange();
      }

      private function onOwnExchangeTick() : void
      {
         var _loc1_:RpcRequestManager = null;
         var _loc2_:RpcTradeIngredients = null;
         this.disableTradeConfirm();
         // Market buys and harvests reach the server through saveProfile: send them first.
         GameWorld.forceAutoSave();
         this.loadingPopUp = new WorldLoadingPopUp("Trading...",WorldLoadingPopUp.TRADING);
         this.loadingPopUp.x = GameWorld.CANVAS_CENTER_X;
         this.loadingPopUp.y = GameWorld.CANVAS_CENTER_Y;
         _loc1_ = new RpcRequestManager();
         _loc1_.loadingPopUp = this.loadingPopUp;
         _loc1_.keepLoadingPopUpOnSuccess = true;
         _loc1_.retryText = GameWorld.textHandler.getTextFromId("TradingRetryText");
         _loc2_ = _loc1_.tradeIngredients(GameWorld.gameUser.userInfo.id,{"hash":this.ownPicksToken()},this.traderItem.itemConfig,false);
         _loc2_.addEventListener(RpcEvent.SUCCESS,this.onOwnExchangeSuccess);
         _loc1_.commit();
      }

      // The offered hashes joined by "," (rpc-store.ts OWN_EXCHANGE_SEPARATOR).
      private function ownPicksToken() : String
      {
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.ownPicks.length)
         {
            _loc1_.push(this.ownPicks[_loc2_].itemConfig.hash);
            _loc2_++;
         }
         return _loc1_.join(",");
      }

      private function onOwnExchangeSuccess(param1:RpcEvent) : void
      {
         var _loc2_:RpcRequestManager = null;
         var _loc3_:int = 0;
         if(param1.successCode == RpcClient.STATUS_OK)
         {
            this.loadingPopUp.remove();
            this.loadingPopUp = null;
            while(_loc3_ < this.ownPicks.length)
            {
               GameWorld.gameUser.removeIngredient(this.ownPicks[_loc3_].itemConfig,1);
               _loc3_++;
            }
            GameWorld.gameUser.addIngredient(this.traderItem.itemConfig,1);
            this.ingredientItemChooser.refresh(GameWorld.gameUser.ingredients);
            this.resetOwnExchange();
         }
         else
         {
            _loc2_ = new RpcRequestManager();
            _loc2_.loadingPopUp = this.loadingPopUp;
            _loc2_.retryText = GameWorld.textHandler.getTextFromId("TradingRetryText");
            _loc2_.addEventListener(RpcEvent.SUCCESS,this.onOwnExchangeReloaded);
            _loc2_.getFriendsDetails([GameWorld.gameUser],GameUser.ITEM_CONTEXT_INGREDIENT,true);
            _loc2_.commit();
         }
      }

      private function onOwnExchangeReloaded(param1:RpcEvent) : void
      {
         this.ingredientItemChooser.refresh(GameWorld.gameUser.ingredients);
         this.resetOwnExchange();
         var _loc2_:WorldInfoPopUp = new WorldInfoPopUp("That swap is no longer possible. Your ingredients were reloaded.");
         _loc2_.show();
      }
      
      public static function setupIngredientIcon(param1:MovieClip, param2:Object, param3:Boolean = false) : void
      {
         var _loc4_:MovieClip = null;
         _loc4_ = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Rectangle = null;
         if(param1.image != null)
         {
            param1.mc_base.removeChild(param1.image);
            param1.image = null;
         }
         param1.tf_count.text = "";
         param1.mc_crate.visible = false;
         param1.mc_lock.visible = false;
         if(param2)
         {
            _loc4_ = Engine.getMovieClip(param2.className);
            _loc4_.stop();
            _loc5_ = param1.width * 0.6;
            _loc6_ = param1.height * 0.6;
            if(_loc4_.width > _loc4_.height)
            {
               _loc4_.scaleX = _loc5_ / _loc4_.width;
               _loc4_.scaleY = _loc4_.scaleX;
            }
            else
            {
               _loc4_.scaleY = _loc6_ / _loc4_.height;
               _loc4_.scaleX = _loc4_.scaleY;
            }
            _loc7_ = _loc4_.getBounds(null);
            _loc4_.x = _loc4_.x - _loc7_.left * _loc4_.scaleX - _loc4_.width / 2;
            _loc4_.y = _loc4_.y - _loc7_.top * _loc4_.scaleY - _loc4_.height / 2;
            param1.itemConfig = param2;
            param1.image = _loc4_;
            param1.mc_rarity.visible = true;
            param1.mc_rarity.gotoAndStop(param2.rarity);
            param1.mc_base.addChild(_loc4_);
            if(param3)
            {
               param1.mc_lock.visible = true;
            }
         }
         else
         {
            param1.itemConfig = null;
            param1.image = null;
            param1.mc_rarity.gotoAndStop(1);
            param1.mc_rarity.visible = false;
         }
      }
      
      private function disableTradeConfirm() : void
      {
         setButtonMode(this.tradeMenuContent.mc_tick,false);
         this.tradeMenuContent.mc_tick.gotoAndStop("grey");
         this.tradeMenuContent.mc_tick.removeEventListener(MouseEvent.CLICK,this.onTickClick);
      }
      
      private function onTickClick(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:DisplayObject = null;
         var _loc5_:WorldPopUp = null;
         var _loc6_:RpcRequestManager = null;
         var _loc7_:RpcTradeIngredients = null;
         if(this.ownExchange)
         {
            if(this.ownPicks.length == OWN_EXCHANGE_ITEMS && Boolean(this.traderItem))
            {
               this.onOwnExchangeTick();
            }
            return;
         }
         if(Boolean(this.userItem) && Boolean(this.traderItem))
         {
            this.disableTradeConfirm();
            this.secure = this.isSecureTrade();
            if(GameWorld.saveProfileHandler.isIngredientHarvested(this.userItem.itemConfig))
            {
               GameWorld.forceAutoSave();
            }
            if(this.secure)
            {
               _loc2_ = Engine.getMovieClip("TradeConfirmationPopup");
               _loc3_ = _loc2_.mc_content;
               GameWorld.textHandler.setTextFieldWithId(_loc3_.tf_title,"SendTradeRequest");
               GameWorld.textHandler.setTextFieldWithId(_loc3_.tf_text,"SendTradeRequestBody");
               _loc3_.mc_playerPanel.stop();
               _loc3_.mc_playerPanel.tf_name.text = GameWorld.gameUser.fullName;
               _loc4_ = GameWorld.getUserFaceImage(GameWorld.gameUser);
               if(_loc4_ != null)
               {
                  _loc3_.mc_playerPanel.mc_frame.mc_face.addChild(_loc4_);
               }
               _loc3_.mc_senderPanel.stop();
               _loc3_.mc_senderPanel.tf_name.text = this.trader.fullName;
               _loc4_ = GameWorld.getUserFaceImage(this.trader);
               if(_loc4_ != null)
               {
                  _loc3_.mc_senderPanel.mc_frame.mc_face.addChild(_loc4_);
               }
               _loc3_.mc_playerItem.stop();
               _loc3_.mc_senderItem.stop();
               WorldTradePanel.setupIngredientIcon(_loc3_.mc_playerItem,this.userItem.itemConfig,this.userItem.lock);
               WorldTradePanel.setupIngredientIcon(_loc3_.mc_senderItem,this.traderItem.itemConfig,this.traderItem.lock);
               _loc3_.mc_tick.addEventListener(MouseEvent.CLICK,this.onTradeRequestSendOK,false,0,true);
               _loc5_ = new WorldPopUp(_loc2_,_loc3_.mc_tick,_loc3_.mc_cancel);
               _loc5_.show();
            }
            else
            {
               this.loadingPopUp = new WorldLoadingPopUp("Trading...",WorldLoadingPopUp.TRADING);
               this.loadingPopUp.x = GameWorld.CANVAS_CENTER_X;
               this.loadingPopUp.y = GameWorld.CANVAS_CENTER_Y;
               _loc6_ = new RpcRequestManager();
               _loc6_.loadingPopUp = this.loadingPopUp;
               _loc6_.keepLoadingPopUpOnSuccess = true;
               _loc6_.retryText = GameWorld.textHandler.getTextFromId("TradingRetryText");
               _loc7_ = _loc6_.tradeIngredients(this.trader.userInfo.id,this.userItem.itemConfig,this.traderItem.itemConfig,false);
               _loc7_.addEventListener(RpcEvent.SUCCESS,this.onTradeIngredientSuccess);
               _loc6_.commit();
            }
         }
      }
      
      private function onTradeRequestSendOK(param1:MouseEvent) : void
      {
         MovieClip(param1.currentTarget).removeEventListener(MouseEvent.CLICK,this.onTradeRequestSendOK);
         this.loadingPopUp = new WorldLoadingPopUp("Trading...",WorldLoadingPopUp.SECURE_TRADE);
         this.loadingPopUp.x = GameWorld.CANVAS_CENTER_X;
         this.loadingPopUp.y = GameWorld.CANVAS_CENTER_Y;
         var _loc2_:RpcRequestManager = new RpcRequestManager();
         _loc2_.loadingPopUp = this.loadingPopUp;
         _loc2_.keepLoadingPopUpOnSuccess = true;
         _loc2_.retryText = GameWorld.textHandler.getTextFromId("TradingRetryText");
         var _loc3_:RpcSendMail = _loc2_.sendMail(this.trader.userInfo.id,"",null,this.userItem,this.traderItem);
         _loc3_.addEventListener(RpcEvent.SUCCESS,this.onTradeRequestSuccess);
         _loc2_.commit();
      }
      
      private function onCancelClick(param1:MouseEvent) : void
      {
         remove();
      }
      
      private function onReloadIngredientsSuccess(param1:RpcEvent) : void
      {
         this.ingredientItemChooser.refresh(GameWorld.gameUser.ingredients);
         this.traderIngredientItemChooser.refresh(this.trader.ingredients);
         setupIngredientIcon(this.tradeMenuContent.mc_swap0,null);
         setupIngredientIcon(this.tradeMenuContent.mc_swap1,null);
         this.userItem = null;
         this.traderItem = null;
         this.disableTradeConfirm();
         var _loc2_:WorldInfoPopUp = new WorldInfoPopUp(GameWorld.textHandler.getTextFromId("TradedIngredientNoLongerAvailable"));
         _loc2_.show();
      }
      
      private function onItemClick(param1:ItemChooserEvent) : void
      {
         if(this.ownExchange)
         {
            this.onOwnPickAdd(param1.itemConfig);
            return;
         }
         this.userItem = GameWorld.gameUser.getIngredient(param1.itemConfig);
         setupIngredientIcon(this.tradeMenuContent.mc_swap1,this.userItem.itemConfig,this.userItem.lock);
         if(Boolean(this.userItem) && Boolean(this.traderItem))
         {
            this.enableTradeConfirm();
         }
         else
         {
            this.disableTradeConfirm();
         }
      }
      
      private function enableTradeConfirm() : void
      {
         setButtonMode(this.tradeMenuContent.mc_tick,true);
         this.tradeMenuContent.mc_tick.addEventListener(MouseEvent.CLICK,this.onTickClick,false,0,true);
         if(this.ownExchange)
         {
            return;
         }
         if(this.isSecureTrade())
         {
            GameWorld.textHandler.setTextFieldWithId(this.tradeMenuContent.tf_ingredientTrade,"IngredientTradeRequest");
            this.tradeMenuContent.mc_icon.gotoAndStop("locked");
         }
         else
         {
            GameWorld.textHandler.setTextFieldWithId(this.tradeMenuContent.tf_ingredientTrade,"IngredientTradeDirect");
            this.tradeMenuContent.mc_icon.gotoAndStop("direct");
         }
      }
      
      private function isSecureTrade() : Boolean
      {
         return this.traderItem.lock || this.userItem.rarity < this.traderItem.rarity;
      }
      
      private function onTradeRequestSuccess(param1:RpcEvent) : void
      {
         var _loc2_:RpcRequestManager = null;
         Debug.out("onTradeRequestSuccess success=" + param1.successCode);
         if(param1.successCode == RpcClient.STATUS_OK)
         {
            this.loadingPopUp.remove();
            this.loadingPopUp = null;
            setupIngredientIcon(this.tradeMenuContent.mc_swap0,null);
            setupIngredientIcon(this.tradeMenuContent.mc_swap1,null);
            GameWorld.addAwardValue(GameAwards.AWARD_TRADE,1);
            GameWorld.addGourmetPoints(this.userItem.rarity * GameWorld.GOURMET_POINTS_PER_TRADE_RARITY);
            this.userItem = null;
            this.traderItem = null;
            this.disableTradeConfirm();
         }
         else
         {
            _loc2_ = new RpcRequestManager();
            _loc2_.loadingPopUp = this.loadingPopUp;
            _loc2_.retryText = GameWorld.textHandler.getTextFromId("TradingRetryText");
            _loc2_.addEventListener(RpcEvent.SUCCESS,this.onReloadIngredientsSuccess);
            _loc2_.getFriendsDetails([GameWorld.gameUser,this.trader],GameUser.ITEM_CONTEXT_INGREDIENT,true);
            _loc2_.commit();
         }
      }
      
      private function onTradeIngredientSuccess(param1:RpcEvent) : void
      {
         var _loc2_:RpcRequestManager = null;
         Debug.out("onTradeIngredientSuccess success=" + param1.successCode);
         if(param1.successCode == RpcClient.STATUS_OK)
         {
            this.loadingPopUp.remove();
            this.loadingPopUp = null;
            GameWorld.gameUser.removeIngredient(this.userItem.itemConfig,1);
            this.trader.addIngredient(this.userItem.itemConfig,1);
            this.trader.removeIngredient(this.traderItem.itemConfig,1);
            GameWorld.gameUser.addIngredient(this.traderItem.itemConfig,1);
            GameWorld.gameUser.getIngredient(this.traderItem.itemConfig).lock = true;
            this.trader.getIngredient(this.userItem.itemConfig).lock = true;
            this.ingredientItemChooser.refresh(GameWorld.gameUser.ingredients);
            this.traderIngredientItemChooser.refresh(this.trader.ingredients);
            setupIngredientIcon(this.tradeMenuContent.mc_swap0,null);
            setupIngredientIcon(this.tradeMenuContent.mc_swap1,null);
            GameWorld.addAwardValue(GameAwards.AWARD_TRADE,1);
            GameWorld.addGourmetPoints(this.userItem.rarity * GameWorld.GOURMET_POINTS_PER_TRADE_RARITY);
            this.userItem = null;
            this.traderItem = null;
            this.disableTradeConfirm();
         }
         else
         {
            _loc2_ = new RpcRequestManager();
            _loc2_.loadingPopUp = this.loadingPopUp;
            _loc2_.retryText = GameWorld.textHandler.getTextFromId("TradingRetryText");
            _loc2_.addEventListener(RpcEvent.SUCCESS,this.onReloadIngredientsSuccess);
            _loc2_.getFriendsDetails([GameWorld.gameUser,this.trader],GameUser.ITEM_CONTEXT_INGREDIENT,true);
            _loc2_.commit();
         }
      }
      
      private function onTraderItemClick(param1:ItemChooserEvent) : void
      {
         if(this.ownExchange)
         {
            this.traderItem = new IngredientItem(param1.itemConfig);
            setupIngredientIcon(this.tradeMenuContent.mc_swap0,this.traderItem.itemConfig);
            this.updateOwnExchange();
            return;
         }
         var _loc2_:IngredientItem = this.trader.getIngredient(param1.itemConfig);
         this.traderItem = _loc2_;
         setupIngredientIcon(this.tradeMenuContent.mc_swap0,this.traderItem.itemConfig,this.traderItem.lock);
         if(Boolean(this.userItem) && Boolean(this.traderItem))
         {
            this.enableTradeConfirm();
         }
         else
         {
            this.disableTradeConfirm();
         }
      }
   }
}

