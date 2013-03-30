//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class SkeletalMeshTargetable extends SkeletalMeshActor
    implements(ITargetable);

/** DestroyedMesh */
var() const name DestroyAnimName;

/** Particle system to use */
var() const ParticleSystem ParticleFX;

/** Scale for particle fx */
var() const vector ParticleScale;

/** Particle Socket */
var() const name ParticleSocket;

/** TimeDilation for particle fx */
var() const float ParticleTimeDilation;

/** SoundCue to play */
var() const SoundCue SoundFX;

/** SoundCue volume multiplier */
var() const float VolumeMultiplier;

/** SoundCue pitch multiplier */
var() const float PitchMultiplier;

/** Aim Socket */
var() const name AimSocket;

/** Health */
var() int Health;

/** Destroyed */
var transient bool bDestroyed;

/** DrawHUD */
var transient bool bDrawHUD;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    SetCollisionType(COLLIDE_BlockAll);
}

/** Should Draw HUD */
function bool ShouldDrawHUD()
{
    if(bDestroyed)
    {
        return false;
    }
    else
    {
        return bDrawHUD;
    }
}

/** Get Projectile Aim Point */
function vector GetProjectileAimPoint()
{
    local vector AimLocation;
    local rotator AimRotation;

    if(SkeletalMeshComponent.GetSocketWorldLocationAndRotation(AimSocket, AimLocation, AimRotation))
    {
        return AimLocation;
    }

    return Location;
}

/** Play Desrtroy */
function PlayDestroy()
{
    local vector FXLocation;
    local rotator FXRotation;
    local ParticleSystemComponent PSC;
    local AudioComponent AC;

    //Particle
    if(ParticleFX != None && SkeletalMeshComponent.GetSocketWorldLocationAndRotation(ParticleSocket, FXLocation, FXRotation))
    {
        PSC = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleFX, FXLocation, FXRotation);

        PSC.SetScale3D(ParticleScale);
        PSC.CustomTimeDilation = ParticleTimeDilation;
    }

    //Sound
    if(SoundFX != None)
    {
        AC = CreateAudioComponent(SoundFX, false, false);
        if (AC != None)
		{
			AC.VolumeMultiplier = VolumeMultiplier;
			AC.PitchMultiplier = PitchMultiplier;
			AC.bAutoDestroy = true;
			AC.Play();
		}
    }

    //Mesh
    if(DestroyAnimName != 'None')
    {
        SkeletalMeshComponent.PlayAnim(DestroyAnimName);
        LifeSpan = SkeletalMeshComponent.GetAnimLength(DestroyAnimName);
        SetCollisionType(COLLIDE_NoCollision);
    }

    bDestroyed = true;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    if(Health < 0)
    {
        return;
    }
    Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
    Health = Health - DamageAmount;
    if(Health < 0)
    {
        PlayDestroy();
    }
}

/**	Handling Toggle event from Kismet. */
simulated function OnToggle(SeqAct_Toggle Action)
{
	// Turn ON
	if (Action.InputLinks[0].bHasImpulse)
	{
	    bDrawHUD = true;
	}
	// Turn OFF
	else if (Action.InputLinks[1].bHasImpulse)
	{
	    bDrawHUD = false;
	}
	// Toggle
	else if (Action.InputLinks[2].bHasImpulse)
	{
	    bDrawHUD = !bDrawHUD;
	}
}

DefaultProperties
{
    ParticleScale=(X=1.0,Y=1.0,Z=1.0)
    ParticleTimeDilation=1.0
    VolumeMultiplier=1.0
    PitchMultiplier=1.0

    Physics=PHYS_Interpolating
}
