// Network.h

#pragma once


extern "C" __declspec(dllexport)  bool _stdcall Client_Connect(char* IP,unsigned short);

extern "C" __declspec(dllexport)  bool _stdcall Client_GetMessage(char* buff);

extern "C" __declspec(dllexport)  void _stdcall Client_Close();

extern "C" __declspec(dllexport)  bool _stdcall Client_Send(const char* message);

