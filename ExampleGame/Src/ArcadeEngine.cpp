/*=============================================================================
	ArcadeEngine.cpp
	HanJiping. hanwukong@126.com
=============================================================================*/
#include "ExampleGame.h"
#include "TCP_Client.h"

IMPLEMENT_CLASS(UArcadeGameEngine);

/*------------------------------------------------------------------------------
     UArcadeGameEngine.
------------------------------------------------------------------------------*/
void UArcadeGameEngine::Init()
{
	__super::Init();

	if( ! GTCPClient.Connect() )
	{
		appMsgf(AMT_OK, TEXT("连接控制客户端失败！"));
	}
}

void UArcadeGameEngine::PreExit()
{
	__super::PreExit();
}

void UArcadeGameEngine::Tick( FLOAT DeltaSeconds )
{
	__super::Tick(DeltaSeconds);

	GTCPClient.Tick();

}

void UArcadeGameEngine::PushRotationToCtrl(FLOAT Rot)
{
	GTCPClient.SetRotateAngle(Rot);
}

void UArcadeGameEngine::GameCloseToCtrl()
{
	GTCPClient.GameOver();
}
