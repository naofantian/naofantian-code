// TCP_Client.cpp 


#include "TCP_Client.h"
#include "Client.h"
#include< winsock.h >
#include <Windows.h>
#include <algorithm>
#include <ExampleGame.h>
//#pragma comment( lib, "ws2_32.lib" )
//#pragma comment( lib, "Network.lib" )
//#define BACKLOG 10
//char* IP="127.0.0.1";
//#define PORT 2046

FTCPClient::FTCPClient( void )
{
	bAngleDirty = FALSE;
	curAngle = 0.0;
	curGameState = ES_Connecting;
	angleUpdateTime = 0; 

	curX1 = 0.0f;
	curY1 = 0.0f;
	curX2 = 0.0f;
	curY2 = 0.0f;
}

//���ӷ�����
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



//������ת�Ƕ�
void FTCPClient::SetRotateAngle( DOUBLE angle )
{
	curAngle = angle;
	bAngleDirty = TRUE;
}
//�����񶯵ȼ�
void FTCPClient::SetCollideLevel( ECollideLevel level )
{
	if ( curGameState == ES_playing )
	{
		ZeroMemory( buf, MAXDATASIZE );
		sprintf_s( buf, MAXDATASIZE, "XH_SHAKE#%d", level );
		Client_Send( buf );
	}
}
//��Ϸ����
void FTCPClient::GameOver( void )
{
	if ( (curGameState == ES_playing) || ( curGameState == ES_PlayPause ) )
	{
		//changeGameTravel( );
		curGameState = ES_connected;
	}

	ZeroMemory( buf, MAXDATASIZE );
	strcpy_s( buf, MAXDATASIZE, "XH_CLOSE#00");
	Client_Send( buf ); 
	
}

//�л���Ϸ����
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
	else if ( (curGameState == ES_playing) || ( curGameState == ES_PlayPause ) )
	{
		GEngine->SetClientTravel( *FURL::DefaultLocalMap, TRAVEL_Partial );
		//GEngine->SetClientTravel( TEXT("ExampleEntry.umap"), TRAVEL_Partial );
		curGameState = ES_connected;
	}
}
//������Ϸ
void FTCPClient::PlayGame( void )
{
	if ( curGameState == ES_connected )
	{
		//changeGameTravel();
		curGameState = ES_playing;
	}

	UArcadeGameEngine* GameEngine = Cast<UArcadeGameEngine>(GEngine);
	if(GameEngine != NULL)
	{
		GameEngine->eventProcCtrlMsg(CM_Play);
	}
}
//��Ϸ�˳�
void FTCPClient::ExitGame( void )
{
	curGameState = ES_Connecting;
	Client_Close();
	//appRequestExit(FALSE);
	UArcadeGameEngine* GameEngine = Cast<UArcadeGameEngine>(GEngine);
	if(GameEngine != NULL)
	{
		GameEngine->eventProcCtrlMsg(CM_ShutDown);
	}
}

//ֹͣ��Ϸ
void FTCPClient::StopGame( void )
{
	UArcadeGameEngine* GameEngine = Cast<UArcadeGameEngine>(GEngine);
	if(GameEngine != NULL)
	{
		GameEngine->eventProcCtrlMsg(CM_Stop);
	}
}

//��Ϸ��ͣ
void FTCPClient::PauseGame( UBOOL bCancelPause )
{
	if ( bCancelPause )
	{
		curGameState = ES_playing;
	}
	else
	{
		curGameState = ES_PlayPause;
	}

	UArcadeGameEngine* GameEngine = Cast<UArcadeGameEngine>(GEngine);
	if(GameEngine != NULL)
	{
		if(bCancelPause)
		{
			GameEngine->eventProcCtrlMsg(CM_UnPause);
		}
		else
		{
			GameEngine->eventProcCtrlMsg(CM_Pause);
		}
	}
}

//��ʾ������Ϣ
void FTCPClient::logError( char *pError )
{
	GLog->Logf( ANSI_TO_TCHAR( pError ) );
}

