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
      
      private var traderItem:IngredientItem;
      
      private var trader:GameUser;
      
      private var tradeMenuContent:MovieClip;
      
      private var ingredientItemChooser:IngredientItemChooser;
      
      private var traderIngredientItemChooser:IngredientItemChooser;
      
      private var loadingPopUp:WorldLoadingPopUp;
      
      private var secure:Boolean;
      
      private var userItem:IngredientItem;
      
      public function WorldTradePanel(param1:GameUser, param2:Boolean)
      {
         super(null,null,null);
         this.trader = param1;
         this.secure = param2;
         var _loc3_:MovieClip = Engine.getMovieClip("TradePopupAnim");
         addChild(_loc3_);
         this.tradeMenuContent = _loc3_.mc_content;
         this.tradeMenuContent.tf_traderName.text = param1.firstName;
         GameWorld.textHandler.setReplaceString("friend",param1.firstName);
         GameWorld.textHandler.setTextFieldWithId(this.tradeMenuContent.tf_traderIngredients,"FriendsIngredient");
         GameWorld.textHandler.setTextFieldWithId(this.tradeMenuContent.tf_ingredientTrade,"IngredientTradeDirect");
         this.tradeMenuContent.mc_icon.gotoAndStop("direct");
         var _loc4_:DisplayObject = GameWorld.getUserFaceImage(param1);
         if(_loc4_)
         {
            this.tradeMenuContent.mc_frame.mc_face.addChild(_loc4_);
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
         this.traderIngredientItemChooser = new IngredientItemChooser(param1.ingredients,this.tradeMenuContent,false,param2);
         this.traderIngredientItemChooser.addEventListener(ItemChooserEvent.EVENT_ITEM_MOUSE_DOWN,this.onTraderItemClick);
         this.disableTradeConfirm();
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

