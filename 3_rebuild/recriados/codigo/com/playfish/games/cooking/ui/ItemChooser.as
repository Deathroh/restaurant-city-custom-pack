package com.playfish.games.cooking.ui
{
   import com.playfish.games.cooking.*;
   import com.playfish.games.cooking.debug.DebugShowAllShopItems;
   import com.playfish.games.cooking.events.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Rectangle;
   import flash.text.*;
   import flash.utils.getQualifiedClassName;
   
   public class ItemChooser extends BaseObject
   {
      
      public static var currentBuildingTileClassName:String;
      
      private static const ICON_WIDTH:int = 65;
      
      private static const ICON_HEIGHT:int = 65;
      
      private static const GREY_FILTER_MATRIX:Array = [0.3,0.3,0.3,0,70,0.3,0.3,0.3,0,70,0.3,0.3,0.3,0,70,0,0,0,1,0];
      
      public static const TAB_NEW:int = 0;
      
      public static const TAB_SHOP:int = 1;
      
      public static const TAB_OWN:int = 2;
      
      public static const TAB_CASH:int = 3;
      
      public var giftButton:MovieClip;
      
      private var groupButtons:Array = new Array();
      
      private var scene:MovieClip;
      
      public var leftButton:MovieClip;
      
      private var curGroup:Object;
      
      public var sellButton:MovieClip;
      
      public var tabButtons:Array = new Array();
      
      private var curGroupButton:MovieClip;
      
      private var curTab:int = -1;
      
      public var enableDragInstructionToolTip:Boolean;
      
      private var curGroupItemConfigs:Array;
      
      private var dragInstructionToolTip:ToolTip;
      
      private var gameUser:GameUser;
      
      private var itemDescriptionTextField:TextField;
      
      public var selectedItems:Array;
      
      private var itemsPerPage:int = 0;
      
      public var rightButton:MovieClip;
      
      private var curPage:int = 0;
      
      private var itemButtons:Array = new Array();
      
      public function ItemChooser(param1:ItemDatabase, param2:GameUser, param3:MovieClip, param4:TextField = null)
      {
         var _loc5_:MovieClip = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:MovieClip = null;
         super();
         this.scene = param3;
         this.gameUser = param2;
         if(!param3.parent)
         {
            addChild(param3);
         }
         this.itemDescriptionTextField = param4;
         if(param4)
         {
            param4.text = "";
         }
         var _loc9_:Number = 0;
         while(_loc9_ < param1.itemGroups.length)
         {
            _loc6_ = param1.itemGroups[_loc9_].buttonName;
            _loc7_ = param1.itemGroups[_loc9_].name;
            if(_loc6_ == null)
            {
               _loc6_ = _loc7_;
            }
            _loc8_ = param3["tab" + _loc6_];
            if(_loc8_ != null)
            {
               this.groupButtons.push(_loc8_);
               setButtonMode(_loc8_,true);
               _loc8_.group = param1.itemGroups[_loc9_];
               _loc8_.addEventListener(MouseEvent.CLICK,this.groupButtonClicked,false,0,true);
               _loc8_.tooltip = new ToolTip(_loc8_,_loc7_);
               _loc8_.groupName = _loc6_;
            }
            _loc9_++;
         }
         if(param3.mc_tabNew)
         {
            this.tabButtons[TAB_NEW] = param3.mc_tabNew;
            this.tabButtons[TAB_NEW].tooltip = new ToolTip(this.tabButtons[TAB_NEW],GameWorld.textHandler.getTextFromId("ToolTipNewThisWeek"));
            this.tabButtons[TAB_SHOP] = param3.mc_tabShop;
            this.tabButtons[TAB_SHOP].tooltip = new ToolTip(this.tabButtons[TAB_SHOP],GameWorld.textHandler.getTextFromId("ToolTipShop"));
            this.tabButtons[TAB_OWN] = param3.mc_tabOwn;
            this.tabButtons[TAB_OWN].tooltip = new ToolTip(this.tabButtons[TAB_OWN],GameWorld.textHandler.getTextFromId("ToolTipYourItems"));
            this.tabButtons[TAB_CASH] = param3.mc_tabCash;
            this.tabButtons[TAB_CASH].tooltip = new ToolTip(this.tabButtons[TAB_CASH],GameWorld.textHandler.getTextFromId("ToolTipCashShop"));
            _loc9_ = 0;
            while(_loc9_ < this.tabButtons.length)
            {
               this.tabButtons[_loc9_].index = _loc9_;
               setButtonMode(this.tabButtons[_loc9_],true);
               this.tabButtons[_loc9_].addEventListener(MouseEvent.CLICK,this.onTabClick,false,0,true);
               _loc9_++;
            }
            this.setTab(TAB_SHOP);
         }
         else
         {
            this.setTab(TAB_SHOP);
         }
         while(true)
         {
            _loc5_ = param3["mc_item" + this.itemsPerPage];
            if(!_loc5_)
            {
               break;
            }
            if(_loc5_)
            {
               this.itemButtons.push(_loc5_);
               _loc5_.stop();
            }
            ++this.itemsPerPage;
         }
         this.leftButton = param3.mc_left;
         this.rightButton = param3.mc_right;
         if(param3.mc_left)
         {
            setButtonMode(param3.mc_left,true);
            this.leftButton.addEventListener(MouseEvent.MOUSE_DOWN,this.onLeft1MouseDown,false,0,true);
         }
         if(param3.mc_right)
         {
            setButtonMode(param3.mc_right,true);
            this.rightButton.addEventListener(MouseEvent.MOUSE_DOWN,this.onRight1MouseDown,false,0,true);
         }
         if(param3.mc_gift)
         {
            this.giftButton = param3.mc_gift;
            setButtonMode(this.giftButton,true);
            param3.mc_gift.toolTip = new ToolTip(param3.mc_gift,GameWorld.textHandler.getTextFromId("ToolTipGiftFriend"));
            param3.mc_gift.addEventListener(MouseEvent.CLICK,this.onGiftClick,false,0,true);
         }
         if(param3.mc_sell)
         {
            this.sellButton = param3.mc_sell;
            setButtonMode(this.sellButton,true);
            param3.mc_sell.toolTip = new ToolTip(param3.mc_sell,GameWorld.textHandler.getTextFromId("ToolTipSellAnItem"));
            param3.mc_sell.addEventListener(MouseEvent.CLICK,this.onSellClick,false,0,true);
         }
      }
      
      public static function setItemOnIconButton(param1:Object, param2:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         param2.stop();
         var _loc4_:MovieClip = getItemMovieClip(param1);
         if(_loc4_)
         {
            param2.image = _loc4_;
            param2.addChild(_loc4_);
            _loc3_ = Engine.getMovieClip(getQualifiedClassName(param2));
            _loc3_.stop();
            _loc4_.mask = _loc3_;
            param2.addChild(_loc3_);
         }
      }
      
      public static function getItemMovieClip(param1:Object, param2:Number = 65, param3:Number = 65) : MovieClip
      {
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = null;
         _loc4_ = null;
         _loc5_ = null;
         var _loc6_:Rectangle = null;
         var _loc7_:MovieClip = null;
         var _loc8_:Rectangle = null;
         var _loc9_:int = 0;
         var _loc10_:MovieClip = null;
         var _loc11_:MovieClip = null;
         if(param1.iconName)
         {
            _loc11_ = Engine.getMovieClip(param1.iconName);
            _loc4_ = _loc11_["mc_texture"];
            if(_loc4_)
            {
               _loc5_ = Engine.getMovieClip(param1.className);
               _loc6_ = _loc5_.getBounds(null);
               _loc5_.width = _loc4_.width;
               _loc5_.height = _loc4_.height;
               _loc5_.x = -_loc5_.width / 2;
               _loc5_.y = -_loc5_.height / 2;
               _loc4_.addChild(_loc5_);
            }
         }
         else if(param1.className)
         {
            if(Boolean(param1.group) && param1.group.name == "Body")
            {
               _loc11_ = getBodyItemMovieClip(param1);
            }
            else
            {
               _loc11_ = Engine.getMovieClip(param1.className);
            }
         }
         else if(param1.texture)
         {
            _loc11_ = Engine.getMovieClip(param1.texture);
         }
         if(_loc11_)
         {
            if(GameWorld.getItemType(param1.id) == GameUser.ITEM_TYPE_RESTAURANT)
            {
               _loc11_.stop();
               _loc9_ = 0;
               while(true)
               {
                  _loc10_ = _loc11_["sub" + _loc9_];
                  if(!_loc10_)
                  {
                     break;
                  }
                  _loc10_.stop();
                  _loc9_++;
               }
            }
            _loc11_.mouseEnabled = false;
            _loc11_.mouseChildren = false;
            _loc7_ = _loc11_["mc_rect"];
            if(_loc7_)
            {
               if(Boolean(param1.group) && param1.group.name == "Body" && _loc7_.parent == _loc11_)
               {
                  _loc11_.removeChild(_loc7_);
               }
               else
               {
                  _loc7_.visible = false;
               }
            }
            if(_loc11_["mc_mask"] != null)
            {
               _loc11_["mc_mask"].visible = false;
            }
            _loc8_ = GameWorld.getVisibleBound(_loc11_);
            if(_loc8_.width > _loc8_.height)
            {
               _loc11_.scaleX = param2 / _loc8_.width;
               _loc11_.scaleY = _loc11_.scaleX;
            }
            else
            {
               _loc11_.scaleY = param3 / _loc8_.height;
               _loc11_.scaleX = _loc11_.scaleY;
            }
            _loc11_.x = _loc11_.x - _loc8_.left * _loc11_.scaleX - _loc8_.width * _loc11_.scaleX / 2;
            _loc11_.y = _loc11_.y - _loc8_.top * _loc11_.scaleY - _loc8_.height * _loc11_.scaleY / 2;
         }
         return _loc11_;
      }
      
      private static function getBodyItemMovieClip(param1:Object) : MovieClip
      {
         var _loc2_:Sprite = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = Engine.getMovieClip(param1.className);
         if(!_loc4_)
         {
            return null;
         }
         var _loc5_:MovieClip = _loc4_["mc_rect"];
         if(_loc5_)
         {
            if(_loc5_.parent == _loc4_)
            {
               _loc4_.removeChild(_loc5_);
            }
            else
            {
               _loc5_.visible = false;
            }
         }
         var _loc6_:MovieClip = Engine.getMovieClip(getCurrentBuildingTileClassName());
         if(!_loc6_)
         {
            return _loc4_;
         }
         var _loc7_:Rectangle = _loc4_.getBounds(null);
         _loc2_ = new Sprite();
         _loc3_ = new MovieClip();
         _loc3_.tileBitmapData = new BitmapData(Math.max(1,_loc6_.width),Math.max(1,_loc6_.height),true,0);
         _loc3_.tileBitmapData.draw(_loc6_);
         _loc2_.graphics.beginBitmapFill(_loc3_.tileBitmapData,null,true,false);
         _loc2_.graphics.drawRect(_loc7_.left,_loc7_.top,_loc7_.width,_loc7_.height);
         _loc2_.graphics.endFill();
         _loc2_.mask = _loc4_;
         _loc3_.addChild(_loc2_);
         _loc3_.addChild(_loc4_);
         return _loc3_;
      }
      
      private static function getCurrentBuildingTileClassName() : String
      {
         var _loc1_:UserItem = null;
         var _loc2_:int = 0;
         if(currentBuildingTileClassName)
         {
            return currentBuildingTileClassName;
         }
         if(GameWorld.gameUser)
         {
            while(_loc2_ < GameWorld.gameUser.usedBuildingItems.length)
            {
               _loc1_ = GameWorld.gameUser.usedBuildingItems[_loc2_];
               if(Boolean(_loc1_.itemConfig) && Boolean(_loc1_.itemConfig.group) && _loc1_.itemConfig.group.name == "Tile")
               {
                  return _loc1_.itemConfig.className;
               }
               _loc2_++;
            }
         }
         return "Tile09";
      }
      
      private function compareShopItems(param1:Object, param2:Object) : int
      {
         if(param1.cost == 0 && param1.cash == 0)
         {
            if(param2.cost == 0 && param2.cash == 0)
            {
               return 0;
            }
            return -1;
         }
         if(param1.isLimited)
         {
            if(!param2.isLimited)
            {
               return -1;
            }
         }
         else if(param1.isNew)
         {
            if(param2.isLimited)
            {
               return 1;
            }
            if(!param2.isNew)
            {
               return -1;
            }
         }
         else if(Boolean(param2.isLimited) || Boolean(param2.isNew))
         {
            return 1;
         }
         var _loc3_:int = int(param1.cost);
         var _loc4_:int = int(param2.cost);
         if(_loc3_ < _loc4_)
         {
            return -1;
         }
         if(_loc3_ > _loc4_)
         {
            return 1;
         }
         _loc3_ = int(param1.cash);
         _loc4_ = int(param2.cash);
         if(_loc3_ < _loc4_)
         {
            return -1;
         }
         if(_loc3_ > _loc4_)
         {
            return 1;
         }
         return 0;
      }
      
      private function getGroupButton(param1:Object) : MovieClip
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.groupButtons.length)
         {
            if(this.groupButtons[_loc2_].group == param1)
            {
               return this.groupButtons[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      private function onIconRollOver(param1:MouseEvent) : void
      {
         GameWorld.textHandler.setTextField(this.itemDescriptionTextField,param1.currentTarget.itemConfig.text);
      }
      
      private function onItemButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:ItemChooserEvent = null;
         var _loc3_:MovieClip = MovieClip(param1.currentTarget);
         if(hasEventListener(ItemChooserEvent.EVENT_ITEM_CLICK))
         {
            _loc2_ = new ItemChooserEvent(ItemChooserEvent.EVENT_ITEM_CLICK);
            _loc2_.itemConfig = _loc3_.itemConfig;
            dispatchEvent(_loc2_);
         }
         if(this.enableDragInstructionToolTip)
         {
            if(this.dragInstructionToolTip)
            {
               this.dragInstructionToolTip.remove();
            }
            this.dragInstructionToolTip = new ToolTip(_loc3_,GameWorld.textHandler.getTextFromId("ToolTipDragItemIntoGame"),false,false,false);
            this.dragInstructionToolTip.show();
            if(_loc3_.tooltip)
            {
               _loc3_.tooltip.remove();
            }
            _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.onDragInstructionToolTipRemove,false,0,true);
         }
         param1.stopImmediatePropagation();
      }
      
      private function onInfoClick(param1:MouseEvent) : void
      {
         var _loc2_:WorldItemInfoPopUp = new WorldItemInfoPopUp(param1.currentTarget.itemConfig,null);
         _loc2_.show();
         param1.stopImmediatePropagation();
      }
      
      private function isItemSelected(param1:Object) : Boolean
      {
         var _loc2_:Number = NaN;
         if(this.selectedItems)
         {
            _loc2_ = 0;
            while(_loc2_ < this.selectedItems.length)
            {
               if(this.selectedItems[_loc2_].itemConfig.id == param1.id)
               {
                  return true;
               }
               _loc2_++;
            }
         }
         return false;
      }
      
      private function onGiftClick(param1:MouseEvent) : void
      {
         var _loc2_:WorldInfoPopUp = new WorldInfoPopUp(GameWorld.textHandler.getTextFromId("GiftItemInstruction"));
         _loc2_.x = GameWorld.CANVAS_CENTER_X;
         _loc2_.y = GameWorld.CANVAS_CENTER_Y;
         _loc2_.show();
      }
      
      // RCR: item de epoca (Halloween, Natal, Valentine) tem no catalogo rcrEpoca="MM-DD:MM-DD", posto pelo
      // aplicar_catalogo a partir de recriados/epocas.json. Fora da janela ele some da loja, como um invisible;
      // quem ja tem continua vendo no inventario. Vale a data do computador do jogador; a janela pode virar o ano.
      private static function rcrNaEpoca(param1:Object) : Boolean
      {
         if(!param1.rcrEpoca)
         {
            return true;
         }
         var _loc2_:Array = String(param1.rcrEpoca).split(":");
         var _loc3_:Date = new Date();
         var _loc4_:int = (_loc3_.month + 1) * 100 + _loc3_.date;
         var _loc5_:int = int(String(_loc2_[0]).replace("-",""));
         var _loc6_:int = int(String(_loc2_[1]).replace("-",""));
         if(_loc5_ <= _loc6_)
         {
            return _loc4_ >= _loc5_ && _loc4_ <= _loc6_;
         }
         return _loc4_ >= _loc5_ || _loc4_ <= _loc6_;
      }

      private function getItemConfigsInGroup(param1:Object) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Array = new Array();
         if(param1 != null)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.items.length)
            {
               _loc3_ = param1.items[_loc2_];
               if(Debug.DEBUG && DebugShowAllShopItems.on)
               {
                  _loc4_.push(_loc3_);
               }
               else if(this.curTab == TAB_OWN)
               {
                  if(this.gameUser.getInventoryItemCount(_loc3_) > 0)
                  {
                     _loc4_.push(_loc3_);
                  }
               }
               else if(!_loc3_.invisible && rcrNaEpoca(_loc3_) || this.gameUser.getInventoryItemCount(_loc3_) > 0)
               {
                  if(this.curTab == TAB_NEW)
                  {
                     if(Boolean(_loc3_.isNew) || Boolean(_loc3_.isLimited))
                     {
                        _loc4_.push(_loc3_);
                     }
                  }
                  else if(this.curTab == TAB_SHOP)
                  {
                     _loc4_.push(_loc3_);
                  }
                  else if(this.curTab == TAB_CASH)
                  {
                     if(_loc3_.cash > 0)
                     {
                        _loc4_.push(_loc3_);
                     }
                  }
               }
               _loc2_++;
            }
            _loc4_.sort(this.compareShopItems);
         }
         return _loc4_;
      }
      
      private function onSellClick(param1:MouseEvent) : void
      {
         var _loc2_:WorldInfoPopUp = new WorldInfoPopUp(GameWorld.textHandler.getTextFromId("SellItemInstruction"));
         _loc2_.x = GameWorld.CANVAS_CENTER_X;
         _loc2_.y = GameWorld.CANVAS_CENTER_Y;
         _loc2_.show();
      }
      
      private function onLeft1MouseDown(param1:MouseEvent) : void
      {
         this.setGroup(this.curGroup,Math.max(this.curPage - 1,0));
      }
      
      public function setGroup(param1:Object, param2:int = 0, param3:Boolean = true) : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc6_:MovieClip = null;
         var _loc7_:int = 0;
         var _loc8_:MovieClip = null;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         if(this.groupButtons.length > 0)
         {
            _loc4_ = this.getGroupButton(param1);
            if(param3 && (!_loc4_ || _loc4_.groupItems.length == 0))
            {
               param1 = null;
               _loc4_ = null;
               _loc5_ = 0;
               while(_loc5_ < this.groupButtons.length)
               {
                  if(this.groupButtons[_loc5_].groupItems.length > 0)
                  {
                     _loc4_ = this.groupButtons[_loc5_];
                     param1 = _loc4_.group;
                     break;
                  }
                  _loc5_++;
               }
            }
         }
         if(this.curGroupButton)
         {
            if(this.curGroupButton.groupItems.length == 0)
            {
               setButtonMode(this.curGroupButton,false);
            }
            else
            {
               setButtonMode(this.curGroupButton,true);
               this.curGroupButton.addEventListener(MouseEvent.CLICK,this.groupButtonClicked,false,0,true);
            }
         }
         if(_loc4_)
         {
            setButtonMode(_loc4_,false);
            _loc4_.removeEventListener(MouseEvent.CLICK,this.groupButtonClicked);
            _loc4_.gotoAndStop("selected");
         }
         this.curGroupButton = _loc4_;
         this.curGroup = param1;
         this.curPage = param2;
         _loc5_ = 0;
         while(_loc5_ < this.itemButtons.length)
         {
            _loc6_ = this.itemButtons[_loc5_];
            _loc6_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemButtonMouseDown);
            _loc6_.removeEventListener(MouseEvent.CLICK,this.onItemButtonClick);
            if(_loc6_.mc_base.image)
            {
               _loc6_.mc_base.removeChild(this.itemButtons[_loc5_].mc_base.image);
               _loc6_.mc_base.image = null;
            }
            if(_loc6_.tooltip)
            {
               _loc6_.tooltip.destroy();
               _loc6_.tooltip = null;
            }
            _loc6_.mc_info.removeEventListener(MouseEvent.CLICK,this.onInfoClick);
            _loc6_.mc_info.removeEventListener(MouseEvent.MOUSE_DOWN,this.onInfoMouseDown);
            setButtonMode(_loc6_.mc_info,false);
            _loc6_.mc_info.itemConfig = null;
            _loc5_++;
         }
         this.curGroupItemConfigs = this.getItemConfigsInGroup(param1);
         var _loc12_:int = param2 * this.itemsPerPage;
         _loc5_ = 0;
         while(_loc5_ < this.itemButtons.length)
         {
            _loc7_ = _loc5_ + _loc12_;
            if(_loc7_ < this.curGroupItemConfigs.length)
            {
               _loc8_ = this.itemButtons[_loc5_];
               _loc9_ = this.curGroupItemConfigs[_loc7_];
               _loc10_ = this.gameUser.getInventoryItemCount(_loc9_);
               if(_loc10_ > 0)
               {
                  _loc8_.tf_count.text = _loc10_;
                  _loc8_.tf_count.visible = true;
                  _loc8_.mc_crate.visible = true;
               }
               else
               {
                  _loc8_.tf_count.text = "";
                  _loc8_.tf_count.visible = false;
                  _loc8_.mc_crate.visible = false;
               }
               _loc8_.tf_count.mouseEnabled = false;
               _loc8_.tf_count.autoSize = TextFieldAutoSize.LEFT;
               _loc8_.mc_wear.visible = false;
               _loc8_.mc_info.stop();
               if(_loc9_.infoText)
               {
                  _loc8_.mc_info.addEventListener(MouseEvent.CLICK,this.onInfoClick,false,0,true);
                  _loc8_.mc_info.addEventListener(MouseEvent.MOUSE_DOWN,this.onInfoMouseDown,false,0,true);
                  setButtonMode(_loc8_.mc_info,true);
                  _loc8_.mc_info.visible = true;
                  _loc8_.mc_info.itemConfig = _loc9_;
               }
               else
               {
                  _loc8_.mc_info.visible = false;
               }
               if(Boolean(this.selectedItems) && this.isItemSelected(_loc9_))
               {
                  setButtonMode(_loc8_,false);
                  _loc8_.mc_wear.visible = true;
                  _loc8_.mc_base.gotoAndStop("grey");
               }
               if(_loc9_.cash > 0)
               {
                  _loc8_.mc_pfCash.visible = true;
                  _loc8_.tf_cost.visible = false;
                  _loc8_.tf_cash.visible = true;
                  _loc8_.tf_cash.text = _loc9_.cash;
               }
               else
               {
                  _loc8_.tf_cost.visible = true;
                  _loc8_.tf_cash.visible = false;
                  _loc8_.mc_pfCash.visible = false;
                  if(_loc9_.cost == 0)
                  {
                     GameWorld.textHandler.setTextFieldWithId(_loc8_.tf_cost,"ItemCostFree");
                  }
                  else
                  {
                     _loc8_.tf_cost.text = _loc9_.cost;
                  }
               }
               _loc8_.addEventListener(MouseEvent.MOUSE_DOWN,this.onItemButtonMouseDown,false,0,true);
               _loc8_.addEventListener(MouseEvent.CLICK,this.onItemButtonClick,false,0,true);
               setButtonMode(_loc8_,true);
               if(GameWorld.isItemAffordable(_loc9_) && GameWorld.isItemLevelReached(_loc9_) || _loc10_ > 0)
               {
                  _loc8_.mc_base.gotoAndStop("grey");
               }
               else
               {
                  _loc8_.mc_base.gotoAndStop("red");
               }
               _loc8_.tf_limited.mouseEnabled = false;
               if(!_loc9_.isLimited)
               {
                  _loc8_.tf_limited.visible = false;
               }
               else
               {
                  _loc8_.tf_limited.visible = true;
               }
               _loc8_.tf_new.mouseEnabled = false;
               if(!_loc9_.isNew)
               {
                  _loc8_.tf_new.visible = false;
               }
               else
               {
                  _loc8_.tf_new.visible = true;
               }
               if(!GameWorld.isItemLevelReached(_loc9_))
               {
                  _loc8_.mc_level.visible = true;
                  _loc8_.mc_level.tf_level.mouseEnabled = false;
                  _loc8_.mc_level.tf_level.text = _loc9_.unlockLevel;
                  GameWorld.textHandler.setReplaceString("level",_loc9_.unlockLevel);
                  _loc8_.tooltip = new ToolTip(_loc8_,_loc9_.name + "\n" + GameWorld.textHandler.getTextFromId("UnlocksAtLevel"));
               }
               else
               {
                  _loc8_.mc_level.visible = false;
                  _loc11_ = GameWorld.textHandler.getTextFromId("ItemToolTip" + _loc9_.className);
                  if(_loc11_ != null)
                  {
                     _loc8_.tooltip = new ToolTip(_loc8_,_loc9_.name + "\n\n<font color=\"#38C4E5\" size=\"18\">" + _loc11_ + "</font>");
                  }
                  else
                  {
                     _loc8_.tooltip = new ToolTip(_loc8_,_loc9_.name);
                  }
               }
               _loc8_.itemConfig = _loc9_;
               _loc8_.tf_cost.mouseEnabled = false;
               _loc8_.tf_cost.autoSize = TextFieldAutoSize.CENTER;
               if(this.itemDescriptionTextField)
               {
                  _loc8_.addEventListener(MouseEvent.ROLL_OVER,this.onIconRollOver,false,0,true);
                  _loc8_.addEventListener(MouseEvent.ROLL_OUT,this.onIconRollOut,false,0,true);
               }
               setItemOnIconButton(_loc9_,_loc8_.mc_base);
               this.itemButtons[_loc5_].visible = true;
            }
            else
            {
               this.itemButtons[_loc5_].visible = false;
            }
            _loc5_++;
         }
         if(this.leftButton)
         {
            if(param2 <= 0)
            {
               setButtonMode(this.leftButton,false);
               this.leftButton.gotoAndStop("disabled");
               this.leftButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.onLeft1MouseDown);
            }
            else
            {
               setButtonMode(this.leftButton,true);
               this.leftButton.addEventListener(MouseEvent.MOUSE_DOWN,this.onLeft1MouseDown,false,0,true);
            }
         }
         if(this.rightButton)
         {
            if(param2 >= this.getMaxPageIndex(this.curGroup))
            {
               setButtonMode(this.rightButton,false);
               this.rightButton.gotoAndStop("disabled");
               this.rightButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRight1MouseDown);
            }
            else
            {
               setButtonMode(this.rightButton,true);
               this.rightButton.addEventListener(MouseEvent.MOUSE_DOWN,this.onRight1MouseDown,false,0,true);
            }
         }
      }
      
      private function onInfoMouseDown(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
      }
      
      private function onDragInstructionToolTipRemove(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = MovieClip(param1.currentTarget);
         if(this.dragInstructionToolTip)
         {
            this.dragInstructionToolTip.destroy();
            this.dragInstructionToolTip = null;
         }
         _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.onDragInstructionToolTipRemove);
      }
      
      public function setTab(param1:int) : Boolean
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Array = null;
         if(param1 != this.curTab)
         {
            if(this.curTab != -1)
            {
               if(this.tabButtons[this.curTab])
               {
                  this.tabButtons[this.curTab].addEventListener(MouseEvent.CLICK,this.onTabClick,false,0,true);
                  setButtonMode(this.tabButtons[this.curTab],true);
               }
            }
            this.curTab = param1;
            if(this.tabButtons[this.curTab])
            {
               this.tabButtons[this.curTab].removeEventListener(MouseEvent.CLICK,this.onTabClick);
               setButtonMode(this.tabButtons[this.curTab],false);
               this.tabButtons[this.curTab].gotoAndStop("selected");
            }
         }
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         while(_loc5_ < this.groupButtons.length)
         {
            _loc2_ = this.groupButtons[_loc5_];
            _loc3_ = this.getItemConfigsInGroup(_loc2_.group);
            _loc2_.groupItems = _loc3_;
            if(_loc3_.length > 0)
            {
               setButtonMode(_loc2_,true);
               _loc2_.addEventListener(MouseEvent.CLICK,this.groupButtonClicked,false,0,true);
               _loc2_.filters = null;
               _loc4_ = true;
            }
            else
            {
               setButtonMode(_loc2_,false);
               _loc2_.removeEventListener(MouseEvent.CLICK,this.groupButtonClicked);
               _loc2_.filters = new Array(new ColorMatrixFilter(GREY_FILTER_MATRIX));
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function groupButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = MovieClip(param1.currentTarget);
         if(_loc2_.group != this.curGroup)
         {
            this.setGroup(_loc2_.group,0);
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
      }
      
      public function refresh() : void
      {
         this.setTab(this.curTab);
         this.setGroup(this.curGroup,this.curPage,false);
      }
      
      public function disableGroups(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = param1[_loc4_];
            _loc3_ = 0;
            while(_loc3_ < this.groupButtons.length)
            {
               if(this.groupButtons[_loc3_].groupName == _loc2_)
               {
                  this.groupButtons[_loc3_].visible = false;
                  break;
               }
               _loc3_++;
            }
            _loc4_++;
         }
      }
      
      private function onTabClick(param1:MouseEvent) : void
      {
         this.setTab(param1.currentTarget.index);
         this.setGroup(this.curGroup,0);
      }
      
      private function onRight1MouseDown(param1:MouseEvent) : void
      {
         this.setGroup(this.curGroup,Math.min(this.curPage + 1,this.getMaxPageIndex(this.curGroup)));
      }
      
      private function getMaxPageIndex(param1:Object) : int
      {
         return Math.max(0,Math.floor((this.curGroupItemConfigs.length - 1) / this.itemsPerPage));
      }
      
      private function onIconRollOut(param1:MouseEvent) : void
      {
         this.itemDescriptionTextField.text = "";
      }
      
      private function onItemButtonMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:ItemChooserEvent = null;
         var _loc3_:MovieClip = MovieClip(param1.currentTarget);
         if(hasEventListener(ItemChooserEvent.EVENT_ITEM_MOUSE_DOWN))
         {
            _loc2_ = new ItemChooserEvent(ItemChooserEvent.EVENT_ITEM_MOUSE_DOWN);
            _loc2_.itemConfig = _loc3_.itemConfig;
            dispatchEvent(_loc2_);
         }
         if(_loc3_.tooltip)
         {
            _loc3_.tooltip.remove();
         }
         param1.stopImmediatePropagation();
      }
   }
}

