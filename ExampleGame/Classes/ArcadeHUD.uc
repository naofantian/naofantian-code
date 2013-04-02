//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class ArcadeHUD extends MobileHUD;

var config bool bDebugRot;
var config float AimDrawSize;

struct TargetAimInfo
{
    var() Actor Target;
    var() Box DrawBox;
};

var transient array<TargetAimInfo> TargetAimInfos;

var Material LeftAimMat;
var Material RightAimMat;

/**
 * The start of the rendering chain.
 */
function PostRender()
{
    local ArcadePlayerController APC;

	super.PostRender();

    APC = ArcadePlayerController(PlayerOwner);
    if(APC != none && APC.bPlaying)
    {
	    RenderTarget();
	    RenderAim();
	}

	if(bDebugRot && APC != none)
	{
        RenderDebugRot(APC.GetCockpitRot());
	}
}

function RenderDebugRot(int Roll)
{
    local rotator CRot;
    local vector Dir;

    Dir.Y = -1;
    CRot.Yaw = Roll;
    Dir = Dir >> CRot;

    Canvas.Draw2DLine(Canvas.SizeX*0.5, Canvas.SizeY*0.5, Canvas.SizeX*0.5 + (Dir.X * Canvas.SizeY*0.5), Canvas.SizeY*0.5 + (Dir.Y * Canvas.SizeY*0.5), MakeColor(0,255,0,255));
}

/** Render Target */
function RenderTarget()
{
    local Actor Target;
    local Box DrawBox, LeftAimBox, RightAimBox;
    local float LeftAimWeight, RightAimWeight, NewLeftAimWeight, NewRightAimWeight;
    local ArcadePlayerController APC;
    local TargetAimInfo NewInfo;
    local int Idx;

	APC = ArcadePlayerController(PlayerOwner);
	LeftAimBox.Min.X = APC.LeftAim.X - APC.AimRadius;
	LeftAimBox.Min.Y = APC.LeftAim.Y - APC.AimRadius;
	LeftAimBox.Max.X = APC.LeftAim.X + APC.AimRadius;
	LeftAimBox.Max.Y = APC.LeftAim.Y + APC.AimRadius;
	RightAimBox.Min.X = APC.RightAim.X - APC.AimRadius;
	RightAimBox.Min.Y = APC.RightAim.Y - APC.AimRadius;
	RightAimBox.Max.X = APC.RightAim.X + APC.AimRadius;
	RightAimBox.Max.Y = APC.RightAim.Y + APC.AimRadius;
	APC.LeftAimed = None;
	APC.RightAimed = None;
	TargetAimInfos.Length = 0;

    ForEach DynamicActors(class'Actor', Target, class'ITargetable')
    {
        if(ITargetable(Target).ShouldDrawHUD())
        {
            if(Target.LastRenderTime > WorldInfo.TimeSeconds - 0.1)
            {
                DrawBox = GetTwoDeeActorBoundingBox(Target);
                NewInfo.Target = Target;
                NewInfo.DrawBox = DrawBox;
                TargetAimInfos.AddItem(NewInfo);

                NewLeftAimWeight = AimTest(DrawBox, LeftAimBox);
                if(NewLeftAimWeight > 0 && NewLeftAimWeight > LeftAimWeight)
                {
                    APC.LeftAimed = Target;
                    LeftAimWeight = NewLeftAimWeight;
                }

                NewRightAimWeight = AimTest(DrawBox, RightAimBox);
                if(NewRightAimWeight > 0 && NewRightAimWeight > RightAimWeight)
                {
                    APC.RightAimed = Target;
                    RightAimWeight = NewRightAimWeight;
                }
            }
        }
    }

    for(Idx = 0; Idx < TargetAimInfos.Length; Idx++)
    {
        if(TargetAimInfos[Idx].Target == APC.LeftAimed || TargetAimInfos[Idx].Target == APC.RightAimed)
        {
             RenderTwoDeeActorBrackets(TargetAimInfos[Idx].DrawBox, MakeColor(255,0,0,255));
        }
        else
        {
             RenderTwoDeeActorBrackets(TargetAimInfos[Idx].DrawBox, MakeColor(0,255,0,255));
        }
    }
}

