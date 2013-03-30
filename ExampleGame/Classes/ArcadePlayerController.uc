//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class ArcadePlayerController extends GamePlayerController
	config(Game);

/** Cockpit */
var() Cockpit Cockpit;

/** Plane */
var() PlayerPlane PlayerPlane;

/** Push Rotation Time */
var() float PushRotationTime;

/** X Speed */
var() float XSpeed;

/** Y Speed */
var() float YSpeed;

/** X Interp Speed */
var() float XInterpSpeed;

/** Y Interp Speed */
var() float YInterpSpeed;

/** Aim Radius */
var() float AimRadius;

/** Arcade Player Input */
var ArcadePlayerInput API;

/** Left Aim */
var transient Vector2D LeftAim;

/** Right Aim */
var transient Vector2D RightAim;

/** Left Aimed */
var transient Actor LeftAimed;
var transient Vector LeftAimedLocation;

/** Right Aimed */
var transient Actor RightAimed;
var transient Vector RightAimedLocation;

var transient bool bCtrlPause;

var transient bool bPlaying;

/** Init input */
event InitInputSystem()
{
    super.InitInputSystem();

    API = ArcadePlayerInput(PlayerInput);
    ResetAim();
}

function ResetAim()
{
    local Vector2D ViewportSize;

    LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);
    LeftAim.X = ViewportSize.X * 0.3;
	LeftAim.Y = ViewportSize.Y * 0.5;
	RightAim.X = ViewportSize.X * 0.7;
	RightAim.Y = ViewportSize.Y * 0.5;
}

simulated event PostBeginPlay()
{
    local Vector2D ViewportSize;

    LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);

	super.PostBeginPlay();

	RegisterCockpit();
}

//Set up the reference to the Cockpit and initialize the Cockpit
function RegisterCockpit()
{
	foreach  WorldInfo.DynamicActors(class'Cockpit', Cockpit)
	{
		Cockpit.Controller = self;
		break;
	}

	foreach  WorldInfo.DynamicActors(class'Playerplane', PlayerPlane)
	{
	    PlayerPlane.Controller = self;
		break;
	}
}

function SetOutput(bool bEnable)
{
    if(bEnable)
    {
        PushRotation();
        SetTimer(PushRotationTime, true, 'PushRotation');
    }
    else
    {
        ClearTimer('PushRotation');
    }
}

// Push Rotation
function PushRotation()
{
    local float RotDeg;

    if(Cockpit != None)
    {
        RotDeg = Cockpit.Rotation.Roll * UnrRotToDeg;
        class'ArcadeGameEngine'.static.PushRotationToCtrl(RotDeg);
        //ClientMessage(WorldInfo.TimeSeconds @ "Cockpit Roll:" @ RotDeg);
    }
}

function int GetCockpitRot()
{
    if(Cockpit != None)
    {
        return Cockpit.Rotation.Roll;
    }

    return 0;
}

exec function GameClose()
{
    RestartLevel();
    bPlaying = false;
    class'ArcadeGameEngine'.static.GameCloseToCtrl();
}

exec function CockpitShake(int Level)
{
    ClientMessage(WorldInfo.TimeSeconds @ "Cockpit Shake:" @ Level);
}

// 控制器信号处理
function ProcCtrlMsg(CtrlMsg Msg)
{
    switch(Msg)
    {
        case CM_Play:
            CtrlPlay();
            break;
        case CM_Pause:
            CtrlPause();
            break;
        case CM_UnPause:
            CtrlUnPause();
            break;
        case CM_Stop:
            CtrlStop();
            break;
        case CM_ShutDown:
            CtrlShutDown();
            break;
        default:
            break;
    }
}

exec function CtrlPlay()
{
     ServerRemoteEvent('Play');
     bPlaying = true;
     ResetAim();
}

exec function CtrlPause()
{
    SetPause(true);
    bPlaying = false;
}

exec function CtrlUnPause()
{
    SetPause(false);
    bPlaying = true;
}

exec function CtrlStop()
{
    RestartLevel();
    bPlaying = false;
}

exec function CtrlShutDown()
{
    ConsoleCommand( "EXIT" );
}

event PlayerTick( float DeltaTime )
{
    Super.PlayerTick(DeltaTime);

    if(bPlaying)
    {
        UpdateAim(DeltaTime);

        LeftAimedLocation = Pick(LeftAim);
        RightAimedLocation = Pick(RightAim);
    }
}

function UpdateAim(float DeltaTime)
{
    local Vector2D ViewportSize;

    LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);

    LeftAim.X = FInterpTo(LeftAim.X, LeftAim.X + API.aLeftX * XSpeed, DeltaTime, XInterpSpeed);
    LeftAim.X = FClamp(LeftAim.X, 0, ViewportSize.X);

    LeftAim.Y = FInterpTo(LeftAim.Y, LeftAim.Y - API.aLeftY * YSpeed, DeltaTime, YInterpSpeed);
    LeftAim.Y = FClamp(LeftAim.Y, 0, ViewportSize.Y);

    RightAim.X = FInterpTo(RightAim.X, RightAim.X + API.aRightX * XSpeed, DeltaTime, XInterpSpeed);
    RightAim.X = FClamp(RightAim.X, 0, ViewportSize.X);

    RightAim.Y = FInterpTo(RightAim.Y, RightAim.Y - API.aRightY * YSpeed, DeltaTime, YInterpSpeed);
    RightAim.Y = FClamp(RightAim.Y, 0, ViewportSize.Y);
}

function Vector Pick(Vector2D PickLocation)
{
    local Vector PickOrigin, PickDir;
    local Vector HitLocation, HitNormal, TraceExtent;
    local Vector2D ViewportSize;

    LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);
    TraceExtent.X = AimRadius;
    TraceExtent.Y = AimRadius;
    TraceExtent.Z = AimRadius;

    //Transform absolute screen coordinates to relative coordinates
    PickLocation.X = PickLocation.X / ViewportSize.X;
    PickLocation.Y = PickLocation.Y / ViewportSize.Y;

    //Transform to world coordinates to get pick ray
    LocalPlayer(Player).Deproject(PickLocation, PickOrigin, PickDir);

    if(WorldInfo.Trace(HitLocation, HitNormal, PickOrigin + (PickDir * 100000), PickOrigin, true, TraceExtent) == None)
    {
        HitLocation = PickOrigin + (PickDir * 100000);
    }

    //DrawDebugSphere(HitLocation, 32, 16, 255, 255,0);
    return HitLocation;
}

exec function LFire()
{
    if(PlayerPlane != none && bPlaying)
    {
        PlayerPlane.Fire(LeftAimed, LeftAimedLocation, true);
    }
}

exec function RFire()
{
    if(PlayerPlane != none && bPlaying)
    {
        PlayerPlane.Fire(RightAimed, RightAimedLocation, false);
    }
}

defaultproperties
{
	InputClass=class'ExampleGame.ArcadePlayerInput'
	PushRotationTime=0.2

	XSpeed=8;
	YSpeed=8;

	XInterpSpeed=10;
	YInterpSpeed=10;

	AimRadius=40
}
