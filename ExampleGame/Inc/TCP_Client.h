/*=============================================================================
	��Ӳ���Ľ�������
=============================================================================*/

#ifndef __HEADER_FTCPCLIENT_H
#define __HEADER_FTCPCLIENT_H
#include <vector>

enum ECollideLevel
{
	ECL_Weak =1,
	ECL_MIddle,
	ECL_strong,
};

enum EGameState
{
	ES_Connecting, //׼������
	ES_connected,  //������
	ES_playing,    //������Ϸ
	ES_PlayPause,  //��Ϸ��ͣ������
};
/**
 * ��Ӳ���Ľ�����.	
 */
class FTCPClient
{
public:
	FTCPClient( void );

	//���ӷ�����
	UBOOL Connect( void );
	//������ת�Ƕ�(��ֵΪ˳ʱ��Ƕȣ���ֵΪ��ʱ��Ƕ�)
	void SetRotateAngle( DOUBLE angle );
	//�����񶯵ȼ�
	void SetCollideLevel( ECollideLevel level );
	//��Ϸ����
	void GameOver( void );	

	void Tick( void );

	//�õ�ҡ��Ӳ��λ��(-1~1)
	void GetInputPos( FLOAT &x1, FLOAT &y1, FLOAT &x2, FLOAT &y2 );


protected:
	//������Ϸ
	void PlayGame( void );
	//ֹͣ��Ϸ
	void StopGame( void );
	//��Ϸ�˳�
	void ExitGame( void );	
	//��Ϸ��ͣ
	void PauseGame( UBOOL bCancelPause );

	//�л���Ϸ����
	void changeGameTravel( void );
	//��ʾ������Ϣ
	void logError( char *pError );

	//����ҡ������Ļ�ϵ�λ��
	void SetInputPos( char *pBuf );
	//֪ͨ����
	void Fire( INT playerIdx );

private:
	DOUBLE curAngle;       //��ǰ����ת�Ƕ�
	UBOOL bAngleDirty;     //�Ƿ���Ҫ���½Ƕ�
	DWORD angleUpdateTime; //�Ƕȸ��µ�ʱ��

	static const INT MAXDATASIZE = 100;
	char buf[ MAXDATASIZE ];

	EGameState curGameState;

	FLOAT curX1;             //�����һ����ҵ�ǰ��ҡ��λ�ã���Ļ����ľ������أ�
	FLOAT curY1;
	FLOAT curX2;             //����ڶ�����ҵ�ǰ��ҡ��λ�ã���Ļ����ľ������أ�
	FLOAT curY2;

};

//����Ӳ��������ȫ�ֱ���
extern FTCPClient GTCPClient;

#endif  //__HEADER_FTCPCLIENT_H

