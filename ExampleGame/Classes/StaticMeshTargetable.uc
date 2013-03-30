//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class StaticMeshTargetable extends InterpActor
    implements(ITargetable);

/** DestroyedMesh */
var() const StaticMesh DestroyedMesh;

/** Particle system to use */
var() const ParticleSystem ParticleFX;

/** Scale for particle fx */
var() const vector ParticleScale;

/** Rotation offset used with particle system */
var() const rotator ParticleOffsetRot;

/** Location offset used with particle system */
var() const vector ParticleOffsetLoc;

/** TimeDilation for particle fx */
var() const float ParticleTimeDilation;

/** SoundCue to play */
var() const SoundCue SoundFX;

/** SoundCue volume multiplier */
var() const float VolumeMultiplier;

/** SoundCue pitch multiplier */
var() const float PitchMultiplier;

/** Location offset used with particle system */
var() const vector AimPointOffsetLoc;

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
    return Location + (AimPointOffsetLoc >> Rotation);
}

/** Play Desrtroy */
function PlayDestroy()
{
    local vector OffsetLocation;
    local ParticleSystemComponent PSC;
    local AudioComponent AC;

    //Particle
    if(ParticleFX != None)
    {
        OffsetLocation = ParticleOffsetLoc >> Rotation;
        PSC = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleFX, Location + OffsetLocation, Rotation + ParticleOffsetRot);

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
    if(DestroyedMesh != None)
    {
        StaticMeshComponent.SetStaticMesh(DestroyedMesh);
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
}
