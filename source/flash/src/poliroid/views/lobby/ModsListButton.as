package poliroid.views.lobby 
{
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import net.wg.infrastructure.base.AbstractView;
	import net.wg.infrastructure.interfaces.IPopOverCaller;
	
	import poliroid.components.lobby.ModsListButtonFrame;
	
	public class ModsListButton extends AbstractView implements IPopOverCaller 
	{
		
		private var modsButton:ModsListButtonFrame = null;
		private var tooltipText:String = 'Список модификаций: удобный запуск, настройка и оповещение.';
		private var isLobby:Boolean = false;
		private var messangerBar:* = null;
		
		public var onButtonClickS:Function = null;
		public var logS:Function = null;
		public var debugLogS:Function = null;
		
		public function ModsListButton() 
		{
			super();
			this.focusable = false;
		}
		
		private function buildButton() : void 
		{
			this.modsButton = new ModsListButtonFrame();
			this.modsButton.width = 72;
			this.modsButton.height = 33;
			this.modsButton.addEventListener(MouseEvent.CLICK, this.handleModsButtonClick);
			this.modsButton.helpText = this.tooltipText;
		}
		
		override protected function onPopulate() : void 
		{
			super.onPopulate();
			App.instance.loaderMgr.loadLibraries(Vector.<String>(["toolTips.swf", "popovers.swf"]));
		}
		
		override protected function nextFrameAfterPopulateHandler() : void 
		{
			if (this.parent != App.instance) {
				(App.instance as MovieClip).addChild(this);
			}
		}
		
		public function getTargetButton() : DisplayObject 
		{
			if (this.modsButton != null) {
				return DisplayObject(this.modsButton);
			}
			return DisplayObject(this);
		}
		
		public function getHitArea() : DisplayObject 
		{
			if (this.modsButton != null) {
				return DisplayObject(this.modsButton);
			}
			return DisplayObject(this);
		}
		
		public function as_setTooltipText(tooltipText:String) : void 
		{
			try {
				
				this.tooltipText = tooltipText;
				if (this.modsButton != null) {
					this.modsButton.helpText = this.tooltipText;
				}
			} catch(err: Error) {
				this.debugLogS("modsListButton::as_setTooltipText:ERROR \n" + err.getStackTrace());
			}
		}
		
		public function as_populateLogin() : void 
		{
			try {
				this.messangerBar = null;
				this.isLobby = false;
				var LoginPageUI:DisplayObjectContainer = this.recursiveFindDOC(DisplayObjectContainer(stage), "LoginPageUI");
				if (LoginPageUI != null) {
					this.buildButton();
					this.modsButton.x = App.appWidth - 80;
					this.modsButton.y = App.appHeight - 34;
					LoginPageUI.addChild(this.modsButton);
				}
			} catch(err: Error) {
				this.debugLogS("modsListButton::as_populateLogin:ERROR \n" + err.getStackTrace());
			}
		}
		
		public function as_populateLobby() : void 
		{
			try {
				this.isLobby = true;
				this.buildButton();
				var MessengerBarUI:DisplayObjectContainer = this.recursiveFindDOC(DisplayObjectContainer(stage), "MessengerBar_UI");
				if (MessengerBarUI != null) {
					this.messangerBar = MessengerBarUI;
					
					this.modsButton.x = App.appWidth - 165;
					this.modsButton.y = this.messangerBar.notificationListBtn.y;
					this.messangerBar.addChild(this.modsButton);
					
					this.messangerBar.channelCarousel.width = App.appWidth - 316;
					this.messangerBar.addEventListener(Event.RESIZE, this.handleMessengerBarResize);
					
					this.resizeMessengerBar();
					
					setTimeout(this.resizeMessengerBar, 50);
					setTimeout(this.resizeMessengerBar, 500);
					setTimeout(this.resizeMessengerBar, 1000);
					setTimeout(this.resizeMessengerBar, 2000);
					setTimeout(this.resizeMessengerBar, 5000);
					setTimeout(this.resizeMessengerBar, 10000);
				}
			} catch(err: Error) {
				this.debugLogS("modsListButton::as_populateLobby:ERROR \n" + err.getStackTrace());
			}
		}
		
		public function as_handleChangeScreenResolution(width:Number, height:Number) : void 
		{
			if (!this.isLobby && this.modsButton != null) {
				this.modsButton.x = App.appWidth - 80;
				this.modsButton.y = App.appHeight - 34;
			}
		}
		
		public function as_handleButtonBlinking() : void 
		{
			if (this.modsButton != null) {
				this.modsButton.blinking = true;
			}
		}
		
		private function handleModsButtonClick(event: MouseEvent) : void 
		{
			this.onButtonClickS();
			App.toolTipMgr.hide();
			this.modsButton.blinking = false;
			App.popoverMgr.show(this, "modsListPopover");
		}
		
		private function handleMessengerBarResize(event: Event) : void 
		{
			try {
				if (this.isLobby && this.messangerBar != null) {
					this.modsButton.x = App.appWidth - 165;
					this.messangerBar.channelCarousel.width = App.appWidth - 316;
				}
			} catch(err: Error) {
				this.debugLogS("modsListButton::handleMessengerBarResize:ERROR \n" + err.getStackTrace());
			}
		}
		
		private function resizeMessengerBar() : void 
		{
		
			if (this.isLobby && this.messangerBar != null) {
				
				var new_size:Number = App.appWidth - 316;
				
				if (this.messangerBar.channelCarousel.width != new_size) {
					setTimeout(this.resizeMessengerBar, 50);
				}
				this.messangerBar.channelCarousel.width = new_size;
			}
		
		}
		
		private function recursiveFindDOC(dOC:DisplayObjectContainer, className:String) : DisplayObjectContainer 
		{
			var child:DisplayObject = null;
			var childOC:DisplayObjectContainer = null;
			var i:int = 0;
			var result:DisplayObjectContainer = null;
			while (i < dOC.numChildren) {
				child = dOC.getChildAt(i);
				if ((child is DisplayObject) && (getQualifiedClassName(child) == className)) result = child as DisplayObjectContainer;
				if (result != null) return result;
				childOC = child as DisplayObjectContainer;
				if ((childOC) && (childOC.numChildren > 0)) result = this.recursiveFindDOC(childOC, className);
				i++;
			}
			return result;
		}
		
	}
}