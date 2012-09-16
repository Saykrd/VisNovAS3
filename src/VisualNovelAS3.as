package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import load.DataLoad;
	import load.LoadObject;
	
	public class VisualNovelAS3 extends Sprite
	{
		
		private static const ASSETS_URL:String = "resources/xml/assets.xml";
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
			DataLoad.startup(ASSETS_URL, startLoad);
		}
		
		public function startLoad():void{
			trace("I have all the asset data, I can begin loading now");
			
			
			var loadObj:LoadObject = new LoadObject(null, onComplete);
			DataLoad.loadAsset(INITIAL_LOAD_ID, loadObj);
			
			function onComplete(obj:LoadObject):void{
				var initialLoadXML:XML = DataLoad.getXML(INITIAL_LOAD_ID);
				DataLoad.loadAssetsFromXML(initialLoadXML, new LoadObject(null, startGame));
			}
		}
		
		public function startGame(load:LoadObject):void{
			trace("game is ready to start!");
			var square:MovieClip = MovieClip(new (DataLoad.getClass("test", "square")));
			addChild(square);
		}
	}
}