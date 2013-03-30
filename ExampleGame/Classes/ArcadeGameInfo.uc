//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class ArcadeGameInfo extends FrameworkGame;

auto State PendingMatch
{
Begin:
	StartMatch();
}

defaultproperties
{
	HUDType=class'ExampleGame.ArcadeHUD'
	PlayerControllerClass=class'ExampleGame.ArcadePlayerController'
	bDelayedStart=false
}