/** Render Aim */
function RenderAim()
{
    local ArcadePlayerController APC;

	APC = ArcadePlayerController(PlayerOwner);
	Canvas.SetPos(APC.LeftAim.X-AimDrawSize, APC.LeftAim.Y-AimDrawSize);
	Canvas.DrawMaterialTile(LeftAimMat, AimDrawSize*2.0,AimDrawSize*2.0,0,0,1,1);
	Canvas.SetPos(APC.RightAim.X-AimDrawSize, APC.RightAim.Y-AimDrawSize);
	Canvas.DrawMaterialTile(RightAimMat, AimDrawSize*2.0,AimDrawSize*2.0,0,0,1,1);
}

/** Aim Test */
function float AimTest(Box A, Box B)
{
    local Vector2d Min, Max;
    local float ASizeX, ASizeY, BSizeX, BSizeY;

    ASizeX = A.Max.X - A.Min.X;
    ASizeY = A.Max.Y - A.Min.Y;

    BSizeX = B.Max.X - B.Min.X;
    BSizeY = B.Max.Y - B.Min.Y;

    Min.X = A.Min.X < B.Min.X ? A.Min.X : B.Min.X;
    Min.Y = A.Min.Y < B.Min.Y ? A.Min.Y : B.Min.Y;

    Max.X = A.Max.X > B.Max.X ? A.Max.X : B.Max.X;
    Max.Y = A.Max.Y > B.Max.Y ? A.Max.Y : B.Max.Y;

    if(Max.X - Min.X < ASizeX + BSizeX && Max.Y - Min.Y < ASizeY + BSizeY)
    {
        return (ASizeX+BSizeX-(Max.X-Min.X))*(ASizeY+BSizeY-(Max.Y-Min.Y));
    }

    return 0;
}

/** Render Point */
function RenderBrackets(Vector2D Point, float Size, color C)
{
	local Box DrawBox;

	DrawBox.Min.X = Point.X - Size;
	DrawBox.Min.Y = Point.Y - Size;
	DrawBox.Max.X = Point.X + Size;
	DrawBox.Max.Y = Point.Y + Size;

	RenderTwoDeeActorBrackets(DrawBox, C);
}

function RenderTwoDeeActorBrackets(Box DrawBox, color C)
{
	local int ActualWidth, ActualHeight;

	// Calculate the width and height
	ActualWidth = (DrawBox.Max.X - DrawBox.Min.X) * 0.3f;
	ActualHeight = (DrawBox.Max.Y - DrawBox.Min.Y) * 0.3f;

	// Draw the actor brackets
	Canvas.SetDrawColorStruct(C);

	// Top left
	Canvas.SetPos(DrawBox.Min.X, DrawBox.Min.Y);
	Canvas.DrawRect(ActualWidth, 2);
	Canvas.SetPos(DrawBox.Min.X, DrawBox.Min.Y);
	Canvas.DrawRect(2, ActualHeight);

	// Top right
	Canvas.SetPos(DrawBox.Max.X - ActualWidth - 2, DrawBox.Min.Y);
	Canvas.DrawRect(ActualWidth, 2);
	Canvas.SetPos(DrawBox.Max.X - 2, DrawBox.Min.Y);
	Canvas.DrawRect(2, ActualHeight);

	// Bottom left
	Canvas.SetPos(DrawBox.Min.X, DrawBox.Max.Y - 2);
	Canvas.DrawRect(ActualWidth, 2);
	Canvas.SetPos(DrawBox.Min.X, DrawBox.Max.Y - ActualHeight - 2);
	Canvas.DrawRect(2, Actualheight);

	// Bottom right
	Canvas.SetPos(DrawBox.Max.X - ActualWidth - 2, DrawBox.Max.Y - 2);
	Canvas.DrawRect(ActualWidth + 2, 2);
	Canvas.SetPos(DrawBox.Max.X - 2, DrawBox.Max.Y - ActualHeight - 2);
	Canvas.DrawRect(2, ActualHeight + 2);
}


