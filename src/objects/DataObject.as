package objects
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import structs.RenderData;
	
	public class DataObject extends EventDispatcher
	{
		
		protected var _eventRegistry:Dictionary = new Dictionary;
		
		public var renderData:RenderData;
		public var id:String;
		
		public function DataObject()
		{
		}
		
		protected function setEvents():void{
			
		}
		
		protected function addEvent(command:String, func:Function):void{
			_eventRegistry[command] = func;
		}
		
		public function callEvent(event:String):void{
			if(_eventRegistry[event]){
				_eventRegistry[event]();
			}
		}
		public function init():void{
			
		}
		
		public function update():void{
			
		}
		
		public function destroy():void{
			_eventRegistry = null;
			renderData = null;
		}
		
		
	}
}