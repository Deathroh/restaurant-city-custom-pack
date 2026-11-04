package com.playfish.games.cooking
{
   import com.playfish.games.cooking.events.GameEvent;
   import com.playfish.games.cooking.rpc.RpcEvent;
   import com.playfish.games.cooking.tutorials.TutorialRecipeMenu;
   import com.playfish.games.cooking.ui.*;
   import com.playfish.rpc.cooking.RpcClient;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class WorldRecipeMenu extends BaseWorld
   {
      
      private static const RECIPE_LEVEL_NAMES:Array = ["","Simple","Standard","Classic","Tasty","Delicious","Luxurious","Gourmet","Sensational","Ultimate","Royal"];
      
      private static const DECORATIVE_ITEMS_FOR_FOOD:Array = ["RandomTableItem01","RandomTableItem02","RandomTableItem03"];
      
      private static const DECORATIVE_ITEMS_FOR_DRINKS:Array = ["RandomTableItem04","RandomTableItem05"];
      
      private static const DECORATIVE_ITEMS:Array = [DECORATIVE_ITEMS_FOR_FOOD,DECORATIVE_ITEMS_FOR_FOOD,DECORATIVE_ITEMS_FOR_FOOD,DECORATIVE_ITEMS_FOR_DRINKS];
      
      private static const BG_NAMES:Array = ["MenuBg","MenuBg","MenuBg","MenuDrinkBg"];
      
      private static const BG_COLOURS:Array = [[15391934,16381672],[15391934,16381672],[15391934,16381672],[13297125,15719877]];
      
      private static const MAX_DISH_LEVEL:int = RECIPE_LEVEL_NAMES.length - 1;
      
      private var bgLayer:Sprite;
      
      private var tutorialLayer:TutorialRecipeMenu;
      
      public var bottomButtonLayer:MovieClip;
      
      private var curCourseIndex:int = -1;
      
      private var recipeEntries:Array;
      
      public var uiLevelBar:MovieClip;
      
      private var curBg:BackgroundLayer;
      
      public var topButtonLayer:MovieClip;
      
      private var decorativeItems:Array;
      
      private var scrollPanel:ScrollPanel;
      
      private var ingredientItemChooser:IngredientItemChooser;
      
      private var bgTop:Shape;
      
      private var recipeLayerX:Number;
      
      private var bgBottom:Shape;
      
      private var gameUser:GameUser;
      
      private var bgMusic:GameSound;
      
      private var recipeLayer:Sprite;
      
      private var courseButtons:Array;
      
      private var recipeGap:Number;
      
      private var ingredientsPerRecipe:int = 4;
      
      public var levelBar:LevelBar;
      
      public function WorldRecipeMenu(param1:GameUser)
      {
         var i:Number = NaN;
         var menuLayout:MovieClip = null;
         menuLayout = null;
         var maxDishes:int = 0;
         var gameUser:GameUser = param1;
         this.recipeEntries = new Array();
         this.decorativeItems = new Array();
         this.courseButtons = new Array();
         this.bgMusic = new GameSound("MusicEditor",GameSound.TYPE_MUSIC);
         super();
         this.gameUser = gameUser;
         this.bgTop = new Shape();
         this.bgBottom = new Shape();
         addChild(this.bgTop);
         addChild(this.bgBottom);
         this.bgLayer = new Sprite();
         addChild(this.bgLayer);
         this.topButtonLayer = Engine.getMovieClip("MenuViewButtonLayerTop");
         this.bottomButtonLayer = Engine.getMovieClip("MenuViewButtonLayerBottom");
         setButtonMode(this.bottomButtonLayer.mc_left,true);
         setButtonMode(this.bottomButtonLayer.mc_right,true);
         setButtonMode(this.bottomButtonLayer.mc_left2,true);
         setButtonMode(this.bottomButtonLayer.mc_right2,true);
         setButtonMode(this.bottomButtonLayer.buttonMyRestaurant,true);
         this.recipeLayer = new Sprite();
         menuLayout = Engine.getMovieClip("MenuUi");
         this.recipeGap = menuLayout.mc_recipe1.x - menuLayout.mc_recipe0.x;
         this.recipeLayerX = menuLayout.mc_recipe0.x;
         this.recipeLayer.x = this.recipeLayerX;
         this.recipeLayer.y = menuLayout.mc_recipe0.y;
         addChild(this.recipeLayer);
         this.scrollPanel = new ScrollPanel(this.recipeLayer,this,this.bottomButtonLayer.mc_left,this.bottomButtonLayer.mc_right,this.bottomButtonLayer.mc_left2,this.bottomButtonLayer.mc_right2);
         addObject(this.scrollPanel);
         i = 0;
         while(i < Recipe.NUM_MENU_RECIPE_TYPE)
         {
            this.courseButtons[i] = this.topButtonLayer["mc_courseButton" + i];
            if(this.courseButtons[i])
            {
               setButtonMode(this.courseButtons[i],true);
               this.courseButtons[i].courseIndex = i;
               this.courseButtons[i].addEventListener(MouseEvent.CLICK,this.onCourseButtonClick,false,0,true);
               this.courseButtons[i].mc_course.tf_course.mouseEnabled = false;
               GameWorld.textHandler.setTextFieldWithId(this.courseButtons[i].mc_course.tf_course,Recipe.MENU_RECIPE_TYPE_NAMES[i] + "Dish");
            }
            i++;
         }
         this.setCourse(0);
         this.ingredientItemChooser = new IngredientItemChooser(this.gameUser.ingredients,null,gameUser == GameWorld.gameUser);
         this.ingredientItemChooser.y = Engine.getStageBottom();
         this.ingredientItemChooser.addEventListener(MouseEvent.MOUSE_DOWN,this.onItemChooserMouseDown,false,0,true);
         addChild(this.ingredientItemChooser);
         this.bottomButtonLayer.buttonMyRestaurant.addEventListener(MouseEvent.CLICK,this.onMyRestaurantClick,false,0,true);
         this.bottomButtonLayer.buttonMyRestaurant.toolTip = new ToolTip(this.bottomButtonLayer.buttonMyRestaurant,GameWorld.textHandler.getTextFromId("ToolTipBackToRestaurant"));
         addChild(this.topButtonLayer);
         addChild(this.bottomButtonLayer);
         GameWorld.gameEventDispatcher.addEventListener(GameEvent.INGREDIENT_CHANGED,this.onIngredientChanged,false,0,true);
         this.uiLevelBar = this.topButtonLayer["mc_levelBar"];
         if(gameUser != GameWorld.gameUser)
         {
            this.ingredientItemChooser.scene.tf_help.visible = false;
            GameWorld.textHandler.setReplaceString("name",gameUser.firstName);
            GameWorld.textHandler.setTextFieldWithId(this.ingredientItemChooser.scene.tf_help,"SomeonesCurrentIngredients");
            this.bottomButtonLayer.mc_shout.visible = false;
            this.bottomButtonLayer.buttonMarket.visible = false;
            this.uiLevelBar.visible = false;
         }
         else
         {
            GameWorld.textHandler.setTextFieldWithId(this.ingredientItemChooser.scene.tf_help,"YourCurrentIngredientsClickToLockAndDisableTrading");
            setButtonMode(this.bottomButtonLayer.mc_shout,true);
            this.bottomButtonLayer.mc_shout.addEventListener(MouseEvent.CLICK,this.onShoutClick,false,0,true);
            this.bottomButtonLayer.mc_shout.toolTip = new ToolTip(this.bottomButtonLayer.mc_shout,GameWorld.textHandler.getTextFromId("ToolTipAskForIngredients"));
            this.bottomButtonLayer.mc_shout.mc_new.mouseEnabled = false;
            this.bottomButtonLayer.mc_shout.mc_new.mouseChildren = false;
            if(!GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_INGRADIANT_SHOP))
            {
               this.bottomButtonLayer.buttonMarket.mc_new.visible = false;
            }
            else
            {
               this.bottomButtonLayer.buttonMarket.tf_sale.visible = false;
            }
            setButtonMode(this.bottomButtonLayer.buttonMarket,true);
            this.bottomButtonLayer.buttonMarket.addEventListener(MouseEvent.CLICK,this.onMarketButtonClick,false,0,true);
            this.bottomButtonLayer.buttonMarket.toolTip = new ToolTip(this.bottomButtonLayer.buttonMarket,GameWorld.textHandler.getTextFromId("ToolTipIngredientMarket"));
            this.bottomButtonLayer.buttonMarket.mc_new.mouseEnabled = false;
            this.bottomButtonLayer.buttonMarket.mc_new.mouseChildren = false;
            if(!GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_ASK_FOR_INGREDIENT))
            {
               this.bottomButtonLayer.mc_shout.mc_new.visible = false;
            }
            if(gameUser.getOwnedRecipe(TutorialRecipeMenu.LEARN_RECIPE_ID) == null && gameUser.hasIngredientsForRecipe(TutorialRecipeMenu.LEARN_RECIPE_ID))
            {
               this.tutorialLayer = new TutorialRecipeMenu(this);
            }
            else
            {
               maxDishes = int(GameWorld.LEVEL_THRESHOLDS[gameUser.level.value].numDishes);
               if(maxDishes > 1 && GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_2_DISHES_PER_COURSE))
               {
                  GameWorld.textHandler.setReplaceString("NumberOfDishes",maxDishes.toString());
                  GameWorld.showTutorialTextPopUp(GameWorld.textHandler.getTextFromId("TutorialTwoDishesPerCourse"));
                  GameWorld.setFirstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_2_DISHES_PER_COURSE);
               }
            }
            this.uiLevelBar.mc_level.toolTip = new ToolTip(this.uiLevelBar.mc_level,GameWorld.textHandler.getTextFromId("ToolTipGourmetPointsAndLevel"));
            WorldRestaurantPlay.setRating(this.uiLevelBar.mc_stars,GameWorld.gameUser);
            if(!GameWorld.gameUser.userInfo.isInStreet)
            {
               this.uiLevelBar.mc_stars.visible = false;
            }
            this.levelBar = new LevelBar(this.uiLevelBar.mc_level,GameWorld.gameUser);
            this.uiLevelBar.mc_level.buttonMode = true;
            this.uiLevelBar.mc_level.addEventListener(MouseEvent.CLICK,function onLevelBarClick(param1:MouseEvent):void
            {
               GameWorld.showNextLevelPopUp(GameWorld.gameUser.level.value);
            },false,0,true);
         }
      }
      
      private function refreshBg() : void
      {
         this.bgTop.graphics.clear();
         this.bgBottom.graphics.clear();
         var _loc1_:Number = Engine.getStageBottom() - Engine.STAGE_HEIGHT;
         if(_loc1_ > 0)
         {
            this.bgBottom.graphics.beginFill(BG_COLOURS[this.curCourseIndex][1]);
            this.bgBottom.graphics.drawRect(Engine.getStageX(),Engine.STAGE_HEIGHT,Engine.getStageWidth(),_loc1_);
            this.bgBottom.graphics.endFill();
         }
         var _loc2_:Number = -Engine.getStageY();
         if(_loc2_ > 0)
         {
            this.bgTop.graphics.beginFill(BG_COLOURS[this.curCourseIndex][0]);
            this.bgTop.graphics.drawRect(Engine.getStageX(),Engine.getStageY(),Engine.getStageWidth(),_loc2_);
            this.bgTop.graphics.endFill();
         }
      }
      
      private function onLevelUpSuccess(param1:RpcEvent, param2:MovieClip) : void
      {
         var _loc3_:WorldInfoPopUp = null;
         var _loc4_:Recipe = null;
         var _loc5_:DishMaxLevelPopUp = null;
         var _loc6_:IngredientItem = null;
         var _loc7_:int = 0;
         Debug.out("onLevelUpSuccess");
         if((param1.successCode & RpcClient.SAVE_USER_PROFILE_FAIL_ADD_RECIPE) != 0)
         {
            _loc3_ = new WorldInfoPopUp(GameWorld.textHandler.getTextFromId("TradedMissingIngredient"));
            _loc3_.show();
         }
         else
         {
            _loc4_ = param2.recipe;
            ++_loc4_.level;
            _loc7_ = 0;
            while(_loc7_ < _loc4_.ingredientItems.length)
            {
               _loc6_ = _loc4_.ingredientItems[_loc7_];
               this.gameUser.removeIngredient(_loc6_.itemConfig,_loc6_.count);
               _loc7_++;
            }
            this.ingredientItemChooser.refresh(this.gameUser.ingredients);
            if(this.gameUser.getOwnedRecipe(_loc4_.config.id) == null)
            {
               this.gameUser.ownedRecipeItems.push(_loc4_);
            }
            this.setRecipeEntry(_loc4_.config,param2);
            this.refreshRecipeButtons();
            param2.mc_recipe.mc_level.gotoAndPlay("level");
            if(_loc4_.level >= MAX_DISH_LEVEL)
            {
               _loc5_ = new DishMaxLevelPopUp(_loc4_);
               _loc5_.show();
               GameWorld.addAwardValue(GameAwards.AWARD_RECIPE_LEVEL_10,1);
            }
            this.addGourmetPoints(GameWorld.GOURMET_POINTS_PER_LEARN_RECIPE_LEVEL[_loc4_.level - 1]);
         }
      }
      
      private function onIngredientChanged(param1:GameEvent) : void
      {
         Debug.out("WorldRecipeMenu.onIngredientChanged");
         this.ingredientItemChooser.refresh(this.gameUser.ingredients);
         this.refreshRecipeButtons();
      }
      
      private function onLevelUpClick(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(!this.scrollPanel.moveGesture)
         {
            _loc2_ = param1.currentTarget.parent;
            this.levelUpRecipeInPanel(_loc2_);
            param1.stopImmediatePropagation();
         }
      }
      
      private function onStageFullScreen(param1:Event) : void
      {
         this.ingredientItemChooser.y = Engine.getStageBottom();
         this.topButtonLayer.y = Engine.getStageY();
         this.bottomButtonLayer.y = Engine.getStageBottom();
         this.curBg.x = Engine.getStageX();
         this.refreshBg();
         this.bottomButtonLayer.mc_left.x = Engine.getStageX() - this.bottomButtonLayer.mc_left.getBounds(null).left + 5;
         this.bottomButtonLayer.mc_left2.x = Engine.getStageX() - this.bottomButtonLayer.mc_left2.getBounds(null).left + 5;
         this.bottomButtonLayer.mc_right.x = Engine.getStageRight() - this.bottomButtonLayer.mc_right.getBounds(null).right - 5;
         this.bottomButtonLayer.mc_right2.x = Engine.getStageRight() - this.bottomButtonLayer.mc_right2.getBounds(null).right - 5;
      }
      
      private function setCourse(param1:int) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Boolean = false;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Recipe = null;
         var _loc9_:MovieClip = null;
         var _loc10_:Array = null;
         var _loc11_:MovieClip = null;
         if(param1 != this.curCourseIndex)
         {
            if(this.curCourseIndex != -1)
            {
               setButtonMode(this.courseButtons[this.curCourseIndex],true);
               this.courseButtons[this.curCourseIndex].addEventListener(MouseEvent.CLICK,this.onCourseButtonClick,false,0,true);
            }
            setButtonMode(this.courseButtons[param1],false);
            this.courseButtons[param1].removeEventListener(MouseEvent.CLICK,this.onCourseButtonClick);
            this.courseButtons[param1].gotoAndStop("selected");
            this.curCourseIndex = param1;
            this.updateSelectedRecipesCountText();
            if(this.curBg)
            {
               this.bgLayer.removeChild(this.curBg);
               this.curBg = null;
            }
            this.curBg = new BackgroundLayer();
            this.curBg.x = Engine.getStageX();
            this.curBg.addLayer(BG_NAMES[param1],0,1);
            this.bgLayer.addChild(this.curBg);
            this.tickBg();
            if(param1 == Recipe.MENU_RECIPE_DRINK && this.gameUser.level.value < GameWorld.DRINK_START_LEVEL)
            {
               this.topButtonLayer.mc_lockBanner.visible = true;
               GameWorld.textHandler.setReplaceString("Level",GameWorld.DRINK_START_LEVEL.toString());
               GameWorld.textHandler.setTextFieldWithId(this.topButtonLayer.mc_lockBanner.tf_text,"DrinksUnlockAtLevel");
            }
            else
            {
               this.topButtonLayer.mc_lockBanner.visible = false;
            }
            _loc2_ = 0;
            while(_loc2_ < this.recipeEntries.length)
            {
               this.recipeLayer.removeChild(this.recipeEntries[_loc2_]);
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < this.decorativeItems.length)
            {
               this.recipeLayer.removeChild(this.decorativeItems[_loc2_]);
               _loc2_++;
            }
            this.decorativeItems.splice(0,this.decorativeItems.length);
            _loc3_ = param1 == Recipe.MENU_RECIPE_DRINK && this.gameUser.level.value < GameWorld.DRINK_START_LEVEL;
            _loc4_ = GameWorld.recipeItemDatabase.getItems(Recipe.MENU_RECIPE_TYPE_NAMES[param1]);
            this.recipeEntries = new Array();
            _loc5_ = this.recipeGap;
            _loc6_ = -1;
            _loc2_ = 0;
            while(_loc2_ < _loc4_.length)
            {
               _loc7_ = _loc4_[_loc2_];
               _loc8_ = this.gameUser.getOwnedRecipe(_loc7_.id);
               if(this.isRecipeAvailable(_loc7_,_loc8_))
               {
                  _loc9_ = Engine.getMovieClip("RecipeEntry");
                  _loc9_.recipeConfig = _loc7_;
                  this.setRecipeEntry(_loc7_,_loc9_);
                  _loc9_.x = _loc5_;
                  this.recipeLayer.addChild(_loc9_);
                  this.recipeEntries.push(_loc9_);
                  if(Engine.rnd(0,4) == 0)
                  {
                     _loc10_ = DECORATIVE_ITEMS[param1];
                     _loc11_ = Engine.getMovieClip(_loc10_[Engine.rnd(0,_loc10_.length)]);
                     _loc11_.x = _loc5_ + this.recipeGap / 2;
                     this.recipeLayer.addChildAt(_loc11_,0);
                     this.decorativeItems.push(_loc11_);
                  }
                  if(_loc3_)
                  {
                     _loc9_.tf_levelName.visible = false;
                     _loc9_.mc_recipe.mc_level.visible = false;
                  }
                  else if(this.gameUser.isMenuRecipeSelected(_loc7_.id))
                  {
                     this.selectRecipe(this.recipeEntries.length - 1);
                     if(_loc6_ == -1)
                     {
                        _loc6_ = _loc2_;
                     }
                  }
                  _loc5_ += this.recipeGap;
               }
               _loc2_++;
            }
            if(_loc6_ == -1)
            {
               if(!_loc3_)
               {
                  this.selectRecipe(0);
                  _loc6_ = 0;
               }
            }
            this.scrollPanel.setBounds(this.recipeLayerX,this.recipeLayerX + _loc5_,this.recipeGap * 2);
            this.scrollPanel.setScrollStep(this.recipeGap);
            this.scrollPanel.focus(_loc6_ * this.recipeGap);
            if(param1 == Recipe.MENU_RECIPE_DRINK)
            {
               if(GameWorld.firstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_DRINK_TUTORIAL) && this.gameUser.level.value >= GameWorld.DRINK_START_LEVEL)
               {
                  GameWorld.showTutorialTextPopUp(GameWorld.textHandler.getTextFromId("TutorialDrinks"));
                  GameWorld.setFirstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_DRINK_TUTORIAL);
               }
            }
            this.refreshBg();
         }
      }
      
      private function onItemChooserMouseDown(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
      }
      
      private function onBuyClick(param1:MouseEvent) : void
      {
         var _loc2_:Array = param1.currentTarget.missingIngredients;
         var _loc3_:Recipe = param1.currentTarget.recipe;
         var _loc4_:MovieClip = param1.currentTarget.parent;
         var _loc5_:BuyAndLevelUpDishPopup = new BuyAndLevelUpDishPopup(this,_loc2_,_loc3_,_loc4_);
         _loc5_.show();
      }
      
      override public function tick(param1:uint) : void
      {
         this.tickBg();
      }
      
      override public function showNotify() : void
      {
         this.bgMusic.play(-1);
         GameWorld.cashPanel.hideAddCoins();
         GameWorld.cashPanel.hideAddPlayfishCash();
         addObject(GameWorld.cashPanel);
         Engine.instance.stage.addEventListener(Event.FULLSCREEN,this.onStageFullScreen,false,0,true);
         this.onStageFullScreen(null);
      }
      
      override public function hideNotify() : void
      {
         if(this.tutorialLayer != null)
         {
            this.tutorialLayer.remove();
         }
         GameWorld.cashPanel.showAddCashButton();
         GameWorld.cashPanel.showAddPlayfishCashButton();
         removeObject(GameWorld.cashPanel);
         this.bgMusic.stop();
         Engine.instance.stage.removeEventListener(Event.FULLSCREEN,this.onStageFullScreen);
      }
      
      private function deselectRecipe(param1:int) : void
      {
         setButtonMode(this.recipeEntries[param1].mc_recipe,true);
      }
      
      private function setSelectedCourseOnPanel(param1:MovieClip, param2:Recipe) : void
      {
         var _loc3_:MovieClip = null;
         if(param1.mc_content.icon)
         {
            param1.mc_content.removeChild(param1.mc_content.icon);
            param1.mc_content.icon = null;
         }
         param1.mc_content.mc_icon.visible = false;
         _loc3_ = Engine.getMovieClip(param2.className);
         _loc3_.stop();
         if(_loc3_.mc_plate)
         {
            _loc3_.mc_plate.gotoAndStop(param2.level);
         }
         _loc3_.x = param1.mc_content.mc_icon.x;
         _loc3_.y = param1.mc_content.mc_icon.y;
         param1.mc_content.addChild(_loc3_);
         param1.mc_content.icon = _loc3_;
         param1.mc_level.tf_level.text = param2.level;
      }
      
      private function onLevelUpFail(param1:RpcEvent) : void
      {
      }
      
      private function onRecipeClick(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Recipe = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:WorldInfoPopUp = null;
         if(!this.scrollPanel.moveGesture)
         {
            _loc2_ = this.gameUser.getSelectedRecipes(this.curCourseIndex);
            _loc3_ = param1.currentTarget.recipe;
            if(!this.gameUser.isMenuRecipeSelected(_loc3_.config.id))
            {
               _loc4_ = int(GameWorld.LEVEL_THRESHOLDS[this.gameUser.level.value].numDishes);
               if(_loc4_ == 1)
               {
                  _loc5_ = int(_loc2_[0].config.id);
                  _loc6_ = 0;
                  while(_loc6_ < this.recipeEntries.length)
                  {
                     if(this.recipeEntries[_loc6_].recipeConfig.id == _loc5_)
                     {
                        this.gameUser.deselectMenuRecipe(_loc5_);
                        this.deselectRecipe(_loc6_);
                        this.updateSelectedRecipesCountText();
                        GameWorld.saveProfileHandler.selectRecipe(_loc5_,false);
                        break;
                     }
                     _loc6_++;
                  }
                  this.gameUser.selectMenuRecipe(_loc3_.config.id);
                  this.selectRecipe(this.recipeEntries.indexOf(param1.currentTarget.parent));
                  this.updateSelectedRecipesCountText();
                  GameWorld.saveProfileHandler.selectRecipe(_loc3_.config.id,true);
               }
               else if(_loc2_.length < _loc4_)
               {
                  this.gameUser.selectMenuRecipe(_loc3_.config.id);
                  this.selectRecipe(this.recipeEntries.indexOf(param1.currentTarget.parent));
                  this.updateSelectedRecipesCountText();
                  GameWorld.saveProfileHandler.selectRecipe(_loc3_.config.id,true);
               }
               else
               {
                  _loc7_ = new WorldInfoPopUp(GameWorld.textHandler.getTextFromId("NeedToDeselectDishFirst"));
                  _loc7_.show();
               }
            }
            else if(_loc2_.length > 1)
            {
               this.gameUser.deselectMenuRecipe(_loc3_.config.id);
               this.deselectRecipe(this.recipeEntries.indexOf(param1.currentTarget.parent));
               this.updateSelectedRecipesCountText();
               GameWorld.saveProfileHandler.selectRecipe(_loc3_.config.id,false);
            }
         }
      }
      
      private function onCourseButtonClick(param1:MouseEvent) : void
      {
         this.setCourse(param1.currentTarget.courseIndex);
      }
      
      private function setRecipeEntry(param1:Object, param2:MovieClip) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:MovieClip = null;
         var _loc9_:IngredientItem = null;
         var _loc10_:IngredientItem = null;
         var _loc11_:Number = NaN;
         var _loc12_:TextField = param2.tf_levelName;
         var _loc13_:TextField = param2.tf_name;
         if(Boolean(param1.isLimited) || Boolean(param1.expireDate))
         {
            param2.tf_levelName.visible = false;
            param2.tf_name.visible = false;
            _loc12_ = param2.tf_levelName2;
            _loc13_ = param2.tf_name2;
         }
         else
         {
            param2.tf_levelName2.visible = false;
            param2.tf_name2.visible = false;
         }
         var _loc14_:Array = null;
         var _loc15_:Recipe = this.gameUser.getOwnedRecipe(param1.id);
         if(_loc15_ == null)
         {
            _loc15_ = new Recipe(param1);
            _loc15_.level = 0;
            GameWorld.textHandler.setTextField(_loc12_,"");
         }
         if(Boolean(param1.expireDate) && _loc15_.level == 0)
         {
            _loc3_ = this.getTimeToExpire(param1.expireDate);
            _loc4_ = 60 * 60 * 1000;
            _loc5_ = 24 * _loc4_;
            _loc6_ = Math.floor(_loc3_ / _loc5_);
            _loc7_ = Math.floor(_loc3_ % _loc5_ / _loc4_);
            GameWorld.textHandler.setReplaceString("days",_loc6_.toString());
            GameWorld.textHandler.setReplaceString("hours",_loc7_.toString());
            GameWorld.textHandler.setTextFieldWithId(param2.mc_limitedDishCountDown.tf_text,"LimitedDishCountDown");
            param2.mc_limitedDishCountDown.visible = true;
         }
         else
         {
            param2.mc_limitedDishCountDown.visible = false;
         }
         param2.recipe = _loc15_;
         _loc13_.text = _loc15_.name;
         param2.mc_recipe.mc_level.stop();
         param2.mc_recipe.mc_level.tf_level.text = _loc15_.level;
         if(_loc15_.level > 0)
         {
            GameWorld.textHandler.setTextFieldWithId(_loc12_,"DishLevel" + RECIPE_LEVEL_NAMES[_loc15_.level]);
         }
         param2.icon = Engine.getMovieClip(_loc15_.className);
         param2.icon.stop();
         if(param2.icon.mc_plate)
         {
            param2.icon.mc_plate.gotoAndStop(_loc15_.level);
         }
         param2.mc_recipe.mc_icon.removeChildAt(0);
         param2.mc_recipe.mc_icon.addChild(param2.icon);
         _loc14_ = _loc15_.ingredientItems;
         var _loc16_:Number = 0;
         while(_loc16_ < this.ingredientsPerRecipe)
         {
            _loc8_ = param2["mc_ingredient" + _loc16_];
            _loc8_.stop();
            _loc8_.visible = false;
            if(_loc8_.icon != null)
            {
               param2.removeChild(_loc8_.icon);
               _loc8_.icon = null;
            }
            _loc16_++;
         }
         var _loc17_:Boolean = true;
         var _loc18_:int = 0;
         var _loc19_:Array = new Array();
         _loc16_ = 0;
         while(_loc16_ < _loc14_.length && _loc15_.level < RECIPE_LEVEL_NAMES.length - 1)
         {
            _loc9_ = _loc14_[_loc16_];
            _loc10_ = this.gameUser.getIngredient(_loc9_.itemConfig);
            _loc11_ = 0;
            while(_loc11_ < _loc9_.count)
            {
               _loc8_ = param2["mc_ingredient" + _loc18_];
               if(_loc8_)
               {
                  _loc8_.icon = Engine.getMovieClip(_loc9_.className);
                  _loc8_.icon.stop();
                  if(_loc10_ == null || _loc11_ >= _loc10_.count)
                  {
                     _loc8_.icon.gotoAndStop("grey");
                     _loc17_ = false;
                     _loc19_.push(_loc9_);
                  }
                  _loc8_.icon.x = _loc8_.x;
                  _loc8_.icon.y = _loc8_.y;
                  this.matchSize(_loc8_.icon,_loc8_);
                  param2.addChild(_loc8_.icon);
                  _loc8_.icon.toolTip = new ToolTip(_loc8_.icon,_loc9_.itemConfig.name);
               }
               _loc18_++;
               _loc11_++;
            }
            _loc16_++;
         }
         param2.mc_levelup.removeEventListener(MouseEvent.CLICK,this.onLevelUpClick);
         param2.mc_learn.removeEventListener(MouseEvent.CLICK,this.onLevelUpClick);
         param2.mc_buy.removeEventListener(MouseEvent.CLICK,this.onBuyClick);
         if(param2.mc_levelup.toolTip != null)
         {
            param2.mc_levelup.toolTip.destroy();
            param2.mc_levelup.toolTip = null;
         }
         if(param2.mc_learn.toolTip != null)
         {
            param2.mc_learn.toolTip.destroy();
            param2.mc_learn.toolTip = null;
         }
         param2.mc_buy.stop();
         if(this.gameUser == GameWorld.gameUser)
         {
            param2.mc_learn.stop();
            param2.mc_levelup.stop();
            param2.mc_buy.stop();
            param2.mc_learn.mc_content.tf_text.mouseEnabled = false;
            param2.mc_levelup.mc_content.tf_text.mouseEnabled = false;
            param2.mc_buy.mc_content.tf_text.mouseEnabled = false;
            if(this.curCourseIndex == Recipe.MENU_RECIPE_DRINK && this.gameUser.level.value < GameWorld.DRINK_START_LEVEL)
            {
               param2.mc_learn.visible = false;
               param2.mc_levelup.visible = false;
               param2.mc_buy.visible = false;
               setButtonMode(param2.mc_recipe,false);
               param2.mc_recipe.gotoAndStop("disabled");
            }
            else if(_loc15_.level > 0)
            {
               param2.mc_learn.visible = false;
               param2.mc_levelup.visible = true;
               param2.mc_buy.visible = false;
               if(_loc15_.level >= RECIPE_LEVEL_NAMES.length - 1)
               {
                  param2.mc_levelup.visible = false;
               }
               else if(_loc17_)
               {
                  setButtonMode(param2.mc_levelup,true);
                  param2.mc_levelup.mc_content.gotoAndStop("on");
                  param2.mc_levelup.addEventListener(MouseEvent.CLICK,this.onLevelUpClick,false,0,true);
               }
               else
               {
                  param2.mc_levelup.visible = false;
                  param2.mc_buy.mc_content.gotoAndStop("on");
                  param2.mc_buy.visible = true;
                  setButtonMode(param2.mc_buy,true);
                  param2.mc_buy.missingIngredients = _loc19_;
                  param2.mc_buy.recipe = _loc15_;
                  GameWorld.textHandler.setTextFieldWithId(param2.mc_buy.mc_content.tf_text,"ButtonLevelUpText");
                  param2.mc_buy.toolTip = new ToolTip(param2.mc_buy,GameWorld.textHandler.getTextFromId("ToolTipPurchaseIngredientsLevelUp"));
                  param2.mc_buy.addEventListener(MouseEvent.CLICK,this.onBuyClick,false,0,true);
               }
               setButtonMode(param2.mc_recipe,true);
               param2.mc_recipe.recipe = _loc15_;
               param2.mc_recipe.addEventListener(MouseEvent.CLICK,this.onRecipeClick,false,0,true);
            }
            else
            {
               param2.mc_levelup.visible = false;
               param2.mc_learn.visible = true;
               param2.mc_buy.visible = false;
               param2.mc_buy.mc_content.mc_arrow.visible = false;
               if(_loc17_)
               {
                  setButtonMode(param2.mc_learn,true);
                  param2.mc_learn.mc_content.gotoAndStop("on");
                  param2.mc_learn.addEventListener(MouseEvent.CLICK,this.onLevelUpClick,false,0,true);
               }
               else
               {
                  param2.mc_learn.visible = false;
                  param2.mc_buy.mc_content.gotoAndStop("on");
                  param2.mc_buy.visible = true;
                  setButtonMode(param2.mc_buy,true);
                  param2.mc_buy.missingIngredients = _loc19_;
                  param2.mc_buy.recipe = _loc15_;
                  GameWorld.textHandler.setTextFieldWithId(param2.mc_buy.mc_content.tf_text,"ButtonLearnText");
                  param2.mc_buy.toolTip = new ToolTip(param2.mc_buy,GameWorld.textHandler.getTextFromId("ToolTipPurchaseIngredientsLearn"));
                  param2.mc_buy.addEventListener(MouseEvent.CLICK,this.onBuyClick,false,0,true);
               }
               setButtonMode(param2.mc_recipe,false);
               param2.mc_recipe.gotoAndStop("disabled");
            }
         }
         else
         {
            param2.mc_learn.visible = false;
            param2.mc_levelup.visible = false;
            param2.mc_buy.visible = false;
            setButtonMode(param2.mc_recipe,false);
            if(_loc15_.level == 0)
            {
               param2.mc_recipe.gotoAndStop("disabled");
            }
         }
      }
      
      private function tickBg() : void
      {
         this.curBg.setX(this.recipeLayer.x - 1000);
      }
      
      private function showIngredientShop() : void
      {
         var _loc1_:WorldIngredientShopPopUp = null;
         if(GameWorld.gameUser.level.value >= GameWorld.INGREDIENT_MARKET_UNLOCK_LEVEL)
         {
            GameWorld.setFirstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_INGRADIANT_SHOP);
            if(this.bottomButtonLayer.buttonMarket)
            {
               this.bottomButtonLayer.buttonMarket.mc_new.visible = false;
            }
            _loc1_ = new WorldIngredientShopPopUp();
            _loc1_.show();
         }
      }
      
      private function isRecipeAvailable(param1:Object, param2:Recipe) : Boolean
      {
         if(Boolean(param2) && param2.level > 0)
         {
            return true;
         }
         if(param1.expireDate)
         {
            return this.getTimeToExpire(param1.expireDate) > 0;
         }
         return !param1.invisible;
      }
      
      private function addGourmetPoints(param1:Number, param2:Boolean = false) : void
      {
         GameWorld.addGourmetPoints(param1,param2);
         var _loc3_:GameObject = new GameObject("GourmetPointAdded");
         var _loc4_:int = Math.floor(param1 * 10) % 10;
         var _loc5_:String = "+" + Math.floor(param1);
         if(_loc4_ != 0)
         {
            _loc5_ += "." + _loc4_;
         }
         _loc3_.getChildMovieClipInstance("mc_content").tf_amount.text = _loc5_;
         _loc3_.y += Engine.getStageY();
         _loc3_.drawPriority = WorldRestaurant.SCORE_POPUP_PRIORITY;
         _loc3_.numLoops = 1;
         _loc3_.removeWhenComplete = true;
         Engine.worldContainer.addObject(_loc3_);
         if(this.levelBar)
         {
            this.levelBar.refresh();
         }
      }
      
      private function updateSelectedRecipesCountText() : void
      {
         var _loc1_:int = int(this.gameUser.getSelectedRecipes(this.curCourseIndex).length);
         var _loc2_:int = int(GameWorld.LEVEL_THRESHOLDS[this.gameUser.level.value].numDishes);
         GameWorld.textHandler.setReplaceString("DishCount",_loc1_ + "/" + _loc2_);
         GameWorld.textHandler.setTextFieldWithId(this.topButtonLayer.tf_dishesSelected,"DishesSelected");
      }
      
      private function getTimeToExpire(param1:String) : Number
      {
         var _loc2_:Array = param1.split("/");
         var _loc3_:Date = new Date(_loc2_[2],_loc2_[1] - 1,_loc2_[0]);
         return _loc3_.time - GameWorld.serverTime.time;
      }
      
      private function onMyRestaurantClick(param1:MouseEvent) : void
      {
         GameWorld.gameEventDispatcher.removeEventListener(GameEvent.INGREDIENT_CHANGED,this.onIngredientChanged);
         GameWorld.fadeToWorld(new WorldRestaurantPlay(this.gameUser,this.gameUser != GameWorld.gameUser,WorldStreet.streetType == WorldStreet.STREET_TYPE_RANDOM));
      }
      
      private function onRetryCancel() : void
      {
         GameWorld.error();
      }
      
      public function matchSize(param1:MovieClip, param2:MovieClip) : void
      {
         if(param1.width > param1.height)
         {
            param1.width = param2.width;
            param1.scaleY = param1.scaleX;
         }
         else
         {
            param1.height = param2.height;
            param1.scaleX = param1.scaleY;
         }
      }
      
      private function selectRecipe(param1:int) : void
      {
         setButtonMode(this.recipeEntries[param1].mc_recipe,false);
         this.recipeEntries[param1].mc_recipe.gotoAndStop("selected");
      }
      
      public function levelUpRecipeInPanel(param1:MovieClip) : void
      {
         var recipePanel:MovieClip = null;
         recipePanel = param1;
         var theRecipe:Recipe = recipePanel.recipe;
         GameWorld.saveProfileHandler.addRecipe(theRecipe);
         GameWorld.saveProfileHandler.addEventListener(RpcEvent.SUCCESS,function(param1:RpcEvent):void
         {
            onLevelUpSuccess(param1,recipePanel);
         });
         GameWorld.globalRpcs.loadingPopUp = new WorldLoadingPopUp("Saving...",WorldLoadingPopUp.SAVING);
         GameWorld.globalRpcs.retryText = GameWorld.textHandler.getTextFromId("AddRecipeRetryText");
         GameWorld.globalRpcs.retryCancelCallBack = this.onRetryCancel;
         GameWorld.commitGlobalRpcs();
      }
      
      private function onShoutClick(param1:MouseEvent) : void
      {
         GameWorld.setFirstTimeAccess(GameWorld.FIRST_TIME_ACCESS_BIT_ASK_FOR_INGREDIENT);
         this.bottomButtonLayer.mc_shout.mc_new.visible = false;
         var _loc2_:WorldIngredientRequest = new WorldIngredientRequest();
         _loc2_.show();
      }
      
      private function refreshRecipeButtons() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Number = 0;
         while(_loc2_ < this.recipeEntries.length)
         {
            _loc1_ = this.recipeEntries[_loc2_];
            this.setRecipeEntry(_loc1_.recipeConfig,_loc1_);
            if(this.gameUser.isMenuRecipeSelected(_loc1_.recipeConfig.id))
            {
               this.selectRecipe(_loc2_);
            }
            _loc2_++;
         }
      }
      
      private function onMarketButtonClick(param1:MouseEvent) : void
      {
         this.showIngredientShop();
      }
   }
}