function Box GetTwoDeeActorBoundingBox(Actor Actor)
{
	local Box ComponentsBoundingBox, OutBox;
	local Vector BoundingBoxCoordinates[8];
	local int i;

	Actor.GetComponentsBoundingBox(ComponentsBoundingBox);

	// Z1
	// X1, Y1
	BoundingBoxCoordinates[0].X = ComponentsBoundingBox.Min.X;
	BoundingBoxCoordinates[0].Y = ComponentsBoundingBox.Min.Y;
	BoundingBoxCoordinates[0].Z = ComponentsBoundingBox.Min.Z;
	BoundingBoxCoordinates[0] = Canvas.Project(BoundingBoxCoordinates[0]);
	// X2, Y1
	BoundingBoxCoordinates[1].X = ComponentsBoundingBox.Max.X;
	BoundingBoxCoordinates[1].Y = ComponentsBoundingBox.Min.Y;
	BoundingBoxCoordinates[1].Z = ComponentsBoundingBox.Min.Z;
	BoundingBoxCoordinates[1] = Canvas.Project(BoundingBoxCoordinates[1]);
	// X1, Y2
	BoundingBoxCoordinates[2].X = ComponentsBoundingBox.Min.X;
	BoundingBoxCoordinates[2].Y = ComponentsBoundingBox.Max.Y;
	BoundingBoxCoordinates[2].Z = ComponentsBoundingBox.Min.Z;
	BoundingBoxCoordinates[2] = Canvas.Project(BoundingBoxCoordinates[2]);
	// X2, Y2
	BoundingBoxCoordinates[3].X = ComponentsBoundingBox.Max.X;
	BoundingBoxCoordinates[3].Y = ComponentsBoundingBox.Max.Y;
	BoundingBoxCoordinates[3].Z = ComponentsBoundingBox.Min.Z;
	BoundingBoxCoordinates[3] = Canvas.Project(BoundingBoxCoordinates[3]);

	// Z2
	// X1, Y1
	BoundingBoxCoordinates[4].X = ComponentsBoundingBox.Min.X;
	BoundingBoxCoordinates[4].Y = ComponentsBoundingBox.Min.Y;
	BoundingBoxCoordinates[4].Z = ComponentsBoundingBox.Max.Z;
	BoundingBoxCoordinates[4] = Canvas.Project(BoundingBoxCoordinates[4]);
	// X2, Y1
	BoundingBoxCoordinates[5].X = ComponentsBoundingBox.Max.X;
	BoundingBoxCoordinates[5].Y = ComponentsBoundingBox.Min.Y;
	BoundingBoxCoordinates[5].Z = ComponentsBoundingBox.Max.Z;
	BoundingBoxCoordinates[5] = Canvas.Project(BoundingBoxCoordinates[5]);
	// X1, Y2
	BoundingBoxCoordinates[6].X = ComponentsBoundingBox.Min.X;
	BoundingBoxCoordinates[6].Y = ComponentsBoundingBox.Max.Y;
	BoundingBoxCoordinates[6].Z = ComponentsBoundingBox.Max.Z;
	BoundingBoxCoordinates[6] = Canvas.Project(BoundingBoxCoordinates[6]);
	// X2, Y2
	BoundingBoxCoordinates[7].X = ComponentsBoundingBox.Max.X;
	BoundingBoxCoordinates[7].Y = ComponentsBoundingBox.Max.Y;
	BoundingBoxCoordinates[7].Z = ComponentsBoundingBox.Max.Z;
	BoundingBoxCoordinates[7] = Canvas.Project(BoundingBoxCoordinates[7]);

	// Find the left, top, right and bottom coordinates
	OutBox.Min.X = Canvas.ClipX;
	OutBox.Min.Y = Canvas.ClipY;
	OutBox.Max.X = 0;
	OutBox.Max.Y = 0;

	// Iterate though the bounding box coordinates
	for (i = 0; i < ArrayCount(BoundingBoxCoordinates); ++i)
	{
		// Detect the smallest X coordinate
		if (OutBox.Min.X > BoundingBoxCoordinates[i].X)
		{
			OutBox.Min.X = BoundingBoxCoordinates[i].X;
		}

		// Detect the smallest Y coordinate
		if (OutBox.Min.Y > BoundingBoxCoordinates[i].Y)
		{
			OutBox.Min.Y = BoundingBoxCoordinates[i].Y;
		}

		// Detect the largest X coordinate
		if (OutBox.Max.X < BoundingBoxCoordinates[i].X)
		{
			OutBox.Max.X = BoundingBoxCoordinates[i].X;
		}

		// Detect the largest Y coordinate
		if (OutBox.Max.Y < BoundingBoxCoordinates[i].Y)
		{
			OutBox.Max.Y = BoundingBoxCoordinates[i].Y;
		}
	}

	return OutBox;
}

defaultproperties
{
    LeftAimMat=Material'PlaneHUD.Mat_Aim'
    RightAimMat=Material'PlaneHUD.Mat_Aim1'
}

