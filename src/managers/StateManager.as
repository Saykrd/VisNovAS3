package managers
{
	import flash.utils.Dictionary;
	
	import states.State;

	public class StateManager
	{
		
		private var _states:Vector.<State>;
		
		public function StateManager()
		{
		}
		
		public function addState(state:State):void{
			_states.push(state);
		}
		
		public function pauseState(id:String):void{
			var state:State = getState(id);
			state.pause();
		}
		
		public function resumeState(id:String):void{
			var state:State = getState(id);
			state.resume();
		}
		
		public function endState(id:String):void{
			for(var i:int = _states.length - 1; i >= 0 && _states.length > 0; i--){
				if(_states[i].id == id){
					_states[i].destroy();
					_states.splice(i,1);
					break;
				}
			}
		}
		
		public function updateStates():void{
			var state:State
			
			for each(state in states){
				state.update();
			}
		}
		
		public function getState(id:String):void{
			for (var i:int = 0; i < _states.length; i++) 
			{
				if(_states[i].id == id){
					return _states[i];
				}
			}
			
		}
			
		
	}
}