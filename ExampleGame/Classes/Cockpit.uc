//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class Cockpit extends InterpActor;

/** Enable Rotation Output */
var() bool bEnable;

/** Controller */
var transient ArcadePlayerController Controller;

/**	Handling Toggle event from Kismet. */
simulated function OnToggle(SeqAct_Toggle Action)
{
	// Turn ON
	if (Action.InputLinks[0].bHasImpulse)
	{
	    bEnable = true;
	}
	// Turn OFF
	else if (Action.InputLinks[1].bHasImpulse)
	{
	    bEnable = false;
	}
	// Toggle
	else if (Action.InputLinks[2].bHasImpulse)
	{
	    bEnable = !bEnable;
	}

    Controller.SetOutput(bEnable);
}

DefaultProperties
{

}
