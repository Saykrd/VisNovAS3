package load
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.events.LoaderEvent;

	public class LoadObject
	{
		
		public static const TYPE_DISPLAY:String = "display";
		
		
		private var _onProgress:Function;
		private var _onComplete:Function;
		private var _onError:Function;
		
		private var _assetProgress:int;
		private var _batchProgress:int;
		
		private var _itemsToLoad:int;
		private var _itemsLoaded:int;
		
		public function get batchProgress():int
		{
			return _batchProgress;
		}
		
		public function get assetProgress():int
		{
			return _assetProgress;
		}
		
		public function LoadObject(onComplete:Function = null, onProgress:Function = null, onError:Function = null)
		{
			_onProgress = onProgress;
			_onComplete = onComplete;
			_onError	= onError;
		}
		
		public function progress(e:ProgressEvent):void{
			
			_assetProgress = e.bytesLoaded / e.bytesTotal * 100;
			_batchProgress = _itemsLoaded / _itemsToLoad + _assetProgress / _itemsToLoad;
			if(_onProgress)_onProgress(this);
		}
		
		public function error(e:IOErrorEvent):void{
			trace("error", e);
			if(_onError)_onError(e);
		}
		
		public function complete(e:Event):void{
			trace("complete");
			if(_onComplete)_onComplete(this);
		}
		
		public function assetLoaded():void{
			_itemsToLoad++;
			_assetProgress = 0;
		}
		
		public function setNumItems(num:int):void{
			_itemsToLoad = num;
		}
		
	}
}