// TCP_Client.cpp 


#include "TCP_Client.h"
#include "Client.h"
#include< winsock.h >
#include <Windows.h>
//#pragma comment( lib, "ws2_32.lib" )
//#pragma comment( lib, "Network.lib" )
//#define BACKLOG 10
//char* IP="127.0.0.1";
//#define PORT 2046

FTCPClient::FTCPClient( void )
{
	bAngleDirty = FALSE;
	curAngle = 0;
	curGameState = ES_Connecting;
	angleUpdateTime = 0; 
}

//连接服务器
UBOOL FTCPClient::Connect( void )
{
	FString serverIP;
	GConfig->GetString( TEXT("Game.Server"), TEXT("ip"), serverIP, GGameIni );
	INT serverPort;
	GConfig->GetInt( TEXT("Game.Server"), TEXT("port"), serverPort, GGameIni );

	if ( Client_Connect( TCHAR_TO_ANSI(*serverIP), serverPort ))
	{
		curGameState = ES_connected;
		return TRUE;
	}
	return FALSE;
}



//设置旋转角度(0~360)
void FTCPClient::SetRotateAngle( INT angle )
{
	if ( angle != curAngle )
	{
		curAngle = angle;
		bAngleDirty = TRUE;
	}

}
//设置振动等级
void FTCPClient::SetCollideLevel( ECollideLevel level )
{
	ZeroMemory( buf, MAXDATASIZE );
	sprintf_s( buf, MAXDATASIZE, "XH_SHAKE#%d", level );
    Client_Send( buf );

}
//游戏结束
void FTCPClient::GameOver( void )
{
	if ( curGameState == ES_playing )
	{
		changeGameTravel( );
	}

	ZeroMemory( buf, MAXDATASIZE );
	strcpy_s( buf, MAXDATASIZE, "XH_CLOSE#00");
	Client_Send( buf ); 
	
}

//切换游戏场景
void FTCPClient::changeGameTravel( void )
{
	if ( curGameState == ES_connected )
	{
		FString gameMap;
		GConfig->GetString( TEXT("Game.Map"), TEXT("Name"), gameMap, GGameIni );
		GEngine->SetClientTravel( *gameMap, TRAVEL_Partial );
		//GEngine->SetClientTravel( TEXT("lefantian.umap"), TRAVEL_Partial );
		curGameState = ES_playing;
	}
	else if ( curGameState == ES_playing )
	{
		GEngine->SetClientTravel( *FURL::DefaultLocalMap, TRAVEL_Partial );
		//GEngine->SetClientTravel( TEXT("ExampleEntry.umap"), TRAVEL_Partial );
		curGameState = ES_connected;
	}
}
//播放游戏
void FTCPClient::PlayGame( void )
{
	if ( curGameState == ES_connected )
	{
		changeGameTravel();
	}
}
//游戏退出
void FTCPClient::ExitGame( void )
{
	curGameState = ES_Connecting;
	Client_Close();
	appRequestExit(FALSE);
}

//显示错误信息
void FTCPClient::logError( char *pError )
{
	GLog->Logf( ANSI_TO_TCHAR( pError ) );
}

void FTCPClient::Tick( void )
{

	if ( Client_GetMessage( buf ) )
	{
		if ( curGameState== ES_playing )  //游戏过程中
		{
			if( strcmp(buf, "XH_STOP#00") == 0 ) //紧急停止
			{
				changeGameTravel();
			}
			else
			{
				logError( buf );
			}

		}
		else if( curGameState==ES_connected )//和服务器连接好,并且不是在游戏的过程中
		{
			if( strcmp(buf, "XH_PLAY#00") == 0 ) //开始游戏
			{
				PlayGame();
			}
			else if ( strcmp(buf, "XH_SHUTDOWN#00") == 0 ) //关机
			{
				ExitGame();
			}
			else
			{
				logError( buf );
			}
		}
		else
		{
			logError( buf );
		}

	}

	if ( bAngleDirty ) //发送旋转角度数据
	{
		DWORD nowTime = GetTickCount();
		INT deltTime = nowTime - angleUpdateTime;
		if ( deltTime >= 200 || deltTime < 0 )
		{
			ZeroMemory( buf, MAXDATASIZE );
			sprintf_s( buf, MAXDATASIZE, "XH_ROTATION#%d", curAngle );
			Client_Send( buf ); 
			bAngleDirty = FALSE;
			angleUpdateTime = nowTime;
		}
	}


	//测试用
	DWORD nowTime = GetTickCount();
	static DWORD testbeginTime = nowTime;
	static DWORD endgameTime = nowTime;
	if ( curGameState== ES_playing )  //游戏过程中
	{
		int testdelt = nowTime - testbeginTime;
		if ( testdelt > 10000 )
		{
			srand( (unsigned)time( NULL ) );
			INT angle =  rand() % 720 - 360;
			SetRotateAngle( angle );
			int level = rand() % 3 + 1;
			debugf( TEXT("rotate angle: = %d ; Collide Level: = %d"), angle,level );
			if ( GWorld != NULL )
			{
				static int i = 1;
				GWorld->GetWorldInfo()->AddOnScreenDebugMessage((QWORD)((PTRINT)this) + i++, 50000.0f, FColor(255,255,255), FString::Printf(TEXT("rotate angle: = %d ; Collide Level: = %d"), angle,level));	
			}
			SetCollideLevel( static_cast< ECollideLevel >(level) );
			testbeginTime = nowTime;
		}
		testdelt = nowTime - endgameTime;
		if (  testdelt > 200000 )
		{
			GameOver();
		}
	}
	else
	{
		testbeginTime = nowTime;
		endgameTime = nowTime;
	}

}
