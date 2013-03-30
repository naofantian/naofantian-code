//-----------------------------------------------------------
//HanJiping.hanwukong@126.com
//-----------------------------------------------------------
class ArcadeGameEngine extends GameEngine
    native;

//CtrlMessage
enum CtrlMsg
{
    CM_Play,
    CM_Pause,
    CM_UnPause,
    CM_Stop,
    CM_ShutDown
};

cpptext
{
    virtual void Init();
    virtual void PreExit();
    virtual void Tick( FLOAT DeltaSeconds );
}

// ������ת���ݵ�������
native static final function PushRotationToCtrl(float Rot);

// ������Ϸ�����źŵ�������
native static final function GameCloseToCtrl();

final function LocalPlayer GetLocalPlayer()
{
    if(GamePlayers.length > 0)
    {
        return GamePlayers[0];
    }

    return none;
}

//����֪ͨ
event ProcFireMsg( int playerIdx )
{

}

event ProcCtrlMsg(CtrlMsg Msg)
{
    local ArcadePlayerController APC;

    APC = ArcadePlayerController(GetLocalPlayer().Actor);
    if(APC != None)
    {
        APC.ProcCtrlMsg(Msg);
    }
}

DefaultProperties
{

}
