//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class ArcadeProjectile extends Projectile;

/** Acceleration magnitude. By default, acceleration is in the same direction as velocity. */
var(Projectile) float AccelRate;

/** if true, the shutdown function has been called and 'new' effects shouldn't happen */
var bool bShuttingDown;

/** Effects */
/** This is the effect that is played while in flight */
var ParticleSystemComponent	ProjEffects;

/** Effects Template */
/** Effect template for the projectile while it is in flight. */
var(Projectile) ParticleSystem ProjFlightTemplate;
var(Projectile) float ProjFlightTemplateScale;
/** Effect template when the projectile explodes.  Projectile only explodes if Damage Radius is non-zero. */
var(Projectile) ParticleSystem ProjExplosionTemplate;
var(Projectile) float ProjExplosionTemplateScale;

/** This value sets the cap how far away the explosion effect of this projectile can be seen */
var(Projectile) float MaxEffectDistance;

/**  The sound that is played when it explodes.  Projectile only explodes if Damage Radius is non-zero. */
var(Projectile) SoundCue	ExplosionSound;

/** Actor types to ignore if the projectile hits them */
var(Projectile) array<class<Actor> >	ActorsToIgnoreWhenHit;

/** used to prevent effects when projectiles are destroyed (see LimitationVolume) */
var bool bSuppressExplosionFX;

var transient Actor HomingTarget;

var transient vector HomingLocation;

var(Projectile) float SpiralForceMag;
var(Projectile) float InwardForceMag;
var(Projectile) float ForwardForceMag;
var(Projectile) float DesiredDistanceToAxis;
var(Projectile) float DesiredDistanceDecayRate;
var(Projectile) float InwardForceMagGrowthRate;

var float CurSpiralForceMag;
var float CurInwardForceMag;
var float CurForwardForceMag;

var float DT;
var(Projectile) float IgniteTime;

var vector AxisOrigin;
var vector AxisDir;
var(Projectile) float KillRange;

/**
 * Explode when the projectile comes to rest on the floor.  It's called from the native physics processing functions.  By default,
 * when we hit the floor, we just explode.
 */
simulated event Landed( vector HitNormal, actor FloorActor )
{
	HitWall(HitNormal, FloorActor, None);
}

/**
 * When this actor begins its life, play any ambient sounds attached to it
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( bDeleteMe || bShuttingDown)
		return;
}

/**
 * Initialize the Projectile
 */
function InitProj(vector Direction, Actor InTarget, Vector InLocation)
{
    local float Dist;

	SetRotation(rotator(Direction));

	Velocity = Speed * Normal(Direction);
	Acceleration = AccelRate * Normal(Velocity);

	HomingTarget = InTarget;
	HomingLocation = InLocation;

	Dist = VSize(HomingLocation - Location);
	if ( Dist < KillRange )
	{
		IgniteTime = IgniteTime - IgniteTime * ((KillRange - Dist)/KillRange);
	}

	SetTimer(IgniteTime, false, 'IgniteToTarget');

	// Spawn any effects needed for flight
	SpawnFlightEffects();
}

function IgniteToTarget()
{
    if(HomingTarget != None)
    {
        HomingLocation = ITargetable(HomingTarget).GetProjectileAimPoint();
    }

    if(VSize(HomingLocation - Location) <= KillRange)
	{
		GotoState('Homing');
	}
	else
	{
		GotoState('Spiraling');
	}
}

/**
 *
 */
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{

	if( ActorsToIgnoreWhenHit.Find(Other.Class) != INDEX_NONE )
	{
		// The hit actor is one that should be ignored
		return;
	}


	if (DamageRadius > 0.0)
	{
		Explode(HitLocation, HitNormal);
	}
	else
	{
		PlaySound(ImpactSound);
		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		Shutdown();
	}
}

/**
 * Explode this Projectile
 */
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (Damage>0 && DamageRadius>0)
	{
		if ( Role == ROLE_Authority )
			MakeNoise(1.0);
		if ( !bShuttingDown )
		{
			ProjectileHurtRadius(HitLocation, HitNormal);
		}
		SpawnExplosionEffects(HitLocation, HitNormal);
	}
	else
	{
		PlaySound(ImpactSound);
	}

	ShutDown();
}


/**
 * Spawns any effects needed for the flight of this projectile
 */
simulated function SpawnFlightEffects()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && ProjFlightTemplate != None)
	{
		ProjEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate, true);
		ProjEffects.SetAbsolute(false, false, false);
		ProjEffects.SetScale(ProjFlightTemplateScale);
		ProjEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		ProjEffects.OnSystemFinished = MyOnParticleSystemFinished;
		ProjEffects.bUpdateComponentInTick = true;
		ProjEffects.SetTickGroup(TG_EffectsUpdateWork);
		AttachComponent(ProjEffects);
		ProjEffects.ActivateSystem(true);
	}

	if (SpawnSound != None)
	{
		PlaySound(SpawnSound);
	}
}

/** sets any additional particle parameters on the explosion effect required by subclasses */
simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion);

