//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class PlaneCamera extends CameraActor;

var() const editconst SkeletalMeshComponent SkeletalMeshComponent;

/**
 * Returns camera's Point of View.
 * Called by Camera.uc class. Subclass and postprocess to add any effects.
 */
simulated function GetCameraView(float DeltaTime, out TPOV OutPOV)
{
	super.GetCameraView(DeltaTime, OutPOV);

	OutPOV.Rotation.Roll = 0;
}

DefaultProperties
{
    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		HiddenGame=TRUE
		CollideActors=FALSE
		BlockRigidBody=FALSE
		CastShadow=FALSE
		AlwaysLoadOnClient=FALSE
		AlwaysLoadOnServer=FALSE
	End Object
	SkeletalMeshComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)
}
