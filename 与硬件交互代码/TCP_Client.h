/*=============================================================================
	��Ӳ���Ľ�������
=============================================================================*/

#ifndef __HEADER_FTCPCLIENT_H
#define __HEADER_FTCPCLIENT_H

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

protected:
	//������Ϸ
	void PlayGame( void );
	//��Ϸ�˳�
	void ExitGame( void );	
	//�л���Ϸ����
	void changeGameTravel( void );
	//��ʾ������Ϣ
	void logError( char *pError );

private:
	DOUBLE curAngle;       //��ǰ����ת�Ƕ�
	UBOOL bAngleDirty;     //�Ƿ���Ҫ���½Ƕ�
	DWORD angleUpdateTime; //�Ƕȸ��µ�ʱ��

	static const INT MAXDATASIZE = 100;
	char buf[ MAXDATASIZE ];

	EGameState curGameState;

};

//����Ӳ��������ȫ�ֱ���
extern FTCPClient GTCPClient;

#endif  //__HEADER_FTCPCLIENT_H

