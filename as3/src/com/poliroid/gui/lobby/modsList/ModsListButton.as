﻿package com.poliroid.gui.lobby.modsList 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.utils.Constraints;
	
	import net.wg.infrastructure.managers.impl.ContainerManagerBase;
	import net.wg.gui.components.containers.MainViewContainer;
	import net.wg.infrastructure.interfaces.ISimpleManagedContainer;
	import net.wg.infrastructure.interfaces.IManagedContent;
	
	import net.wg.data.Aliases;
	import net.wg.gui.lobby.messengerBar.MessengerBar;
	import net.wg.infrastructure.interfaces.IView;
	import net.wg.infrastructure.events.LoaderEvent;
	import net.wg.gui.lobby.LobbyPage;
	import net.wg.gui.login.impl.LoginPage;
	
	import com.poliroid.gui.lobby.modsList.controls.ModsListBlinkingButton;
	import com.poliroid.gui.lobby.modsList.data.ModsListStaticDataVO;
	import com.poliroid.gui.lobby.modsList.interfaces.IModsListButtonMeta;
	import com.poliroid.gui.lobby.modsList.interfaces.impl.ModsListButtonMeta;
	
	public class ModsListButton extends ModsListButtonMeta implements IModsListButtonMeta 
	{
		
		private static const BOTTOM_MARGIN:int = 36;
		
		private static const RIGHT_MARGIN:Number = 86;
		
		private static const POPOVER_ALIAS:String = 'ModsListApiPopover';
		
		private static const INVALIDATE_ALIASES:Array = [Aliases.LOGIN, Aliases.LOBBY, Aliases.LOBBY_HANGAR, Aliases.LOBBY_TRAINING_ROOM];

		private static const INVALIDATE_BUTTON:String = 'invalidateButton';

		public var modsButton:ModsListBlinkingButton = null;
		
		private var messangerBar:MessengerBar = null;
		
		private var isInLobby:Boolean = false;
		
		public function ModsListButton() 
		{
			super();
		}
		
		override protected function configUI() : void 
		{
			super.configUI();
			
			// subscribe to stage resize
			App.instance.stage.addEventListener(Event.RESIZE, onResize);
			
			// process already loaded views
			var containerMgr:ContainerManagerBase = App.containerMgr as ContainerManagerBase;
			for each (var container:ISimpleManagedContainer in containerMgr.containersMap)
			{
				var viewContainer:MainViewContainer = container as MainViewContainer;
				if (viewContainer != null)
				{
					var num:int = viewContainer.numChildren;
					for (var idx:int = 0; idx < num; ++idx)
					{
						var view:IView = viewContainer.getChildAt(idx) as IView;
						if (view != null)
							processView(view);
					}
					var topmostView:IManagedContent = viewContainer.getTopmostView();
					if (topmostView != null)
					{
						viewContainer.setFocusedView(topmostView);
					}
				}
			}
			
			// subscribe to container manager loader
			(App.containerMgr as ContainerManagerBase).loader.addEventListener(LoaderEvent.VIEW_LOADED, onViewLoaded, false, 0, true);
			
			modsButton.addEventListener(ButtonEvent.CLICK, handleModsButtonClick);
		}
		
		override protected function onDispose() : void 
		{
			if (modsButton) {
				modsButton.removeEventListener(ButtonEvent.CLICK, handleModsButtonClick);
				modsButton.dispose();	
			}
			
			modsButton = null;
			messangerBar = null;
			
			(App.containerMgr as ContainerManagerBase).loader.removeEventListener(LoaderEvent.VIEW_LOADED, onViewLoaded);
			
			App.instance.stage.removeEventListener(Event.RESIZE, onResize);
			
			super.onDispose();
		}
		
		override protected function draw() : void
		{
			super.draw();
			
			if(isInvalid(INVALIDATE_BUTTON))
			{
				if (isInLobby) 
				{
					if (messangerBar)
					{
						var mostLeftButton:DisplayObject = DisplayObject(modsButton);
						
						if (messangerBar.vehicleCompareCartBtn.visible)
						{
							mostLeftButton = DisplayObject(messangerBar.vehicleCompareCartBtn);
						}
						
						messangerBar.channelCarousel.width = mostLeftButton.x - messangerBar.channelCarousel.x - 1;
					}
				}
				else 
				{
					moveButton(App.appWidth - RIGHT_MARGIN, App.appHeight - BOTTOM_MARGIN);
				}
			}
		}
		
		// this needs for valid Focus and Position in Login Window 
		override protected function nextFrameAfterPopulateHandler() : void 
		{
			if (parent != App.instance) {
				(App.instance as MovieClip).addChild(this);
			}
		}
		
		private function onResize(e:Event) : void
		{
			invalidate(INVALIDATE_BUTTON);
			validateNow();
		}
		
		private function onViewLoaded(event:LoaderEvent) : void
		{
			var view:IView = event.view as IView;
			processView(view);
		}
		
		private function processView(view:IView) : void
		{
			var alias:String = view.as_config.alias;
			
			if (alias == Aliases.LOGIN) 
			{
				messangerBar = null;
				isInLobby = false;
				
				(view as LoginPage).addChild(DisplayObject(modsButton));
			}
			
			if (alias == Aliases.LOBBY) 
			{
				
				// in case whan hangar loaded faster then nextFrameAfterPopulateHandler fire
				if (parent != App.instance)
					(App.instance as MovieClip).addChild(this);
				
				isInLobby = true;
				messangerBar = ((view as LobbyPage).messengerBar as MessengerBar);
				
				moveButton(messangerBar.vehicleCompareCartBtn.x, 9);
				
				// move "vehicle compare button" and "vehicle name anim" left
				messangerBar.vehicleCompareCartBtn.x -= 77;
				messangerBar.animPlacer.x -= 77;
				
				// append modsButton to messangerBar.constraints (all bottom buttons position manager)
				messangerBar.addChild(DisplayObject(modsButton));
				messangerBar.constraints.addElement("modsButton", DisplayObject(modsButton), Constraints.RIGHT);
				
			}

			if (INVALIDATE_ALIASES.indexOf(alias) >= 0) 
			{
				invalidate(INVALIDATE_BUTTON);
			}
		}
		
		private function moveButton(posX:Number, posY:Number) : void
		{
			modsButton.x = posX;
			modsButton.y = posY;
		}
		
		private function handleModsButtonClick(event:ButtonEvent) : void 
		{
			onButtonClickS(isInLobby);
			modsButton.blinking = false;
			App.toolTipMgr.hide();
			App.popoverMgr.show(modsButton, POPOVER_ALIAS);
		}
		
		override protected function setStaticData(data:ModsListStaticDataVO) : void 
		{
			modsButton.tooltip = data.descriptionLabel;
		}
		
		override protected function buttonBlinking() : void 
		{
			modsButton.blinking = true;
		}
		
		override protected function compareBasketVisibility() : void 
		{
			invalidate(INVALIDATE_BUTTON);
		}
	}
}