void FTCPClient::Tick( void )
{

	if ( Client_GetMessage( buf ) )
	{
		if ( strncmp(buf, "XH_POS#", 7 ) == 0 )
		{
			SetInputPos( buf );
		}
		else if ( curGameState == ES_playing )  //��Ϸ������
		{
			if( strncmp(buf, "XH_FIRE#", 8 ) == 0 )
			{
				char*pNumber = buf + 8;
				std::string tempStr( pNumber );
				Fire( atoi( tempStr.c_str()) );
			}
			else if( strcmp(buf, "XH_PAUSE#00") == 0 ) //��Ϸ��ͣ
			{
				PauseGame( FALSE );
			}
			else if ( strcmp(buf, "XH_STOP#00") == 0 ) //����ֹͣ
			{
				//changeGameTravel();
				curGameState = ES_connected;
				StopGame();
			}
			else
			{
				logError( buf );
			}

		}
		else if( curGameState==ES_connected )//�ͷ��������Ӻ�,���Ҳ�������Ϸ�Ĺ�����
		{
			if( strcmp(buf, "XH_PLAY#00") == 0 ) //��ʼ��Ϸ
			{
				PlayGame();
			}
			else if ( strcmp(buf, "XH_SHUTDOWN#00") == 0 ) //�ػ�
			{
				ExitGame();
			}
			else
			{
				logError( buf );
			}
		}
		else if( curGameState== ES_PlayPause )//��Ϸ��ͣ
		{
			if( strcmp(buf, "XH_PLAY#00") == 0 ) //��ʼ��Ϸ
			{
				PauseGame( TRUE );
			}
			else if ( strcmp(buf, "XH_SHUTDOWN#00") == 0 ) //�ػ�
			{
				ExitGame();
			}
			else if ( strcmp(buf, "XH_STOP#00") == 0 ) //����ֹͣ
			{
				//changeGameTravel();
				curGameState = ES_connected;
				StopGame();
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

	if ( bAngleDirty && (curGameState == ES_playing)) //������ת�Ƕ�����
	{
		DWORD nowTime = GetTickCount();
		INT deltTime = nowTime - angleUpdateTime;
		//if ( deltTime >= 200 || deltTime < 0 )
		{
			ZeroMemory( buf, MAXDATASIZE );
			sprintf_s( buf, MAXDATASIZE, "XH_ROTATION#%f", curAngle );
			Client_Send( buf ); 
			bAngleDirty = FALSE;
			angleUpdateTime = nowTime;
		}
	}


	////������
	//DWORD nowTime = GetTickCount();
	//static DWORD testbeginTime = nowTime;
	//static DWORD endgameTime = nowTime;
	//if ( curGameState== ES_playing )  //��Ϸ������
	//{
	//	int testdelt = nowTime - testbeginTime;
	//	if ( testdelt > 10000 )
	//	{
	//		srand( (unsigned)time( NULL ) );
	//		INT angle =  rand() % 720 - 360;
	//		SetRotateAngle( angle );
	//		int level = rand() % 3 + 1;
	//		debugf( TEXT("rotate angle: = %d ; Collide Level: = %d"), angle,level );
	//		if ( GWorld != NULL )
	//		{
	//			static int i = 1;
	//			GWorld->GetWorldInfo()->AddOnScreenDebugMessage((QWORD)((PTRINT)this) + i++, 50000.0f, FColor(255,255,255), FString::Printf(TEXT("rotate angle: = %d ; Collide Level: = %d"), angle,level));	
	//		}
	//		SetCollideLevel( static_cast< ECollideLevel >(level) );
	//		testbeginTime = nowTime;
	//	}
	//	testdelt = nowTime - endgameTime;
	//	if (  testdelt > 200000 )
	//	{
	//		GameOver();
	//	}
	//}
	//else
	//{
	//	testbeginTime = nowTime;
	//	endgameTime = nowTime;
	//}

}

	//����ҡ������Ļ�ϵ�λ��
void FTCPClient::SetInputPos( char *pBuf )
{
	if( pBuf == NULL )
		return;

	std::string posStr( pBuf );
	std::string tempStr;
	INT preIdx = 7;
	INT curIdx = posStr.find( ',');

	if( curIdx == std::string::npos )
		return;

	tempStr = posStr.substr( preIdx, curIdx - preIdx );
	curX1 = atof( tempStr.c_str() );

	preIdx = curIdx+1;
	curIdx = posStr.find( ',', preIdx );
	if( curIdx == std::string::npos )
		return;
	tempStr = posStr.substr( preIdx, curIdx - preIdx );
	curY1 = atof( tempStr.c_str() );

	preIdx = curIdx+1;
	curIdx = posStr.find( ',', preIdx );
	if( curIdx == std::string::npos )
		return;
	tempStr = posStr.substr( preIdx, curIdx - preIdx );
	curX2 = atof( tempStr.c_str() );

	preIdx = curIdx+1;
	curIdx = posStr.length();
	if( preIdx < curIdx )
	{
		tempStr = posStr.substr( preIdx, curIdx - preIdx );
		curY2 = atof( tempStr.c_str() );
	}
}

//�õ�ҡ��Ӳ��λ��
void FTCPClient::GetInputPos( FLOAT &x1, FLOAT &y1, FLOAT &x2, FLOAT &y2 )
{
	x1 = curX1;
	y1 = curY1;
	x2 = curX2;
	y2 = curY2;
}

//֪ͨ����
void FTCPClient::Fire( INT playerIdx )
{
	UArcadeGameEngine* GameEngine = Cast<UArcadeGameEngine>(GEngine);
	if(GameEngine != NULL)
	{
		GameEngine->eventProcFireMsg(playerIdx);
	}
}

//ͨѶЭ�����
FTCPClient GTCPClient;