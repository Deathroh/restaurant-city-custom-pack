package com.playfish.games.cooking
{
   import com.playfish.games.cooking.actors.CleanerEmployee;
   import com.playfish.games.cooking.actors.Customer;
   import com.playfish.games.cooking.actors.Waitor;
   import com.playfish.games.cooking.itemfunctions.*;
   import com.playfish.games.cooking.ui.ToolTip;
   import com.playfish.games.cooking.utils.*;
   import flash.display.*;
   import flash.filters.*;
   import flash.geom.Rectangle;
   import flash.utils.*;
   
   public class RoomItem extends GameItemObject
   {
      
      public var tableItem:Boolean = false;
      
      public var fullGridSizeY:int;
      
      public var toiletWater:BaseObject;
      
      public var outdoor:Boolean = false;
      
      public var floorTileItem:Boolean = false;
      
      public var waiter:Waitor;
      
      public var fullGridSizeX:int;
      
      public var menuItem:Boolean = false;
      
      public var toilet:Boolean = false;
      
      public var decorItem:Boolean = false;
      
      public var subItemTileOffsetY:int = 0;
      
      public var itemHeight:Number;
      
      public var subItemTileOffsetX:int = 0;
      
      public var wallpaper:MovieClip;
      
      private var rotationCount:int;
      
      public var wallpaperItem:Boolean = false;
      
      public var doorTimer:int;
      
      public var wallDecorationItem:Boolean = false;
      
      public var roomTileX:int = -1;
      
      public var roomTileY:int = -1;
      
      public var toiletStatus:BaseObject;
      
      public var subItems:Array = null;
      
      public var editable:Boolean = true;
      
      public var musicPlayer:Boolean = false;
      
      public var tileX:int = -1;
      
      public var tileY:int = -1;
      
      public var subItemAutoSplit:Boolean = false;
      
      public var mailItem:Boolean = false;
      
      public var notGiftable:Boolean = false;
      
      private var glowEffect:GlowEffect;
      
      public var chairItem:Boolean = false;
      
      public var bed:Boolean = false;
      
      public var curHeight:int = 0;
      
      public var sink:Boolean = false;
      
      public var drink:Boolean = false;
      
      public var numTilesX:int;
      
      public var noInventory:Boolean = false;
      
      public var notSellable:Boolean = false;
      
      public var numTilesY:int;
      
      public var kitchen:Boolean = false;
      
      public var attachedWalls:Array;
      
      public var gridLayer:Shape;
      
      public var surface:Boolean = false;
      
      public var wallpaperRoomItem:RoomItem;
      
      public var cleaner:CleanerEmployee;
      
      public var roomIndex:int = 0;
      
      public var doorMask:Array;
      
      public var itemFunctions:Array;
      
      public var unique:Boolean = false;
      
      public var canOrderDrink:Boolean;
      
      public var inUserTaskQueue:Boolean = false;
      
      public var parentItem:RoomItem = null;
      
      public var doorItem:Boolean = false;
      
      public var stackable:Boolean = false;
      
      public var toolTip:ToolTip;
      
      public var customer:Customer;
      
      private var tableTopOrderUnico:DishOrder;

      private var rcrLugares:Object = new Object();

      // RCR: o jogo guarda um pedido so por mesa e isTableFree recusa a mesa enquanto ele existe. Numa mesa de
      // 2+ blocos (Zen Table, Long Sushi Table) o lugar e o bloco: cada bloco serve um cliente por vez, o da cadeira
      // que olha para ele (rcrLugarLivre/rcrOcupar/rcrLiberar, chamados por Customer e WorldRestaurantPlay).
      // A mesa de 1 bloco continua como no original.
      public function get tableTopOrder() : DishOrder
      {
         if(this.rcrMesaGrande())
         {
            return null;
         }
         return this.tableTopOrderUnico;
      }

      public function set tableTopOrder(param1:DishOrder) : void
      {
         this.tableTopOrderUnico = param1;
      }

      // a mesa inteira: as fileiras de tras de uma mesa de 2+ blocos sao sub-itens dela
      public function rcrRaizMesa() : RoomItem
      {
         return this.parentItem != null ? this.parentItem : this;
      }

      public function rcrMesaGrande() : Boolean
      {
         var _loc1_:RoomItem = this.rcrRaizMesa();
         return _loc1_.tableItem && _loc1_.numTilesX * _loc1_.numTilesY > 1;
      }

      private static function rcrBloco(param1:RoomItem) : String
      {
         var _loc2_:Object = WorldRestaurant.getFacingTile(param1.tileX,param1.tileY,param1.getRotationCount());
         return _loc2_.x + "," + _loc2_.y;
      }

      public function rcrLugarLivre(param1:RoomItem) : Boolean
      {
         if(!this.rcrMesaGrande() || param1 == null)
         {
            return true;
         }
         var _loc2_:DishOrder = this.rcrRaizMesa().rcrLugares[rcrBloco(param1)];
         // pedido que ficou para tras (cliente foi embora sem passar pelo rcrLiberar) nao segura o lugar
         return _loc2_ == null || _loc2_.customer == null || _loc2_.customer.order != _loc2_;
      }

      public function rcrOcupar(param1:RoomItem, param2:DishOrder) : void
      {
         if(this.rcrMesaGrande() && param1 != null)
         {
            this.rcrRaizMesa().rcrLugares[rcrBloco(param1)] = param2;
         }
      }

      public function rcrLiberar(param1:DishOrder) : void
      {
         var _loc2_:Object = this.rcrRaizMesa().rcrLugares;
         for(var _loc3_:String in _loc2_)
         {
            if(_loc2_[_loc3_] == param1)
            {
               delete _loc2_[_loc3_];
            }
         }
      }

      public var interactive:Boolean = false;
      
      public var canOrderFood:Boolean;
      
      public var usageCount:int;
      
      public var wallDivider:Boolean = false;
      
      public var achievementItem:Boolean = false;
      
      public var operateTimePercentage:int = 100;
      
      public var wallItem:Boolean = false;

      // RCR (2026-11-04, reescrito no mesmo dia): pecas da frente (mc_attach0..) dos arcos de julho/2010 (Sunken
      // Ruins Arch, Wedding Trellis). O item continua cortado em fileiras pelo proprio jogo (subItemAutoSplit, como
      // qualquer item grande); cada mc_attachN sai do desenho cortado e vira UM sub-item proprio, posto no bloco
      // da frente que ele cobre, no quadro do giro (rcrMontarPecas / rcrPosicionarPecas). Sem isso a peca ia junto
      // das fileiras e aparecia solta, um bloco fora do lugar.
      public var rcrEhPeca:Boolean = false;

      public var rcrPecas:Array = null;

      // blocos de passagem (mc_walkable0..), relativos ao bloco do item no giro atual: o cliente passa por baixo
      // do arco (WorldRestaurantPlay.isWalkable). Sem isso o bloco do meio ficava bloqueado.
      public var rcrPassagens:Array = null;

      public function rcrPassavelEm(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         if(this.rcrPassagens == null)
         {
            return false;
         }
         while(_loc3_ < this.rcrPassagens.length)
         {
            if(this.tileX + this.rcrPassagens[_loc3_][0] == param1 && this.tileY + this.rcrPassagens[_loc3_][1] == param2)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }

      public function RoomItem(param1:Object, param2:UserItem, param3:String = null)
      {
         var _loc4_:int = 0;
         if(param3 == null)
         {
            param3 = param1.className;
         }
         super(param1,param2,param3);
         content.stop();
         if(param1.group.types != null)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.group.types.length)
            {
               this[param1.group.types[_loc4_]] = true;
               _loc4_++;
            }
         }
         if(param1.types)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.types.length)
            {
               this[param1.types[_loc4_]] = true;
               _loc4_++;
            }
         }
         if(param1.operateTimePercentage)
         {
            this.operateTimePercentage = int(param1.operateTimePercentage);
         }
         if(content.mc_mask)
         {
            content.mc_mask.visible = false;
         }
         this.rcrSyncPartes();
         var _loc5_:Rectangle = getBounds(this);
         this.numTilesX = Math.max(1,Math.round(_loc5_.right / WorldRestaurant.tileWidthHalf));
         this.numTilesY = Math.max(1,Math.round(_loc5_.bottom / WorldRestaurant.tileHeightHalf) - this.numTilesX);
         if(param1.sizeX)
         {
            this.numTilesX = param1.sizeX;
         }
         if(param1.sizeY)
         {
            this.numTilesY = param1.sizeY;
         }
         this.setGridSize(this.numTilesX,this.numTilesY);
         this.fullGridSizeX = this.numTilesX;
         this.fullGridSizeY = this.numTilesY;
         // RCR (2026-11-04): o pe do desenho de um item NxM fica em tileHeight*(N+M)/2 (o losango do piso); o
         // original usava tileHeight*numTilesY, certo so para itens quadrados. Num item de 1x2 (Zen Table, Long
         // Sushi Table) o tampo saia 20 px alto e o prato e o que se punha em cima flutuavam. Antes isso era
         // compensado no desenho recriado, que saiu quando as mesas viraram as originais de julho/2010.
         this.itemHeight = -_loc5_.top + (WorldRestaurant.tileHeight * (this.numTilesX + this.numTilesY) / 2 - _loc5_.bottom);
         // RCR (2026-11-03): ?semcache=1 na pagina do jogo desliga o cacheAsBitmap dos itens (diagnostico:
         // no painel do app os itens com cache nao apareciam)
         if(!this.isAnimated(content,true) && !rcrSemCache())
         {
            cacheAsBitmap = true;
         }
         // RCR (2026-11-04) diagnostico: area calculada do Washington Monument (a dona viu o gramado cortado)
         if(param3 == "AFWashingtonMonument")
         {
            PerfTrace.mark("[RCR-DIAG] " + param3 + " bounds=" + Math.round(_loc5_.left) + "," + Math.round(_loc5_.top) + "," + Math.round(_loc5_.right) + "," + Math.round(_loc5_.bottom) + " numTiles=" + this.numTilesX + "x" + this.numTilesY + " itemHeight=" + Math.round(this.itemHeight) + " frames=" + content.totalFrames);
         }
         Debug.out(param3 + " numTileX=" + this.numTilesX + " numTileY=" + this.numTilesY + " itemHeight=" + this.itemHeight + " cacheAsBitmap=" + cacheAsBitmap);
      }
      
      private static function getRowMask(param1:RoomItem, param2:int) : Shape
      {
         // RCR: em superficie (mesa que aceita itens em cima) a fileira da frente so cobre ate o tampo;
         // com a margem de 20 px ela tapava a metade de baixo do que estava em cima do bloco de tras.
         var _loc3_:Number = param1.itemHeight + (param1.surface ? 0 : 20);
         var _loc4_:Shape = new Shape();
         _loc4_.graphics.beginFill(255 << param2 * 8,1);
         _loc4_.graphics.moveTo(WorldRestaurant.getScreenX(0,param2 + 1),WorldRestaurant.getScreenY(0,param2 + 1));
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(param1.fullGridSizeX,param2 + 1),WorldRestaurant.getScreenY(param1.fullGridSizeX,param2 + 1));
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(param1.fullGridSizeX,param2),WorldRestaurant.getScreenY(param1.fullGridSizeX,param2));
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(param1.fullGridSizeX,param2),WorldRestaurant.getScreenY(param1.fullGridSizeX,param2) - _loc3_);
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(0,param2),WorldRestaurant.getScreenY(0,param2) - _loc3_);
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(0,param2 + 1),WorldRestaurant.getScreenY(0,param2 + 1) - _loc3_);
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(0,param2 + 1),WorldRestaurant.getScreenY(0,param2 + 1));
         _loc4_.graphics.endFill();
         return _loc4_;
      }
      
      public static function createRoomItems(param1:Object, param2:UserItem) : RoomItem
      {
         var _loc3_:RoomItem = null;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc6_:RoomItem = null;
         var _loc7_:RoomItem = null;
         var _loc8_:Shape = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:RoomItem = new RoomItem(param1,null);
         if(_loc11_.content["sub0"])
         {
            _loc3_ = new RoomItem(param1,null,getQualifiedClassName(_loc11_.content["sub0"]));
            _loc3_.subItems = new Array();
            _loc4_ = 1;
            while(true)
            {
               _loc5_ = _loc11_.content["sub" + _loc4_];
               if(!_loc5_)
               {
                  break;
               }
               _loc6_ = new RoomItem(param1,null,getQualifiedClassName(_loc5_));
               _loc6_.parentItem = _loc3_;
               _loc6_.subItemTileOffsetX = WorldRestaurant.getTileIndexX(_loc5_.x,_loc5_.y);
               _loc6_.subItemTileOffsetY = WorldRestaurant.getTileIndexY(_loc5_.x,_loc5_.y);
               _loc3_.subItems.push(_loc6_);
               _loc3_.fullGridSizeX = Math.max(_loc3_.fullGridSizeX,_loc6_.subItemTileOffsetX + 1);
               _loc3_.fullGridSizeY = Math.max(_loc3_.fullGridSizeY,_loc6_.subItemTileOffsetY + 1);
               _loc4_++;
            }
            if(param2)
            {
               _loc3_.setUserItem(param2);
            }
            return _loc3_;
         }
         if(_loc11_.numTilesX > 1 || _loc11_.numTilesY > 1)
         {
            _loc11_.subItemAutoSplit = true;
            _loc11_.subItems = new Array();
            if(_loc11_.numTilesX == _loc11_.numTilesY)
            {
               _loc7_ = new RoomItem(param1,null);
               _loc7_.mouseEnabled = false;
               _loc7_.mouseChildren = false;
               _loc7_.setGridSize(0,0);
               _loc7_.parentItem = _loc11_;
               _loc8_ = getLeftHalfMask(_loc11_);
               _loc7_.content.addChild(_loc8_);
               _loc7_.content.mask = _loc8_;
               _loc7_.subItemTileOffsetX = _loc11_.fullGridSizeX - 1;
               _loc7_.subItemTileOffsetY = _loc11_.fullGridSizeY - 1;
               _loc7_.content.x = -WorldRestaurant.getScreenX(_loc7_.subItemTileOffsetX,_loc7_.subItemTileOffsetY);
               _loc7_.content.y = -WorldRestaurant.getScreenY(_loc7_.subItemTileOffsetX,_loc7_.subItemTileOffsetY);
               _loc11_.subItems.push(_loc7_);
            }
            else
            {
               _loc9_ = Math.max(_loc11_.fullGridSizeX,_loc11_.fullGridSizeY);
               _loc10_ = 1;
               while(_loc10_ < _loc9_)
               {
                  _loc7_ = new RoomItem(param1,null);
                  _loc7_.mouseEnabled = false;
                  _loc7_.mouseChildren = false;
                  _loc7_.setGridSize(0,0);
                  _loc7_.parentItem = _loc11_;
                  _loc8_ = getRowMask(_loc11_,_loc10_);
                  _loc7_.content.addChild(_loc8_);
                  _loc7_.content.mask = _loc8_;
                  _loc7_.subItemTileOffsetX = 0;
                  _loc7_.subItemTileOffsetY = _loc10_;
                  _loc7_.content.x = -WorldRestaurant.getScreenX(_loc7_.subItemTileOffsetX,_loc7_.subItemTileOffsetY);
                  _loc7_.content.y = -WorldRestaurant.getScreenY(_loc7_.subItemTileOffsetX,_loc7_.subItemTileOffsetY);
                  _loc11_.subItems.push(_loc7_);
                  if(_loc10_ >= _loc11_.fullGridSizeY)
                  {
                     _loc7_.visible = false;
                  }
                  _loc10_++;
               }
            }
         }
         rcrMontarPecas(_loc11_,param1);
         if(param2)
         {
            _loc11_.setUserItem(param2);
         }
         return _loc11_;
      }
      
      // cria um sub-item para cada mc_attachN do desenho (nada acontece nos itens sem essas pecas)
      private static function rcrMontarPecas(param1:RoomItem, param2:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc5_:RoomItem = null;
         while((_loc4_ = param1.content["mc_attach" + _loc3_] as MovieClip) != null)
         {
            if(param1.rcrPecas == null)
            {
               param1.rcrPecas = new Array();
               if(param1.subItems == null)
               {
                  param1.subItems = new Array();
               }
            }
            _loc5_ = new RoomItem(param2,null,getQualifiedClassName(_loc4_));
            _loc5_.rcrEhPeca = true;
            _loc5_.mouseEnabled = false;
            _loc5_.mouseChildren = false;
            _loc5_.setGridSize(0,0);
            _loc5_.parentItem = param1;
            param1.rcrPecas.push(_loc5_);
            param1.subItems.push(_loc5_);
            _loc3_++;
         }
         param1.rcrPosicionarPecas();
      }

      // poe cada peca no quadro do giro atual e no bloco da frente que ela cobre, sem mudar onde ela aparece na
      // tela; e guarda os blocos de passagem (mc_walkable) do giro atual
      public function rcrPosicionarPecas() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc3_:RoomItem = null;
         var _loc4_:Rectangle = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         this.rcrPassagens = new Array();
         while((_loc2_ = content["mc_walkable" + _loc1_] as MovieClip) != null)
         {
            this.rcrPassagens.push([Math.round((_loc2_.x + 2 * _loc2_.y) / WorldRestaurant.tileWidth),Math.round((2 * _loc2_.y - _loc2_.x) / (2 * WorldRestaurant.tileHeight))]);
            _loc1_++;
         }
         if(this.rcrPecas == null)
         {
            return;
         }
         _loc1_ = 0;
         while(_loc1_ < this.rcrPecas.length)
         {
            _loc3_ = this.rcrPecas[_loc1_];
            _loc2_ = content["mc_attach" + _loc1_] as MovieClip;
            _loc3_.content.gotoAndStop(content.currentFrame <= _loc3_.content.totalFrames ? content.currentFrame : 1);
            if(_loc2_ != null)
            {
               // canto de baixo da peca na tela -> bloco da frente que ela cobre (projecao isometrica inversa)
               _loc4_ = _loc3_.content.getBounds(_loc3_.content);
               _loc5_ = Math.max(0,Math.min(this.numTilesX - 1,Math.round((_loc2_.x + 2 * (_loc2_.y + _loc4_.bottom)) / WorldRestaurant.tileWidth) - 1));
               _loc6_ = Math.max(0,Math.min(this.numTilesY - 1,Math.round((2 * (_loc2_.y + _loc4_.bottom) - _loc2_.x) / WorldRestaurant.tileWidth) - 1));
               _loc3_.subItemTileOffsetX = _loc5_;
               _loc3_.subItemTileOffsetY = _loc6_;
               _loc3_.content.x = _loc2_.x - WorldRestaurant.getScreenX(_loc5_,_loc6_);
               _loc3_.content.y = _loc2_.y - WorldRestaurant.getScreenY(_loc5_,_loc6_);
            }
            _loc3_.setTilePosition(this.tileX + _loc3_.subItemTileOffsetX,this.tileY + _loc3_.subItemTileOffsetY);
            _loc1_++;
         }
      }

      private static function getLeftHalfMask(param1:RoomItem) : Shape
      {
         var _loc2_:int = Math.max(param1.fullGridSizeX,param1.fullGridSizeY);
         var _loc3_:Number = param1.itemHeight + 20;
         var _loc4_:Shape = new Shape();
         _loc4_.graphics.beginFill(0,1);
         _loc4_.graphics.moveTo(0,-_loc3_);
         _loc4_.graphics.lineTo(0,WorldRestaurant.getScreenY(_loc2_,_loc2_));
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(0,_loc2_),WorldRestaurant.getScreenY(0,_loc2_));
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(0,_loc2_),WorldRestaurant.getScreenY(0,_loc2_) - _loc3_);
         _loc4_.graphics.endFill();
         return _loc4_;
      }
      
      private static function getRightHalfMask(param1:RoomItem) : Shape
      {
         var _loc2_:int = Math.max(param1.fullGridSizeX,param1.fullGridSizeY);
         var _loc3_:Number = param1.itemHeight + 20;
         var _loc4_:Shape = new Shape();
         _loc4_.graphics.beginFill(0,1);
         _loc4_.graphics.moveTo(0,-_loc3_);
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(param1.numTilesX,param1.numTilesY),WorldRestaurant.getScreenY(param1.numTilesX,param1.numTilesY));
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(param1.numTilesX,0),WorldRestaurant.getScreenY(param1.numTilesX,0));
         _loc4_.graphics.lineTo(WorldRestaurant.getScreenX(param1.numTilesX,0),WorldRestaurant.getScreenY(param1.numTilesX,0) - _loc3_);
         _loc4_.graphics.endFill();
         return _loc4_;
      }
      
      override public function setUserItem(param1:UserItem) : void
      {
         super.setUserItem(param1);
         this.roomTileX = param1.x;
         this.roomTileY = param1.y;
         this.setTilePosition(param1.x,param1.y);
         this.roomIndex = param1.roomIndex;
         var _loc2_:int = param1.data as int;
         this.setRotation(_loc2_ & 0x0F);
         this.usageCount = (_loc2_ & 0xF0) >> 4;
      }
      
      public function setRotation(param1:int) : void
      {
         // RCR (2026-11-03): item sem giro (Magic Water Tile) ignora o giro salvo
         if(this.getMaxRotationCount() <= 1)
         {
            return;
         }
         param1 %= this.getMaxRotationCount();
         var _loc2_:int = this.getRotationCount();
         var _loc3_:int = 0;
         if(param1 > _loc2_)
         {
            _loc3_ = param1 - _loc2_;
         }
         else if(param1 < _loc2_)
         {
            _loc3_ = this.getMaxRotationCount() - _loc2_ + param1;
         }
         var _loc4_:Number = 0;
         while(_loc4_ < _loc3_)
         {
            this.rotate();
            _loc4_++;
         }
      }
      
      public function setGridSize(param1:int, param2:int) : void
      {
         this.numTilesX = param1;
         this.numTilesY = param2;
      }
      
      public function copyRotation(param1:RoomItem) : void
      {
         this.setRotation(param1.getRotationCount());
      }
      
      public function getTopHeight() : Number
      {
         return this.itemHeight + this.curHeight;
      }
      
      public function setHeight(param1:int) : void
      {
         var _loc2_:Number = NaN;
         if(param1 != this.curHeight)
         {
            y += this.curHeight;
            this.curHeight = param1;
            y -= this.curHeight;
            if(this.gridLayer != null)
            {
               this.gridLayer.y = this.curHeight;
            }
            if(this.subItems != null)
            {
               _loc2_ = 0;
               while(_loc2_ < this.subItems.length)
               {
                  this.subItems[_loc2_].setHeight(this.curHeight);
                  _loc2_++;
               }
            }
         }
      }
      
      override public function manipulate(param1:int) : void
      {
         var _loc2_:Number = NaN;
         super.manipulate(param1);
         if(this.subItems != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this.subItems.length)
            {
               this.subItems[_loc2_].manipulate(param1);
               _loc2_++;
            }
         }
      }
      
      public function rotate() : void
      {
         var _loc1_:RoomItem = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Shape = null;
         this.rotationCount = (this.rotationCount + 1) % this.getMaxRotationCount();
         this.setGridSize(this.numTilesY,this.numTilesX);
         var _loc5_:int = this.fullGridSizeX;
         this.fullGridSizeX = this.fullGridSizeY;
         this.fullGridSizeY = _loc5_;
         if(content.currentFrame == content.totalFrames)
         {
            content.gotoAndStop(1);
         }
         else
         {
            content.nextFrame();
         }
         this.rcrSyncPartes();
         if(this.subItems != null)
         {
            if(this.subItemAutoSplit)
            {
               if(this.fullGridSizeX == this.fullGridSizeY)
               {
                  _loc1_ = this.subItems[0];
                  _loc1_.rotate();
                  _loc1_.subItemTileOffsetX = this.fullGridSizeX - 1;
                  _loc1_.subItemTileOffsetY = this.fullGridSizeY - 1;
                  _loc1_.content.x = -WorldRestaurant.getScreenX(_loc1_.subItemTileOffsetX,_loc1_.subItemTileOffsetY);
                  _loc1_.content.y = -WorldRestaurant.getScreenY(_loc1_.subItemTileOffsetX,_loc1_.subItemTileOffsetY);
                  _loc1_.setTilePosition(this.tileX + _loc1_.subItemTileOffsetX,this.tileY + _loc1_.subItemTileOffsetY);
               }
               else
               {
                  _loc2_ = 0;
                  while(_loc2_ < this.subItems.length)
                  {
                     _loc1_ = this.subItems[_loc2_];
                     if(_loc1_.rcrEhPeca)
                     {
                        _loc2_++;
                        continue;
                     }
                     _loc1_.rotate();
                     _loc3_ = _loc2_ + 1;
                     if(_loc3_ < this.fullGridSizeY)
                     {
                        if(_loc1_.content.mask)
                        {
                           _loc1_.content.removeChild(_loc1_.content.mask);
                           _loc1_.content.mask = null;
                        }
                        _loc4_ = getRowMask(this,_loc2_ + 1);
                        _loc1_.content.addChild(_loc4_);
                        _loc1_.content.mask = _loc4_;
                        _loc1_.visible = true;
                     }
                     else
                     {
                        _loc1_.visible = false;
                     }
                     _loc2_++;
                  }
               }
            }
            else
            {
               _loc2_ = 0;
               while(_loc2_ < this.subItems.length)
               {
                  this.subItems[_loc2_].rotate();
                  _loc5_ = int(this.subItems[_loc2_].subItemTileOffsetX);
                  this.subItems[_loc2_].subItemTileOffsetX = -this.subItems[_loc2_].subItemTileOffsetY;
                  this.subItems[_loc2_].subItemTileOffsetY = _loc5_;
                  this.subItems[_loc2_].setTilePosition(this.tileX + this.subItems[_loc2_].subItemTileOffsetX,this.tileY + this.subItems[_loc2_].subItemTileOffsetY);
                  _loc2_++;
               }
            }
         }
         this.rcrPosicionarPecas();
      }
      
      public function clone() : RoomItem
      {
         var _loc1_:RoomItem = createRoomItems(itemConfig,this.getUserItem());
         _loc1_.editable = this.editable;
         return _loc1_;
      }
      
      public function initFunctions(param1:WorldRestaurantPlay) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:RoomItemFunction = null;
         if(itemConfig.functions)
         {
            _loc2_ = itemConfig.functions.split(/\s*,\s*/);
            if(_loc2_.length > 0)
            {
               this.itemFunctions = new Array();
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  _loc4_ = RoomItemFunction.create(_loc2_[_loc3_],this);
                  if(_loc4_)
                  {
                     this.itemFunctions.push(_loc4_);
                     _loc4_.init(param1);
                  }
                  _loc3_++;
               }
               if(this.itemFunctions.length <= 0)
               {
                  this.itemFunctions = null;
               }
            }
         }
      }
      
      public function getRotationCount() : int
      {
         return this.rotationCount;
      }

      // RCR: bloco por onde o cliente entra e sai. Nas portas originais e o proprio bloco da porta; numa porta
      // recriada de 2 blocos (RCR_*) o vao fica no segundo bloco (y+1 na parede esquerda, x+1 na de cima).
      public function getEntranceTileX() : int
      {
         if(this.doorItem && this.fullGridSizeX > 1 && String(itemConfig.className).indexOf("RCR_") == 0)
         {
            return tileX + 1;
         }
         return tileX;
      }

      public function getEntranceTileY() : int
      {
         if(this.doorItem && this.fullGridSizeY > 1 && String(itemConfig.className).indexOf("RCR_") == 0)
         {
            return tileY + 1;
         }
         return tileY;
      }

      public function setTilePosition(param1:int, param2:int) : void
      {
         var _loc3_:Number = NaN;
         this.tileX = param1;
         this.tileY = param2;
         x = WorldRestaurant.getScreenX(this.tileX,this.tileY);
         y = WorldRestaurant.getScreenY(this.tileX,this.tileY) - this.curHeight;
         if(this.subItems != null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.subItems.length)
            {
               this.subItems[_loc3_].setTilePosition(param1 + this.subItems[_loc3_].subItemTileOffsetX,param2 + this.subItems[_loc3_].subItemTileOffsetY);
               _loc3_++;
            }
         }
      }
      
      public function glow(param1:Boolean, param2:int = 16777215) : void
      {
         var _loc3_:Number = NaN;
         if(param1)
         {
            if(this.glowEffect == null)
            {
               this.glowEffect = new GlowEffect(this,param2);
            }
         }
         else if(this.glowEffect != null)
         {
            this.glowEffect.remove();
            this.glowEffect = null;
         }
         if(this.subItems != null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.subItems.length)
            {
               this.subItems[_loc3_].glow(param1,param2);
               _loc3_++;
            }
         }
      }
      
      override public function tick(param1:uint) : void
      {
         var _loc2_:int = 0;
         if(this.itemFunctions)
         {
            _loc2_ = 0;
            while(_loc2_ < this.itemFunctions.length)
            {
               this.itemFunctions[_loc2_].tick(param1);
               _loc2_++;
            }
         }
      }
      
      public function getMaxRotationCount() : int
      {
         if(this.subItems != null && !this.subItemAutoSplit)
         {
            return 4;
         }
         // RCR (2026-11-03), itens de julho/2010 cujo clip tem quadros que nao sao giros:
         // bichos (MovingActor): quadros 1-4 sao os giros, 5+ sao poses de parado;
         // Magic Water Tile: os 16 quadros sao as bordas (escolhidas pelo efeito), entao nao gira.
         var _loc1_:String = itemConfig != null && itemConfig.functions ? String(itemConfig.functions) : "";
         if(_loc1_.indexOf("MagicWaterTile") >= 0)
         {
            return 1;
         }
         if(_loc1_.indexOf("MovingActor") >= 0)
         {
            return Math.min(4,content.totalFrames);
         }
         return content.totalFrames;
      }
      
      public function isBroken() : Boolean
      {
         return Boolean(itemConfig.breakCount) && this.usageCount >= itemConfig.breakCount;
      }
      
      public function hideGrid() : void
      {
         var _loc1_:Number = NaN;
         if(Boolean(this.gridLayer) && Boolean(this.gridLayer.parent))
         {
            this.gridLayer.parent.removeChild(this.gridLayer);
            if(this.subItems != null)
            {
               _loc1_ = 0;
               while(_loc1_ < this.subItems.length)
               {
                  this.subItems[_loc1_].hideGrid();
                  _loc1_++;
               }
            }
         }
      }
      
      public function isRotatable() : Boolean
      {
         if(this.wallDecorationItem || this.wallItem)
         {
            return false;
         }
         return this.getMaxRotationCount() > 1;
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         x = param1;
         y = param2 - this.curHeight;
         if(this.subItems != null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.subItems.length)
            {
               this.subItems[_loc3_].setPosition(param1 + WorldRestaurant.getScreenX(this.subItems[_loc3_].subItemTileOffsetX,this.subItems[_loc3_].subItemTileOffsetY),param2 + WorldRestaurant.getScreenY(this.subItems[_loc3_].subItemTileOffsetX,this.subItems[_loc3_].subItemTileOffsetY));
               _loc3_++;
            }
         }
      }
      
      public function getBytes() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeUnsignedInt(itemConfig.nameHash);
         _loc1_.writeShort(this.tileX);
         _loc1_.writeShort(this.tileY);
         _loc1_.writeByte(this.getRotationCount());
         _loc1_.writeBoolean(this.editable);
         return _loc1_;
      }
      
      public function destroyFunctions() : void
      {
         var _loc1_:int = 0;
         if(this.itemFunctions)
         {
            _loc1_ = 0;
            while(_loc1_ < this.itemFunctions.length)
            {
               this.itemFunctions[_loc1_].destroy();
               _loc1_++;
            }
            this.itemFunctions = null;
         }
      }
      
      public function setGrid(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         if(this.numTilesX > 0 && this.numTilesY > 0)
         {
            if(this.gridLayer == null)
            {
               if(!this.floorTileItem && !this.wallDecorationItem)
               {
                  this.gridLayer = new Shape();
               }
            }
         }
         if(this.gridLayer != null)
         {
            this.gridLayer.graphics.clear();
            this.gridLayer.y = this.curHeight;
            if(param1)
            {
               WorldRestaurant.paintGrid(this.gridLayer,0,0,this.numTilesX,this.numTilesY,10551200,5308240,0.5);
            }
            else
            {
               WorldRestaurant.paintGrid(this.gridLayer,0,0,this.numTilesX,this.numTilesY,16744576,16711680,0.5);
            }
            if(this.subItems != null)
            {
               _loc2_ = 0;
               while(_loc2_ < this.subItems.length)
               {
                  this.subItems[_loc2_].setGrid(param1);
                  _loc2_++;
               }
            }
         }
      }
      
      public function showGrid() : void
      {
         var _loc1_:Number = NaN;
         if(Boolean(this.gridLayer) && !contains(this.gridLayer))
         {
            addChildAt(this.gridLayer,0);
            if(this.subItems != null)
            {
               _loc1_ = 0;
               while(_loc1_ < this.subItems.length)
               {
                  this.subItems[_loc1_].showGrid();
                  _loc1_++;
               }
            }
         }
      }
      
      // RCR (2026-11-03): pecas de passar por baixo da build de julho/2010 (Sunken Ruins Arch, Wedding Trellis,
      // Lounge Bar). mc_walkable0.. e so o marcador verde do bloco de passagem: fica escondido. mc_attach0.. e a
      // parte de cima, com um quadro por giro e sem stop (ficava piscando entre os giros): para no quadro do giro
      // atual. Chamado na criacao e a cada rotate(); nos itens sem essas pecas nao faz nada.
      private static function rcrSemCache() : Boolean
      {
         try
         {
            return Engine.instance != null && Engine.instance.loaderInfo != null && Engine.instance.loaderInfo.parameters["semcache"] == "1";
         }
         catch(e:Error)
         {
         }
         return false;
      }

      // RCR (2026-11-03): poe o clip do item num quadro (Magic Water Tile: o quadro diz quais bordas aparecem)
      public function rcrQuadro(param1:int) : void
      {
         if(content != null && param1 >= 1 && param1 <= content.totalFrames && content.currentFrame != param1)
         {
            content.gotoAndStop(param1);
         }
      }

      private function rcrSyncPartes() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         while((_loc2_ = content["mc_walkable" + _loc1_] as MovieClip) != null)
         {
            _loc2_.visible = false;
            _loc1_++;
         }
         _loc1_ = 0;
         while((_loc2_ = content["mc_attach" + _loc1_] as MovieClip) != null)
         {
            _loc2_.stop();
            _loc2_.visible = false;
            _loc1_++;
         }
      }

      private function isAnimated(param1:MovieClip, param2:Boolean = false) : Boolean
      {
         var _loc3_:DisplayObject = null;
         if(!param2 && param1.totalFrames > 1)
         {
            return true;
         }
         var _loc4_:int = 0;
         while(_loc4_ < param1.numChildren)
         {
            _loc3_ = param1.getChildAt(_loc4_);
            if(_loc3_ is MovieClip)
            {
               if(this.isAnimated(MovieClip(_loc3_)))
               {
                  return true;
               }
            }
            _loc4_++;
         }
         return false;
      }
      
      override public function getUserItem() : UserItem
      {
         var _loc1_:UserItem = super.getUserItem();
         _loc1_.x = this.roomTileX;
         _loc1_.y = this.roomTileY;
         _loc1_.data = this.getRotationCount() | this.usageCount << 4;
         _loc1_.roomIndex = this.roomIndex;
         return _loc1_;
      }
   }
}

