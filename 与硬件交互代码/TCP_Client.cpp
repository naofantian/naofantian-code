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



//������ת�Ƕ�(0~360)
void FTCPClient::SetRotateAngle( INT angle )
{
	if ( angle != curAngle )
	{
		curAngle = angle;
		bAngleDirty = TRUE;
	}

}
//�����񶯵ȼ�
void FTCPClient::SetCollideLevel( ECollideLevel level )
{
	ZeroMemory( buf, MAXDATASIZE );
	sprintf_s( buf, MAXDATASIZE, "XH_SHAKE#%d", level );
    Client_Send( buf );

}
//��Ϸ����
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
	else if ( curGameState == ES_playing )
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
		changeGameTravel();
	}
}
//��Ϸ�˳�
void FTCPClient::ExitGame( void )
{
	curGameState = ES_Connecting;
	Client_Close();
	appRequestExit(FALSE);
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
		if ( curGameState== ES_playing )  //��Ϸ������
		{
			if( strcmp(buf, "XH_STOP#00") == 0 ) //����ֹͣ
			{
				changeGameTravel();
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
		else
		{
			logError( buf );
		}

	}

	if ( bAngleDirty ) //������ת�Ƕ�����
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


	//������
	DWORD nowTime = GetTickCount();
	static DWORD testbeginTime = nowTime;
	static DWORD endgameTime = nowTime;
	if ( curGameState== ES_playing )  //��Ϸ������
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
