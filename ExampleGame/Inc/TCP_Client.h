/*=============================================================================
	和硬件的交互处理
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
	ES_Connecting, //准备连接
	ES_connected,  //连接上
	ES_playing,    //播放游戏
	ES_PlayPause,  //游戏暂停过程中
};
/**
 * 和硬件的交互类.	
 */
class FTCPClient
{
public:
	FTCPClient( void );

	//连接服务器
	UBOOL Connect( void );
	//设置旋转角度(正值为顺时针角度，负值为逆时针角度)
	void SetRotateAngle( DOUBLE angle );
	//设置振动等级
	void SetCollideLevel( ECollideLevel level );
	//游戏结束
	void GameOver( void );	

	void Tick( void );

	//得到摇杆硬件位置(-1~1)
	void GetInputPos( FLOAT &x1, FLOAT &y1, FLOAT &x2, FLOAT &y2 );


protected:
	//播放游戏
	void PlayGame( void );
	//停止游戏
	void StopGame( void );
	//游戏退出
	void ExitGame( void );	
	//游戏暂停
	void PauseGame( UBOOL bCancelPause );

	//切换游戏场景
	void changeGameTravel( void );
	//显示错误信息
	void logError( char *pError );

	//设置摇杆在屏幕上的位置
	void SetInputPos( char *pBuf );
	//通知开火
	void Fire( INT playerIdx );

private:
	DOUBLE curAngle;       //当前的旋转角度
	UBOOL bAngleDirty;     //是否需要更新角度
	DWORD angleUpdateTime; //角度更新的时间

	static const INT MAXDATASIZE = 100;
	char buf[ MAXDATASIZE ];

	EGameState curGameState;

	FLOAT curX1;             //保存第一个玩家当前的摇杆位置（屏幕上面的绝对像素）
	FLOAT curY1;
	FLOAT curX2;             //保存第二个玩家当前的摇杆位置（屏幕上面的绝对像素）
	FLOAT curY2;

};

//声明硬件交互的全局变量
extern FTCPClient GTCPClient;

#endif  //__HEADER_FTCPCLIENT_H

