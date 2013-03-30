/*===========================================================================
    C++ class definitions exported from UnrealScript.
    This is automatically generated by the tools.
    DO NOT modify this manually! Edit the corresponding .uc files instead!
    Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
===========================================================================*/
#if SUPPORTS_PRAGMA_PACK
#pragma pack (push,4)
#endif

#include "ExampleGameNames.h"

// Split enums from the rest of the header so they can be included earlier
// than the rest of the header file by including this file twice with different
// #define wrappers. See Engine.h and look at EngineClasses.h for an example.
#if !NO_ENUMS && !defined(NAMES_ONLY)

#ifndef INCLUDED_EXAMPLEGAME_ENUMS
#define INCLUDED_EXAMPLEGAME_ENUMS 1

enum CtrlMsg
{
    CM_Play                 =0,
    CM_Pause                =1,
    CM_UnPause              =2,
    CM_Stop                 =3,
    CM_ShutDown             =4,
    CM_MAX                  =5,
};
#define FOREACH_ENUM_CTRLMSG(op) \
    op(CM_Play) \
    op(CM_Pause) \
    op(CM_UnPause) \
    op(CM_Stop) \
    op(CM_ShutDown) 

#endif // !INCLUDED_EXAMPLEGAME_ENUMS
#endif // !NO_ENUMS

#if !ENUMS_ONLY

#ifndef NAMES_ONLY
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif


#ifndef NAMES_ONLY

#ifndef INCLUDED_EXAMPLEGAME_CLASSES
#define INCLUDED_EXAMPLEGAME_CLASSES 1
#define ENABLE_DECLARECLASS_MACRO 1
#include "UnObjBas.h"
#undef ENABLE_DECLARECLASS_MACRO

struct ArcadeGameEngine_eventProcCtrlMsg_Parms
{
    BYTE msg;
    ArcadeGameEngine_eventProcCtrlMsg_Parms(EEventParm)
    {
    }
};
struct ArcadeGameEngine_eventProcFireMsg_Parms
{
    INT PlayerIdx;
    ArcadeGameEngine_eventProcFireMsg_Parms(EEventParm)
    {
    }
};
class UArcadeGameEngine : public UGameEngine
{
public:
    //## BEGIN PROPS ArcadeGameEngine
    //## END PROPS ArcadeGameEngine

    void PushRotationToCtrl(FLOAT Rot);
    void GameCloseToCtrl();
    DECLARE_FUNCTION(execPushRotationToCtrl)
    {
        P_GET_FLOAT(Rot);
        P_FINISH;
        this->PushRotationToCtrl(Rot);
    }
    DECLARE_FUNCTION(execGameCloseToCtrl)
    {
        P_FINISH;
        this->GameCloseToCtrl();
    }
    void eventProcCtrlMsg(BYTE msg)
    {
        ArcadeGameEngine_eventProcCtrlMsg_Parms Parms(EC_EventParm);
        Parms.msg=msg;
        ProcessEvent(FindFunctionChecked(EXAMPLEGAME_ProcCtrlMsg),&Parms);
    }
    void eventProcFireMsg(INT PlayerIdx)
    {
        ArcadeGameEngine_eventProcFireMsg_Parms Parms(EC_EventParm);
        Parms.PlayerIdx=PlayerIdx;
        ProcessEvent(FindFunctionChecked(EXAMPLEGAME_ProcFireMsg),&Parms);
    }
    DECLARE_CLASS(UArcadeGameEngine,UGameEngine,0|CLASS_Transient|CLASS_Config,ExampleGame)
    virtual void Init();
    virtual void PreExit();
    virtual void Tick( FLOAT DeltaSeconds );
};

#undef DECLARE_CLASS
#undef DECLARE_CASTED_CLASS
#undef DECLARE_ABSTRACT_CLASS
#undef DECLARE_ABSTRACT_CASTED_CLASS
#endif // !INCLUDED_EXAMPLEGAME_CLASSES
#endif // !NAMES_ONLY

AUTOGENERATE_FUNCTION(UArcadeGameEngine,-1,execGameCloseToCtrl);
AUTOGENERATE_FUNCTION(UArcadeGameEngine,-1,execPushRotationToCtrl);

#ifndef NAMES_ONLY
#undef AUTOGENERATE_FUNCTION
#endif

#ifdef STATIC_LINKING_MOJO
#ifndef EXAMPLEGAME_NATIVE_DEFS
#define EXAMPLEGAME_NATIVE_DEFS

#define AUTO_INITIALIZE_REGISTRANTS_EXAMPLEGAME \
	UArcadeGameEngine::StaticClass(); \
	GNativeLookupFuncs.Set(FName("ArcadeGameEngine"), GExampleGameUArcadeGameEngineNatives); \

#endif // EXAMPLEGAME_NATIVE_DEFS

#ifdef NATIVES_ONLY
FNativeFunctionLookup GExampleGameUArcadeGameEngineNatives[] = 
{ 
	MAP_NATIVE(UArcadeGameEngine, execGameCloseToCtrl)
	MAP_NATIVE(UArcadeGameEngine, execPushRotationToCtrl)
	{NULL, NULL}
};

#endif // NATIVES_ONLY
#endif // STATIC_LINKING_MOJO

#ifdef VERIFY_CLASS_SIZES
VERIFY_CLASS_SIZE_NODIE(UArcadeGameEngine)
#endif // VERIFY_CLASS_SIZES
#endif // !ENUMS_ONLY

#if SUPPORTS_PRAGMA_PACK
#pragma pack (pop)
#endif