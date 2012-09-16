package states
{
	import managers.StateManager;

	public class GameState extends State
	{
		protected var _stateManager:StateManager;
		
		public function GameState(stateManager:StateManager)
		{
			_stateManager = stateManager;
		}
		
		override protected function setEvents():void{
			
		}
		
		protected function pauseGame():void{
			
		}
	}
}