/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

using System;
using System.Collections.Generic;
using System.Text;

namespace UnrealBuildTool
{
	class UE3BuildExampleGame : UE3BuildGame
	{
        /** Returns the singular name of the game being built ("Example", "UT3", etc) */
		public string GetGameName()
		{
			return "Example";
		}

		/** Returns a subplatform (e.g. dll) to disambiguate object files */
		public string GetSubPlatform()
		{
			return ( "" );
		}

		/** Get the desired OnlineSubsystem. */
		public string GetDesiredOnlineSubsystem( CPPEnvironment CPPEnv, UnrealTargetPlatform Platform )
		{
			string ForcedOSS = UE3BuildTarget.ForceOnlineSubsystem( Platform );
			if( ForcedOSS != null )
			{
				return ( ForcedOSS );
			}

			return ( "PC" );
		}

		/** Returns true if the game wants to have PC ES2 simulator (ie ES2 Dynamic RHI) enabled */
		public bool ShouldCompileES2()
		{
			return false;
		}

        /** Allows the game add any global environment settings before building */
        public void GetGameSpecificGlobalEnvironment(CPPEnvironment GlobalEnvironment)
        {

        }

        /** Returns the xex.xml file for the given game */
		public FileItem GetXEXConfigFile()
		{
			return FileItem.GetExistingItemByPath("ExampleGame/Live/xex.xml");
		}

        /** Allows the game to add any additional environment settings before building */
		public void SetUpGameEnvironment(CPPEnvironment GameCPPEnvironment, LinkEnvironment FinalLinkEnvironment, List<UE3ProjectDesc> GameProjects)
		{
			GameCPPEnvironment.IncludePaths.Add("ExampleGame/Inc");
			GameProjects.Add( new UE3ProjectDesc( "ExampleGame/ExampleGame.vcproj") );

			if (UE3BuildConfiguration.bBuildEditor &&
				(GameCPPEnvironment.TargetPlatform == CPPTargetPlatform.Win32 || GameCPPEnvironment.TargetPlatform == CPPTargetPlatform.Win64))
			{
				GameProjects.Add( new UE3ProjectDesc( "ExampleEditor/ExampleEditor.vcproj") );
				GameCPPEnvironment.IncludePaths.Add("ExampleEditor/Inc");
			}

			GameCPPEnvironment.Definitions.Add("GAMENAME=EXAMPLEGAME");
			GameCPPEnvironment.Definitions.Add("IS_EXAMPLEGAME=1");

            FinalLinkEnvironment.AdditionalLibraries.Add("ws2_32.lib");
            FinalLinkEnvironment.AdditionalLibraries.Add("../../Binaries/win32/Network.lib");

		}
	}
}
