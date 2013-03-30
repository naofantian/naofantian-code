//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class PlayerPlane extends SkeletalMeshActor;

/** Left Rocket Socket */
var() name LeftRocketSocket;

/** Right Rocket Socket */
var() name RightRocketSocket;

/** ProjectileTemplate */
var() ArcadeProjectile ProjectileTemplate;

/** Controller */
var transient ArcadePlayerController Controller;

function Fire(Actor Target, vector TargetLocation, bool bLeft)
{
    local Vector FireLocation;
    local rotator FireRotation;
    local ArcadeProjectile NewProj;

    if(ProjectileTemplate == None)
    {
        Controller.ClientMessage("No ProjectileTemplate to fire!!!");
        return;
    }

    if(bLeft)
    {
        SkeletalMeshComponent.GetSocketWorldLocationAndRotation(LeftRocketSocket, FireLocation, FireRotation);
    }
    else
    {
        SkeletalMeshComponent.GetSocketWorldLocationAndRotation(RightRocketSocket, FireLocation, FireRotation);
    }

    if(Target != None)
    {
        NewProj = Spawn(class'ArcadeProjectile',,,FireLocation, FireRotation, ProjectileTemplate);
        if(NewProj != None)
        {
            `Log(Target.Location @ ITargetable(Target).GetProjectileAimPoint());
            NewProj.InitProj(vector(FireRotation), Target, ITargetable(Target).GetProjectileAimPoint());
        }
    }
    else
    {
        NewProj = Spawn(class'ArcadeProjectile',,,FireLocation, FireRotation, ProjectileTemplate);
        if(NewProj != None)
        {
            NewProj.InitProj(vector(FireRotation), None, TargetLocation);
        }
    }
}

DefaultProperties
{
    Physics=PHYS_Interpolating
}
