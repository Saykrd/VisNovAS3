package states
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import managers.StateManager;
	
	import objects.DataObject;
	
	public class State extends DataObject
	{
		
		public static const TYPE_ACTIVE:String  = "active";
		public static const TYPE_PASSIVE:String = "passive";
		
		
		
		protected var _paused:Boolean;
		protected var _type:String = TYPE_ACTIVE;
		
		protected var _objectData:Dictionary;
		
		public function State()
		{
			
		}
		
		public function pause():void{
			
		}
		
		public function resume():void{
			
		}
		
		public function getRenderData():Dictionary{
			var renderData:Dictionary = new Dictionary;
			var id:String;
			
			for(id in _objectData){
				renderData[id] = _objectData[id].renderData;
			}
			
			return renderData;
		}
		
		
		public function get isPaused():Boolean{
			return _paused;
		}
		
		
		protected function addEventListeners():void{
			
		}
	}
}