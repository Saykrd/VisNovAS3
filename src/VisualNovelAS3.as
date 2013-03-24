package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	
	
	public class VisualNovelAS3 extends Sprite
	{
		
		private static const ASSETS_URL:String      = "resources/xml/assets.xml";
		private static const INITIAL_LOAD_ID:String = "initialLoad";
		
		public function VisualNovelAS3()
		{
			if(!stage){
				this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			} else {
				init();
			}
			
			function onAdded(e:Event):void{
				init();
				this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			}
		}
		
		public function init():void{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			
			DataLoad.startup(ASSETS_URL, startLoad);
		}
		
		public function startLoad():void{
			trace("I have all the asset data, I can begin loading now");
			
			
			DataLoad.loadAsset(INITIAL_LOAD_ID, onComplete);
			
			function onComplete(obj:LoadObject):void{
				var initialLoadXML:XML = DataLoad.getXML(INITIAL_LOAD_ID);
				DataLoad.loadAssetsFromXML(initialLoadXML, startGame);
			}
		}
		
		public function startGame(load:LoadObject):void{
			trace("game is ready to start!");
//			var square:MovieClip = MovieClip(new (DataLoad.getClass("test", "square")));
//			addChild(square);
			var img:DisplayObject = DataLoad.getImage("image1");
			addChild(img);
		}
	}
}