/**
 * Spawn Explosion Effects
 */
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ParticleSystemComponent ProjExplosion;
	local Actor EffectAttachActor;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (EffectIsRelevant(Location, false, MaxEffectDistance))
		{
			if (ProjExplosionTemplate != None)
			{
				EffectAttachActor = ImpactedActor;
				ProjExplosion = WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(HitNormal), EffectAttachActor);
				ProjExplosion.SetScale(ProjExplosionTemplateScale);
				SetExplosionEffectParameters(ProjExplosion);
			}

			if (ExplosionSound != None)
			{
				PlaySound(ExplosionSound, true);
			}
		}

		bSuppressExplosionFX = true; // so we don't get called again
	}
}

/**
 * Clean up
 */
simulated function Shutdown()
{
	local vector HitLocation, HitNormal;

	bShuttingDown=true;
	HitNormal = normal(Velocity * -1);
	Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));

	SetPhysics(PHYS_None);

	if (ProjEffects!=None)
	{
		ProjEffects.DeactivateSystem();
	}

	HideProjectile();
	SetCollision(false,false);

	Destroy();
}

// If this actor

event TornOff()
{
	ShutDown();
	Super.TornOff();
}

/**
 * Hide any meshes/etc.
 */
simulated function HideProjectile()
{
	local MeshComponent ComponentIt;
	foreach ComponentList(class'MeshComponent',ComponentIt)
	{
		ComponentIt.SetHidden(true);
	}
}

simulated function Destroyed()
{
	if (ProjEffects != None)
	{
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects = None;
	}

	super.Destroyed();
}

simulated function MyOnParticleSystemFinished(ParticleSystemComponent PSC)
{
	if (PSC == ProjEffects)
	{
		// clear component and return to pool
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects = None;
	}
}

state Spiraling
{
	simulated function BeginState(name PreviousStateName)
	{
		CurSpiralForceMag = SpiralForceMag;
		CurInwardForceMag = InwardForceMag;
		CurForwardForceMag = ForwardForceMag;

		AxisOrigin = Location;
		SetTimer(DT, true);
	}

	// @TODO FIXMESTEVE move to C++, and do every tick (with less accel change)
	simulated function Timer()
	{
		local vector ParallelComponent, PerpendicularComponent, NormalizedPerpendicularComponent;
		local vector SpiralForce, InwardForce, ForwardForce;
		local float InwardForceScale;

		if(HomingTarget != None)
        {
            HomingLocation = ITargetable(HomingTarget).GetProjectileAimPoint();
        }
        AxisDir = Normal(HomingLocation - Location);

		// Add code to switch directions

		// Update the inward force magnitude.
		CurInwardForceMag += InwardForceMagGrowthRate * DT;

		ParallelComponent = ((Location - AxisOrigin) dot AxisDir) * AxisDir;
		PerpendicularComponent = (Location - AxisOrigin) - ParallelComponent;
		NormalizedPerpendicularComponent = Normal(PerpendicularComponent);

		InwardForceScale = VSize(PerpendicularComponent) - DesiredDistanceToAxis;

		SpiralForce = CurSpiralForceMag * Normal(AxisDir cross NormalizedPerpendicularComponent);
		InwardForce = -CurInwardForceMag * InwardForceScale * NormalizedPerpendicularComponent;
		ForwardForce = CurForwardForceMag * AxisDir;

		Acceleration = SpiralForce + InwardForce + ForwardForce;

		DesiredDistanceToAxis -= DesiredDistanceDecayRate * DT;
		DesiredDistanceToAxis = FMax(DesiredDistanceToAxis, 0.0);

		if(VSize(HomingLocation - Location) <= KillRange)
		{
			GotoState('Homing');
		}

		if(Normal(HomingLocation - Location) dot Normal(Velocity) > 0.9)
		{
			GotoState('Homing');
		}
	}
}


state Homing
{
	simulated function Timer()
	{
	    if(HomingTarget != None)
        {
            HomingLocation = ITargetable(HomingTarget).GetProjectileAimPoint();
        }
		// do normal guidance to target.
		Acceleration = 16.0 * AccelRate * Normal(HomingLocation - Location);

		if ( ((Acceleration dot Velocity) < 0.f))
		{
			Explode(Location, vect(0,0,1));
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		Timer();
		SetTimer(DT, true);
	}
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	out_CamLoc = Location + (CylinderComponent.CollisionHeight * Vect(0,0,1));
	return true;
}

/** called when this Projectile is the ViewTarget of a local player
 * @return the Pawn to use for rendering HUD displays
 */
simulated function Pawn GetPawnOwner();


defaultproperties
{
	Speed=2000
	MaxSpeed=5000
	AccelRate=15000

	Damage=100
	DamageRadius=2000
	MomentumTransfer=500
	LifeSpan=5.0

	bCollideWorld=true
	DrawScale=2.0

	bShuttingDown=false

	MaxEffectDistance=100000

	SpiralForceMag=800.000000
    InwardForceMag=25.000000
    ForwardForceMag=15000.000000
    DesiredDistanceToAxis=250.000000
    DesiredDistanceDecayRate=500.000000
    DT=0.100000

    KillRange=2000.000000

    ProjFlightTemplateScale=1.0
    ProjExplosionTemplateScale=1.0
    IgniteTime=0.2

    bRotationFollowsVelocity=true;
}


