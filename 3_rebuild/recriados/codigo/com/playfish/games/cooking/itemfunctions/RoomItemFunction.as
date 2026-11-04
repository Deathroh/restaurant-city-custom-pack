package com.playfish.games.cooking.itemfunctions
{
   import com.playfish.games.cooking.Engine;
   import com.playfish.games.cooking.PerfTrace;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import com.playfish.games.cooking.RoomItem;
   import com.playfish.games.cooking.WorldRestaurant;
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

      private var walkerPet:Boolean = false;

      // visibilidade das fatias do item (item de varios blocos e cortado por fileira) antes de o bicho sair andando
      private var walkerSubVisible:Array = null;

      // recriado (2026-11-03): funcao "CheshireCatFunction" (Pet Cheshire Cat, julho/2010). O codigo original nao
      // existe em nenhuma build que temos; isto e nosso, a partir da arte. CheshireCatInside1 > mc_content tem:
      //   idle (1-45, repete), appear (46-102: o sorriso surge e o corpo aparece; volta ao idle),
      //   disappear (103-130: o corpo some e ficam so os olhos; para no fim).
      // Com o restaurante aberto: parado 8-20 s, some (sobram os olhos) por 5-12 s e reaparece.
      private var cheshire:Boolean = false;

      private var cheshireSumido:Boolean = false;

      private var cheshireTimer:int = 0;

      // AlienGooTrash: simbolos a mais para a sujeira do chao (como BananaTrash)
      private var lixoExtra:Array = null;

      // MagicWaterTile (2026-11-03). A arte tem 16 quadros: quadro = 1 + soma dos lados com agua vizinha
      // (nordeste/y-1 = 1, sudeste/x+1 = 2, sudoeste/y+1 = 4, noroeste/x-1 = 8; lido da arte, quadro 16 = cercado).
      // corner1..4 sao os vertices de cima, direita, baixo e esquerda: somem quando os dois lados e a diagonal
      // daquele vertice tem agua. Peixes: MagicWaterTileEffect01..03 no proprio bloco, um de cada vez, a cada 6-20 s.
      private var agua:Boolean = false;

      private var aguaMundo:WorldRestaurantPlay;

      private var aguaTimer:int = 0;

      private var aguaPeixe:EffectObject = null;

      // SushiBelt (2026-11-03; regra corrigida pela dona em 2026-11-04). Cada prato da esteira (mc_plate0..7 no
      // SushiBelt_Animation) e de uma das 8 receitas do Sushi Bar e so mostra a comida quando essa receita esta
      // SELECIONADA no cardapio do dono daquele restaurante (como os pratos servidos), no nivel dela: como o
      // DishOrder do jogo, a comida fica no quadro 1 (prato cheio; os outros quadros sao o prato sendo comido) e o
      // mc_plate dela vai para o quadro do nivel. O prato da comida cobre o prato branco da esteira inteiro.
      // Receita que o dono nao tem ou nao selecionou: prato vazio. Hoje so o Yakibuta Ramen existe no nosso
      // recipe.xml; as outras 7 vem com a etapa das receitas de julho.
      // Arte: game_asset2.swf de julho (copiar_julho2010.cjs, fonte filtrada); FoodItem48 e de fevereiro.
      private static const SUSHI_COMIDAS:Array = ["FoodItem111","FoodItem108","FoodItem110","FoodItem113","FoodItem48","FoodItem109","FoodItem114","FoodItem112"];

      // Salmon Sashimi, Miso Soup, Yaki Gyoza, Seaweed Salad, Yakibuta Ramen, Sushi Selection, Salmon Handrolls, Sakura Mochi
      private static const SUSHI_RECEITAS:Array = [5100044,5000031,5000032,5000033,5100018,5100043,5100045,5200033];

      private var sushiMundo:WorldRestaurantPlay = null;

      private var sushi:Boolean = false;

      private var sushiTimer:int = 0;

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
            // ---- funcoes de julho/2010, recriadas em 2026-11-03 com as classes de fevereiro e a arte de julho ----
            case "SakuraLeavesGenerator":
               // Cherry Blossom Tree original: folhas de cerejeira dela (SakuraTreeLeaf01..03), fisica da petala
               return new SnowGenerator(param2,true,{"simbolos":["SakuraTreeLeaf01","SakuraTreeLeaf02","SakuraTreeLeaf03"],"modo":"petala","max":12});
            case "RainDropGenerator":
               // Rain Cloud: gotas caindo pelo salao
               return new SnowGenerator(param2,false,{"simbolos":["RainDropIndoor"],"modo":"cai","max":14,"velMin":6,"velMax":9});
            case "MusicNoteGenerator":
               // Musical Note: notas subindo
               return new SnowGenerator(param2,false,{"simbolos":["MusicNote01","MusicNote02","MusicNote03","MusicNote04"],"modo":"sobe","max":8});
            case "ButterflyGenerator":
               // Magic Unicorn: borboletas voando
               return new SnowGenerator(param2,false,{"simbolos":["BlueButterfly","OrangeButterfly","WhiteButterfly"],"modo":"sobe","max":6});
            // FishSchoolGenerator (Coral Garden): sem efeito extra. Os dois peixes que flutuam no proprio bloco ja
            // estao na animacao do item. Em 2026-11-04 foi posto um cardume nadando pelo salao (lido de um texto do
            // blog de 2010) e a dona corrigiu: no original nao havia isso. Retirado.
            case "FlowerFootprint":
               // Spring Goddess Statue: clientes deixam florzinhas pelo caminho (como as folhas de outono)
               return new FootprintGenerator(param2,"SpringEffect");
            case "RosePetalFootprint":
               // Ice Swans Sculpture: petalas de rosa pelo caminho
               return new FootprintGenerator(param2,"WeddingIndoorEffect");
            case "AddMaxDemand25":
               // Onyx Obelisk: +25 de demanda maxima
               return new AddMaxDemand(param2,25);
            case "AlienGooTrash":
               // Alien Statue: a sujeira do chao vira gosma alien (Slime01..04), como a casca de banana
               var _loc7_:RoomItemFunction = new RoomItemFunction(param2);
               _loc7_.lixoExtra = ["Slime01","Slime02","Slime03","Slime04"];
               return _loc7_;
            case "SushiBelt":
               // Sushi Bar / Neon Sushi Bar: comida nos 8 pratos da esteira (ver sushiPratos)
               var _loc9_:RoomItemFunction = new RoomItemFunction(param2);
               _loc9_.sushi = true;
               return _loc9_;
            case "MagicWaterTile":
               // Magic Water Tile / Dark: bordas que se juntam com a agua vizinha e peixes pulando de vez em quando
               var _loc8_:RoomItemFunction = new RoomItemFunction(param2);
               _loc8_.agua = true;
               return _loc8_;
            case "PetalGenerator":
               // recriado (2026-10-26): petalas de cerejeira caindo pelo salao (Cherry Blossom Tree RCR, petalas
               // RCR_Petal01..03). A arvore original de julho tem o caso SakuraLeavesGenerator acima.
               return new SnowGenerator(param2,true);
            case "RobotWalker":
               // recriado (2026-10-28): o Monster Robot passeia pelo salao
               var _loc4_:RoomItemFunction = new RoomItemFunction(param2);
               _loc4_.walkerClass = param2.itemConfig.className + "Andando";
               return _loc4_;
            case "MovingActor":
               // recriado (2026-11-03): bichos de julho/2010 (Alien Pets, Pet Chick, Pet Bunny, Sea Horse, Monster
               // Robot). Mesmo passeio do RobotWalker, com a arte do proprio item: quadros 1-4 = andando em cada
               // direcao; 5-6 (ou 5-8) = pose parada, quando a arte tem (ver MovingVisitActor.startPet).
               var _loc5_:RoomItemFunction = new RoomItemFunction(param2);
               _loc5_.walkerClass = param2.itemConfig.className;
               _loc5_.walkerPet = true;
               return _loc5_;
            case "CheshireCatFunction":
               var _loc6_:RoomItemFunction = new RoomItemFunction(param2);
               _loc6_.cheshire = true;
               return _loc6_;
         }
         if(_loc3_)
         {
            return new _loc3_(param2);
         }
         return null;
      }
      
      public function init(param1:WorldRestaurantPlay) : void
      {
         if(this.sushi)
         {
            this.sushiMundo = param1;
         }
         if(this.lixoExtra != null)
         {
            param1.trashItems = param1.trashItems.concat(this.lixoExtra);
         }
         if(this.agua)
         {
            this.aguaMundo = param1;
            this.aguaTimer = Engine.rnd(3000,20001);
            this.aguaBordas();
         }
         if(this.cheshire)
         {
            this.cheshireSumido = false;
            this.cheshireTimer = Engine.rnd(8000,20001);
         }
         if(this.walkerClass)
         {
            this.walkerWorld = param1;
            this.walker = new MovingVisitActor(this.walkerClass,param1);
            this.walker.placeNear(this.roomItem.tileX,this.roomItem.tileY);
            if(this.walkerPet)
            {
               this.walker.startPet(this.roomItem.getRotationCount());
            }
            else
            {
               this.walker.startRobot(this.roomItem.getRotationCount());
            }
            this.walker.mouseEnabled = false;
            this.walker.mouseChildren = false;
            param1.room.addObject(this.walker);
            this.roomItem.visible = false;
            if(this.roomItem.subItems != null)
            {
               this.walkerSubVisible = [];
               for each(var _loc2_:RoomItem in this.roomItem.subItems)
               {
                  this.walkerSubVisible.push(_loc2_.visible);
                  _loc2_.visible = false;
               }
            }
            PerfTrace.mark("[RCR] RobotWalker: item em " + this.roomItem.tileX + "," + this.roomItem.tileY + "; robo comeca em " + this.walker.tileX + "," + this.walker.tileY);
         }
      }

      public function destroy() : void
      {
         if(this.aguaPeixe != null)
         {
            if(!this.aguaPeixe.removed)
            {
               this.aguaPeixe.remove();
            }
            this.aguaPeixe = null;
         }
         if(this.cheshire && this.cheshireSumido)
         {
            // fora do modo de jogo o gato volta inteiro
            this.cheshireTocar("idle");
            this.cheshireSumido = false;
         }
         if(this.walker)
         {
            this.walkerWorld.room.removeObject(this.walker);
            this.walker.destroy();
            this.walker = null;
            this.roomItem.visible = true;
            if(this.walkerSubVisible != null && this.roomItem.subItems != null)
            {
               var _loc1_:int = 0;
               while(_loc1_ < this.walkerSubVisible.length && _loc1_ < this.roomItem.subItems.length)
               {
                  this.roomItem.subItems[_loc1_].visible = this.walkerSubVisible[_loc1_];
                  _loc1_++;
               }
               this.walkerSubVisible = null;
            }
         }
      }
      
      public function tick(param1:uint) : void
      {
         if(this.sushi)
         {
            this.sushiTimer -= param1;
            if(this.sushiTimer <= 0)
            {
               this.sushiTimer = 1000;
               this.sushiPratos(this.roomItem);
               if(this.roomItem.subItems != null)
               {
                  for each(var _loc2_:RoomItem in this.roomItem.subItems)
                  {
                     this.sushiPratos(_loc2_);
                  }
               }
            }
            return;
         }
         if(this.agua)
         {
            this.aguaTick(param1);
            return;
         }
         if(!this.cheshire)
         {
            return;
         }
         this.cheshireTimer -= param1;
         if(this.cheshireTimer > 0)
         {
            return;
         }
         if(!this.cheshireSumido)
         {
            if(this.cheshireTocar("disappear"))
            {
               this.cheshireSumido = true;
               this.cheshireTimer = Engine.rnd(5000,12001);
            }
            else
            {
               this.cheshireTimer = 60000;
            }
         }
         else
         {
            this.cheshireTocar("appear");
            this.cheshireSumido = false;
            this.cheshireTimer = Engine.rnd(8000,20001);
         }
      }

      // poe a comida em cada prato que ainda nao tem (a esteira pode recriar os pratos ao recomecar a volta)
      private function sushiPratos(param1:RoomItem) : void
      {
         var _loc2_:MovieClip = param1.getChildMovieClipInstance("mc_content");
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = null;
         var _loc6_:Rectangle = null;
         var _loc7_:Rectangle = null;
         var _loc8_:Number = NaN;
         var _loc9_:flash.display.DisplayObject = null;
         var _loc10_:int = 0;
         if(_loc2_ == null)
         {
            return;
         }
         while(_loc3_ < SUSHI_COMIDAS.length)
         {
            _loc4_ = _loc2_.getChildByName("mc_plate" + _loc3_) as MovieClip;
            if(_loc4_ != null)
            {
               _loc10_ = this.sushiNivel(SUSHI_RECEITAS[_loc3_]);
               _loc5_ = _loc4_.getChildByName("rcrComida") as MovieClip;
               if(_loc10_ <= 0)
               {
                  // receita fora do cardapio (ou que o dono nao tem): prato vazio
                  if(_loc5_ != null)
                  {
                     _loc4_.removeChild(_loc5_);
                  }
               }
               else
               {
                  if(_loc5_ == null)
                  {
                     _loc5_ = Engine.getMovieClip(SUSHI_COMIDAS[_loc3_]);
                     if(_loc5_ != null)
                     {
                        _loc5_.gotoAndStop(1);
                        _loc5_.name = "rcrComida";
                        _loc5_.mouseEnabled = false;
                        _loc5_.mouseChildren = false;
                        _loc4_.addChild(_loc5_);
                     }
                  }
                  _loc9_ = _loc5_ != null ? _loc5_.getChildByName("mc_plate") as MovieClip : null;
                  if(_loc5_ != null && (_loc9_ == null || MovieClip(_loc9_).currentFrame != _loc10_ || _loc5_.scaleX == 1))
                  {
                     if(_loc9_ != null)
                     {
                        MovieClip(_loc9_).gotoAndStop(Math.min(_loc10_,MovieClip(_loc9_).totalFrames));
                     }
                     // prato branco da esteira (a primeira peca do mc_plateN, sem contar a comida)
                     _loc6_ = _loc4_.getChildAt(0).getBounds(_loc4_);
                     _loc7_ = _loc9_ != null ? _loc9_.getBounds(_loc5_) : _loc5_.getBounds(_loc5_);
                     _loc8_ = _loc6_.width / Math.max(1,_loc7_.width);
                     _loc5_.scaleX = _loc5_.scaleY = _loc8_;
                     _loc5_.x = _loc6_.x + _loc6_.width / 2 - (_loc7_.x + _loc7_.width / 2) * _loc8_;
                     _loc5_.y = _loc6_.y + _loc6_.height / 2 - (_loc7_.y + _loc7_.height / 2) * _loc8_;
                  }
               }
            }
            _loc3_++;
         }
      }

      // nivel da receita no cardapio do dono do restaurante (0 = nao tem ou nao esta selecionada)
      private function sushiNivel(param1:int) : int
      {
         var _loc2_:* = undefined;
         if(this.sushiMundo == null || this.sushiMundo.gameUser == null)
         {
            return 0;
         }
         _loc2_ = this.sushiMundo.gameUser.getOwnedRecipe(param1);
         if(_loc2_ == null || !_loc2_.selected)
         {
            return 0;
         }
         return Math.max(1,int(_loc2_.level));
      }

      private function aguaTem(param1:int, param2:int) : Boolean
      {
         var _loc3_:Array = null;
         var _loc4_:* = undefined;
         if(param1 < 0 || param2 < 0 || this.aguaMundo.isTileOutOfBound(param1,param2))
         {
            return false;
         }
         _loc3_ = this.aguaMundo.itemMap[WorldRestaurant.getTileIndex(param1,param2)];
         if(_loc3_ == null)
         {
            return false;
         }
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_ is RoomItem && RoomItem(_loc4_).itemConfig.functions && String(RoomItem(_loc4_).itemConfig.functions).indexOf("MagicWaterTile") >= 0)
            {
               return true;
            }
         }
         return false;
      }

      private function aguaBordas() : void
      {
         var _loc1_:int = this.roomItem.tileX;
         var _loc2_:int = this.roomItem.tileY;
         var _loc3_:Boolean = this.aguaTem(_loc1_,_loc2_ - 1);
         var _loc4_:Boolean = this.aguaTem(_loc1_ + 1,_loc2_);
         var _loc5_:Boolean = this.aguaTem(_loc1_,_loc2_ + 1);
         var _loc6_:Boolean = this.aguaTem(_loc1_ - 1,_loc2_);
         this.roomItem.rcrQuadro(1 + (_loc3_ ? 1 : 0) + (_loc4_ ? 2 : 0) + (_loc5_ ? 4 : 0) + (_loc6_ ? 8 : 0));
         this.aguaCanto("corner1",_loc6_ && _loc3_ && this.aguaTem(_loc1_ - 1,_loc2_ - 1));
         this.aguaCanto("corner2",_loc3_ && _loc4_ && this.aguaTem(_loc1_ + 1,_loc2_ - 1));
         this.aguaCanto("corner3",_loc4_ && _loc5_ && this.aguaTem(_loc1_ + 1,_loc2_ + 1));
         this.aguaCanto("corner4",_loc5_ && _loc6_ && this.aguaTem(_loc1_ - 1,_loc2_ + 1));
      }

      private function aguaCanto(param1:String, param2:Boolean) : void
      {
         var _loc3_:MovieClip = this.roomItem.getChildMovieClipInstance(param1);
         if(_loc3_ != null)
         {
            _loc3_.visible = !param2;
         }
      }

      private function aguaTick(param1:uint) : void
      {
         if(this.aguaPeixe != null && this.aguaPeixe.removed)
         {
            this.aguaPeixe = null;
         }
         if(this.aguaPeixe != null)
         {
            return;
         }
         this.aguaTimer -= param1;
         if(this.aguaTimer > 0)
         {
            return;
         }
         this.aguaTimer = Engine.rnd(6000,20001);
         // o clip do peixe toca sozinho (51-139 quadros a 25 fps = 2-5,6 s) e o objeto some em 6 s
         this.aguaPeixe = new EffectObject("MagicWaterTileEffect0" + Engine.rnd(1,4),WorldRestaurant.getScreenX(this.roomItem.tileX,this.roomItem.tileY),WorldRestaurant.getScreenY(this.roomItem.tileX,this.roomItem.tileY),0,0,6000);
         this.aguaPeixe.drawPriority = WorldRestaurant.getTileDrawPriority(this.roomItem.tileX,this.roomItem.tileY) + 1;
         this.aguaMundo.room.addObject(this.aguaPeixe);
      }

      // toca o trecho no mc_content do item e das fatias dele, se o rotulo existir
      private function cheshireTocar(param1:String) : Boolean
      {
         var _loc2_:Boolean = cheshireTocarEm(this.roomItem,param1);
         var _loc3_:int = 0;
         if(this.roomItem.subItems != null)
         {
            while(_loc3_ < this.roomItem.subItems.length)
            {
               cheshireTocarEm(this.roomItem.subItems[_loc3_],param1);
               _loc3_++;
            }
         }
         return _loc2_;
      }

      private static function cheshireTocarEm(param1:RoomItem, param2:String) : Boolean
      {
         var _loc3_:MovieClip = param1.getChildMovieClipInstance("mc_content");
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         if(_loc3_ == null)
         {
            return false;
         }
         _loc4_ = _loc3_.currentLabels;
         while(_loc5_ < _loc4_.length)
         {
            if(_loc4_[_loc5_].name == param2)
            {
               _loc3_.gotoAndPlay(param2);
               return true;
            }
            _loc5_++;
         }
         return false;
      }
   }
}

