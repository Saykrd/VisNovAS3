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
		public static const TYPE_NON_DISPLAY:String = "nondisplay";
		
		
		
		private var _totalBytes:int;
		private var _bytesLoaded:int;
		private var _percentage:int = 0;
		
		
		private var _onProgress:Function;
		private var _onComplete:Function;
		private var _onError:Function;
		
		private var _prevLoadStep:int = 0;
		
		public function LoadObject(onProgress:Function = null, onComplete:Function = null, onError:Function = null)
		{
			_onProgress = onProgress;
			_onComplete = onComplete;
			_onError	= onError;
		}
		
		public function progress(e:ProgressEvent):void{
			_bytesLoaded  += e.bytesLoaded - _prevLoadStep;
			_prevLoadStep  = e.bytesLoaded;
			_percentage	   = _bytesLoaded / _totalBytes * 100;
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
		
		public function appendTotalBytes(url:String, dataType:String, callback:Function):void{
			var loader:Loader;
			var urlLoader:URLLoader;
			var req:URLRequest = new URLRequest(url);
			
			if(dataType == TYPE_DISPLAY){
				loader = new Loader();
				loader.addEventListener(ProgressEvent.PROGRESS, getTotalBytes, false, 0, true);
				loader.load(req);
			} else if (dataType == TYPE_NON_DISPLAY){
				urlLoader = new URLLoader;
				urlLoader.addEventListener(ProgressEvent.PROGRESS, getTotalBytes, false, 0, true);
				urlLoader.load(req);
			}
			
			function getTotalBytes(e:ProgressEvent):void{
				_totalBytes += e.bytesTotal;
				e.target.removeEventListener(ProgressEvent.PROGRESS, getTotalBytes);
				if(callback)callback();
			}
		}
	}
}