@echo off
rem ---------------------------------------------------------------------
rem --- Init ---
rem ---------------------------------------------------------------------
set var_Debug=0
set str_Title=      MaxPayne Conversion Tool by Darkje, v1.12 - 21-Feb-2010      
if not "%1"=="" cd "%*"

rem --- Adjust conversion delay here (var_ConversionDelay=seconds) ---
set var_ConversionDelay=1
set var_ExitDelay=2
set var_ActionFinishedDelay=3
set var_DbgL2Delay=1
call :sub_DetectUac

rem ---------------------------------------------------------------------
rem --- Game Conv Screen, Menu control structure ---
rem ---------------------------------------------------------------------
:lbl_GameMenu
call :msg_Welcome
call :msg_GameConvScreen
call :sub_DetectionPhase
if %flag_FreshGame%==1 (
	if %var_TotModCount%==0 ( 
		call :sub_GameMenu1
	) else (
		call :sub_GameMenu2
	)
) else (
	if exist backup\*.ras (
		if %var_TotModCount%==0	(
			call :sub_GameMenu3
		) else (
			call :sub_GameMenu4
		)
	) else (
		if %var_TotModCount%==0	(
			call :sub_GameMenu5
		) else (
			call :sub_GameMenu6
		)
	)
)

rem ---------------------------------------------------------------------
rem Game Conv Screen menus
rem ---------------------------------------------------------------------
:sub_GameMenu1
rem --- just fresh game, no mods ---
call :msg_YouWantTo 1
call :msg_GameConvOpt
call :msg_LaunchOpt
call :msg_OtherOpt
call :msg_SdeOpt
choice /c clsde
if errorlevel 5 goto :lbl_Exit
if errorlevel 4 goto :lbl_ToggleDebug
if errorlevel 3 goto :lbl_GameMenu
if errorlevel 2 goto :lbl_LaunchGame
call :sub_CvrtGame
goto :lbl_GameMenu

rem ---------------------------------------------------------------------
:sub_GameMenu2
rem --- fresh game and mods too ---
call :msg_YouWantTo 2
call :msg_GameConvOpt
call :msg_LaunchOpt
call :msg_OtherOpt
call :msg_ModOpt
call :msg_SdeOpt
choice /c clmsde
if errorlevel 6 goto :lbl_Exit
if errorlevel 5 goto :lbl_ToggleDebug
if errorlevel 4 goto :lbl_GameMenu
if errorlevel 3 goto :lbl_ModMenu
if errorlevel 2 goto :lbl_LaunchGame
call :sub_CvrtGame
goto :lbl_GameMenu

rem ---------------------------------------------------------------------
:sub_GameMenu3
rem --- just converted game, no mods --- 
call :msg_YouWantTo 3
call :msg_LaunchConvOpt
call :msg_RestoreGameOpt
call :msg_OtherOpt
call :msg_SdeOpt
choice /c lrsde
if errorlevel 5 goto :lbl_Exit
if errorlevel 4 goto :lbl_ToggleDebug
if errorlevel 3 goto :lbl_GameMenu
if errorlevel 2 (
	call :sub_RestoreGame
	goto :lbl_GameMenu
)
goto :lbl_LaunchGame

rem ---------------------------------------------------------------------
:sub_GameMenu4
rem --- converted game and mods too ---
call :msg_YouWantTo 4
call :msg_LaunchConvOpt
call :msg_RestoreGameOpt
call :msg_OtherOpt
call :msg_ModOpt
call :msg_SdeOpt
choice /c lrmsde
if errorlevel 6 goto :lbl_Exit
if errorlevel 5 goto :lbl_ToggleDebug
if errorlevel 4 goto :lbl_GameMenu
if errorlevel 3 goto :lbl_ModMenu
if errorlevel 2 (
	call :sub_RestoreGame
	goto :lbl_GameMenu
)
goto :lbl_LaunchGame

rem ---------------------------------------------------------------------
:sub_GameMenu5
rem --- no game, no mods ---
call :msg_YouWantTo 5
call :msg_NoMainOpt
call :msg_OtherOpt
call :msg_SdeOpt
choice /c sde
if errorlevel 3 goto :lbl_Exit
if errorlevel 2 goto :lbl_ToggleDebug
goto :lbl_GameMenu

rem ---------------------------------------------------------------------
:sub_GameMenu6
rem --- no game, only mods ---
call :msg_YouWantTo 6
call :msg_ModOpt
call :msg_OtherOpt
call :msg_SdeOpt
choice /c msde
if errorlevel 4 goto :lbl_Exit
if errorlevel 3 goto :lbl_ToggleDebug
if errorlevel 2 goto :lbl_GameMenu
goto :lbl_ModMenu

rem ---------------------------------------------------------------------
rem --- Mod Conv Screen, Menu control structure ---
rem ---------------------------------------------------------------------
:lbl_ModMenu
call :msg_Welcome
call :msg_ModConvScreen
call :sub_DetectionPhase
call :sub_ListMods
if %var_NewModCount% gtr 0 (
	if %var_ConvModCount% == 0 (
		if %var_ExcludedModCount% == 0 (
			call :sub_ModMenu1
		) else (
			call :sub_ModMenu5
		)
	) else (
		if %var_ExcludedModCount% == 0 (
			call :sub_ModMenu3
		) else (
			call :sub_ModMenu7
		)
	)
) else ( 
	if %var_ConvModCount% == 0 (
		call :sub_ModMenu4
	) else (
		if %var_ExcludedModCount% == 0 (
			call :sub_ModMenu2
		) else (
			call :sub_ModMenu6
		)
	)
)
call :sub_Waitasec %var_ActionFinishedDelay%
goto :lbl_GameMenu

rem ---------------------------------------------------------------------
rem Mod Conv Screen menus
rem ---------------------------------------------------------------------
:sub_ModMenu1
rem --- only unconverted mods ---
call :msg_ModYouWantTo 1
call :msg_ConvModOpt
call :msg_AddModExclOpt
call :msg_OtherOpt
call :msg_EndmodOpt
choice /c mase
if errorlevel 4 goto :lbl_GameMenu
if errorlevel 3 goto :lbl_ModMenu
if errorlevel 2 (
	call :sub_AddExclusion
) else (
	call :sub_AddNewMods
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_ModMenu2
rem --- only converted mods ---
call :msg_ModYouWantTo 2
call :msg_RestoreModOpt
call :msg_OtherOpt
call :msg_EndmodOpt
choice /c rse
if errorlevel 3 goto :lbl_GameMenu
if errorlevel 2 goto :lbl_ModMenu
call :sub_RestoreMods
goto :EOF

rem ---------------------------------------------------------------------
:sub_ModMenu3
rem --- converted and unconverted mods ---
call :msg_ModYouWantTo 3
call :msg_ConvModOpt
call :msg_RestoreModOpt
call :msg_AddModExclOpt
call :msg_OtherOpt
call :msg_EndmodOpt
choice /c mrase
if errorlevel 5 goto :lbl_GameMenu
if errorlevel 4 goto :lbl_ModMenu
if errorlevel 3 (
	call call :sub_AddExclusion
	goto :EOF
)
if errorlevel 2 (
	call :sub_RestoreMods
) else ( 
	call :sub_AddNewMods
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_ModMenu4
rem --- only excluded mods ---
call :msg_ModYouWantTo 4
call :msg_RestoreModOpt
call :msg_ClrModExclOpt
call :msg_OtherOpt
call :msg_EndmodOpt
choice /c rhse
if errorlevel 4 goto :lbl_GameMenu
if errorlevel 3 goto :lbl_ModMenu
if errorlevel 2 (
	call :sub_ClrModExcl
) else (
	call :sub_RestoreMods
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_ModMenu5
rem --- unconverted and excluded mods ---
call :msg_ModYouWantTo 5
call :msg_ConvModOpt
call :msg_AddModExclOpt
call :msg_ClrModExclOpt
call :msg_OtherOpt
call :msg_EndmodOpt
choice /c mahse
if errorlevel 5 goto :lbl_GameMenu
if errorlevel 4 goto :lbl_ModMenu
if errorlevel 3 (
	call :sub_ClrModExcl
	goto :EOF
)
if errorlevel 2 (
	call call :sub_AddExclusion
) else (
	call :sub_AddNewMods
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_ModMenu6
rem --- converted and excluded mods ---
call :msg_ModYouWantTo 6
call :msg_RestoreModOpt
call :msg_ClrModExclOpt
call :msg_OtherOpt
call :msg_EndmodOpt
choice /c rhse
if errorlevel 4 goto :lbl_GameMenu
if errorlevel 3 goto :lbl_ModMenu
if errorlevel 2 (
	call :sub_ClrModExcl
) else (
	call :sub_RestoreMods
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_ModMenu7
rem --- unconverted, converted and excluded mods ---
call :msg_ModYouWantTo 7
call :msg_ConvModOpt
call :msg_AddModExclOpt
call :msg_RestoreModOpt
call :msg_ClrModExclOpt
call :msg_OtherOpt
call :msg_EndmodOpt
choice /c marhse
if errorlevel 6 goto :lbl_GameMenu
if errorlevel 5 goto :lbl_ModMenu
if errorlevel 4 (
	call :sub_ClrModExcl
	goto :EOF
)
if errorlevel 3 (
	call :sub_RestoreMods
	goto :EOF
)
if errorlevel 2 (
	call call :sub_AddExclusion
) else (
	call :sub_AddNewMods
)
goto :EOF

rem ---------------------------------------------------------------------
rem --- conversion subs ---
rem ---------------------------------------------------------------------
:sub_Convert
set flag_Dont=0
if /i %1=="x_level1.ras" set flag_Dont=1
if /i %1=="x_level2.ras" set flag_Dont=1
if /i %1=="x_level3.ras" set flag_Dont=1
if %flag_Dont%==0 (
	if %var_Debug% gtr 0 call :msg_StartConvfileDbg %1
	if not exist backup md backup
	copy %1 backup >nul
	md tmp
	if %var_Debug% gtr 0 call :msg_ExtractDbg %1
	rasmaker -x %1 tmp >nul
	if %var_Debug% gtr 0 call :msg_ConvertDbg
	for /r tmp\data %%i in (*.wav ) do call :sub_SoxLoop "%%i"
	if %var_Debug% gtr 0 call :msg_PackDbg %1
	rasmaker -a -p tmp %1 >nul
	call :sub_CheckConv %1 %2
	call :sub_Waitasec %var_ConversionDelay%
	if %var_Debug% gtr 0 call :msg_DeltmpDbg
	call :sub_RemoveTmp
	if %var_Debug% gtr 0 call :msg_FiledoneDbg %1
)
set flag_Dont=
goto :EOF

rem ---------------------------------------------------------------------
:sub_SoxLoop
if %var_Debug%==0 SoX -q %1 -u -b "%~dp1outfile.wav" 2>nul
if %var_Debug%==1 SoX -q %1 -u -b "%~dp1outfile.wav" 2>nul
if %var_Debug%==2 (
	call :msg_LineDbg
	SoX -V %1 -u -b "%~dp1outfile.wav"
	call :sub_Waitasec %var_DbgL2Delay%
)
del %1
ren "%~dp1outfile.wav" "%~nx1"
goto :EOF

rem ---------------------------------------------------------------------
:sub_CheckConv
set flag_RasMsg=0
if %var_Debug% gtr 0 call :msg_CheckConvDbg
if %~z1==%~z2 (
	call :sub_KeepExcl %1
	if %var_Debug% gtr 0 call :msg_BadConvEqualDbg
	call :sub_BadConv %1 %2
	if %var_Debug% gtr 0 call :msg_BackupRestDbg %1
	set flag_RasCheck=1
	set flag_RasMsg=1
) else (
	if %~z1==0 (
		call :sub_KeepExcl %1
		if %var_Debug% gtr 0 call :msg_BadConvZeroDbg
		call :sub_BadConv %1 %2
		if %var_Debug% gtr 0 call :msg_BackupRestDbg %1
		set flag_RasCheck=1
		set flag_RasMsg=1
	)
)
if exist x_english.ras (
	if "%~nx1"=="x_data.ras" (
		if not "%~z1"=="151433969" (
			call :msg_ConvFileSizeBad %1
			set flag_RasCheck=1
			set flag_RasMsg=1
		)
	)
	if "%~nx1"=="x_english.ras" (
		if not "%~z1"=="412658843" (
			call :msg_ConvFileSizeBad %1
			set flag_RasCheck=1
			set flag_RasMsg=1
		)
	)
)
if "%~nx1"=="x_music.ras" (
	if not "%~z1"=="286777161" (
		call :msg_ConvFileSizeBad %1
		set flag_RasCheck=1
		set flag_RasMsg=1
	)
)
if not %flag_RasMsg%==1 call :msg_ConvFileOk "%~nx1"
set flag_RasMsg=
goto :EOF

rem ---------------------------------------------------------------------
:sub_KeepExcl
if not exist convexcl md convexcl
call :msg_ConvFileBad "%~nx1"
goto :EOF

rem ---------------------------------------------------------------------
:sub_BadConv
del %1
copy %2 "%~dp1" >nul
del %2
call :sub_DelBakIfEmpty
goto :EOF

rem ---------------------------------------------------------------------
:sub_CvrtGame
call :msg_working
call :msg_StartConvGame
set flag_RasCheck=0
for %%i in (*.ras) do call :sub_Convert "%%i" "backup\%%i"
if not %flag_RasCheck%==1 ( 
	call :msg_FileSizeGood
) else (
	call :msg_ConvFailed
	call :sub_RestoreExt ras
	call :sub_DelBakIfEmpty
	pause
)
call :msg_GameConvDone
call :sub_Waitasec %var_ActionFinishedDelay%
if not %flag_RasCheck%==1 call :msg_finished
goto :EOF
rem ---------------------------------------------------------------------
:sub_AddNewMods
call :msg_StartConvMod
set var_File=
call :msg_TypeFileName
set /p var_File= -^> 
if not "%var_File%"=="" (
	if not "%var_File%" == "*" (
		if exist "%var_File%.mpm" (
			if not exist "backup\%var_File%.mpm" (
				if not exist "convexcl\%var_File%.log" (
					set flag_RasCheck=0
					call :msg_ConvFile "%var_File%"
					call :sub_Convert "%var_File%.mpm" "backup\%var_File%.mpm" 
				)
			)
		) else (
			call :msg_FileNotFound "%var_File%"
			goto :sub_AddNewMods
		)
	) else (
		for %%i in (*.mpm) do (
			if not exist "backup\%%i" (
				if not exist "convexcl\%%~ni.log" (
					set flag_RasCheck=0
					call :sub_Convert "%%i" "backup\%%i" 
				)
			)
		)
	)
) else (
	call :msg_NoAction
)
call :msg_ModConvDone
call :sub_Waitasec %var_ActionFinishedDelay%
goto :EOF

rem ---------------------------------------------------------------------
rem --- restore subs ---
rem ---------------------------------------------------------------------
:sub_RestoreGame
call :msg_working
call :msg_StartRestore
call :sub_RestoreExt ras
call :sub_DelBakIfEmpty
call :msg_RestoreDone
call :sub_Waitasec %var_ActionFinishedDelay%
call :msg_finished
goto :EOF

rem ---------------------------------------------------------------------
:sub_RestoreMods
call :msg_StartRestore
set var_File=
call :msg_TypeFileName
set /p var_File= -^> 
if not "%var_File%"=="" (
	if not "%var_File%" == "*" (
		if exist "backup\%var_File%.mpm" (
			call :Sub_RestoreFile "backup\%var_File%.mpm"
		) else (
			call :msg_FileNotFound "%var_File%"
			goto :sub_RestoreMods
		)
	) else (
		call :sub_RestoreExt mpm
		call :sub_DelBakIfEmpty
	)
) else (
	call :msg_NoAction
)
call :msg_RestoreDone
call :sub_Waitasec %var_ActionFinishedDelay%
goto :EOF

rem ---------------------------------------------------------------------
:sub_RestoreFile
copy %1 . >nul
call :msg_FileRestored %~nx1
del %1 /q
goto :EOF

rem ---------------------------------------------------------------------
:sub_RestoreExt
if %var_Debug% gtr 0 call :msg_RestoreDbg
for %%i in (backup\*.%1) do (
	copy "%%i" . >nul
	call :msg_FileRestored "%%~nxi"
)
del backup\*.%1 /q
if %var_Debug% gtr 0 call :msg_DelbakDbg
goto :EOF

rem ---------------------------------------------------------------------
:sub_DelBakIfEmpty
if not exist backup\*.mpm (
	if not exist backup\*.ras rd  backup /s /q
)
goto :EOF

rem ---------------------------------------------------------------------
rem --- History subs ---
rem ---------------------------------------------------------------------
:sub_ClrModExcl
call :msg_StartDelExclusion
set var_File=
call :msg_TypeFileName
set /p var_File= -^> 
if not "%var_File%"=="" (
	if not "%var_File%" == "*" (
		if exist "convexcl\%var_File%.log" (
			call :msg_ExcludeRemove "%var_File%"
			del "convexcl\%var_File%.log"
			if not exist convexcl\*.log rd convexcl /s /q
		) else (
			call :msg_FileNotFound "%var_File%"
			goto :sub_ClrModExcl
		)
	) else (
		call :msg_ExcludeListRemoved
		rd convexcl /s /q
	)
) else (
	call :msg_NoAction
)
call :msg_ExclusionDone
call :sub_Waitasec %var_ActionFinishedDelay%
goto :EOF

rem ---------------------------------------------------------------------
:sub_AddExclusion
call :msg_StartAddExclusion
set var_File=
call :msg_TypeFileName
set /p var_File= -^> 
if not "%var_File%"=="" (
	if not "%var_File%" == "*" (
		if exist "%var_File%.mpm" (
			if not exist "backup\%var_File%.mpm" (
				if not exist "convexcl\%var_File%.log" (
					if not exist convexcl md convexcl
					call :msg_LogExcludedFile "%var_File%.mpm"
					call :msg_FileExclude "%var_File%"
				)
			)
		) else (
			call :msg_FileNotFound "%var_File%"
			goto sub_AddExclusion
		)
	) else (
		for %%i in (*.mpm) do (
			if not exist "backup\%%i" (
				if not exist "convexcl\%%~ni.log" (
					if not exist convexcl md convexcl
					call :msg_LogExcludedFile "%%~nxi"
					call :msg_FileExclude "%%~nxi"
				)
			)
		)
	)
) else (
	call :msg_NoAction
)
call :msg_ExclusionDone
call :sub_Waitasec %var_ActionFinishedDelay%
goto :EOF

rem ---------------------------------------------------------------------
rem --- listing subs ---
rem ---------------------------------------------------------------------
:sub_ListNewMods
for %%i in (*.mpm) do if not exist "backup\%%i" if not exist "convexcl\%%~ni.log" echo    - %%i
goto :EOF

rem ---------------------------------------------------------------------
:sub_ListConvMods
for %%i in (backup/*.mpm) do echo    - %%i
goto :EOF

rem ---------------------------------------------------------------------
:sub_ListExcludedMods
for %%i in (*.mpm) do if not exist "backup\%%i" if exist "convexcl\%%~ni.log" echo    - %%i
goto :EOF

rem ---------------------------------------------------------------------
:sub_ListMods
if %var_NewModCount% gtr 0 (
	call :msg_NewModFnd 
	call :sub_ListNewMods
)
if %var_ConvModCount% gtr 0 (
	call :msg_ConvModsFnd
	call :sub_ListConvMods
)
if %var_ExcludedModCount% gtr 0 (
	call :msg_ExcludedModsFnd
	call :sub_ListExcludedMods
)
goto :EOF

rem ---------------------------------------------------------------------
rem --- detection phase control and report structure ---
rem ---------------------------------------------------------------------
:sub_DetectionPhase
call :msg_HorLine
call :msg_AnalyseCurrent
if %var_Debug% gtr 0 call :msg_DebugStat
call :msg_WorkDir
call :sub_DetectTmp 1
call :sub_DetectBackupProbs
call :sub_DetectFreshGame
if %var_Debug% gtr 0 call :msg_FilesdetectedDbg
call :sub_DetectScriptNeeds
if %flag_ScriptNeeds%==1 (
	if %var_Debug% gtr 0 call :msg_ScriptNeedFndDbg
) else (
	if %var_Debug% gtr 0 (
		call :msg_ScriptNeedBadDbg
		call :sub_DetectScriptNeeds 1
	)
)
call :sub_DetectGame
call :sub_DetectLang
call :sub_DetectConvData
if %flag_ConvData%==1 (
	if %var_Debug% gtr 0 call :msg_ConvDataFndDbg
) else (
	if %var_Debug% gtr 0 (
		call :msg_ConvDataBadDbg
		call :sub_DetectConvData 1
	)
)
call :sub_DetectRun
if %flag_GameExe%==1 (
	if %var_Debug% gtr 0 call :msg_GameExeFndDbg
) else (
	if %var_Debug% gtr 0 call :msg_GameExeBadDbg
)
if %flag_RunFiles%==1 (
	if %var_Debug% gtr 0 call :msg_AdtlFndDbg
) else (
	if %var_Debug% gtr 0 (
		call :msg_AdtlBadDbg
		call :sub_DetectRun 1
	)
)
if %flag_LangFiles%==1 (
	if %var_Debug% gtr 0 for %%i in (*.ras) do call :sub_CheckLang %%i,1
) else (
	if %var_Debug% gtr 0 call :msg_LangBadDbg
)
if %var_Debug% gtr 0 if exist backup call :msg_BackupFndDbg
call :sub_DetectMods
set flag_AllFiles=0
if %flag_ScriptNeeds%==1 (
	if %flag_GameExe%==1 (
		if %flag_RunFiles%==1 (
			set flag_AllFiles=1
		)
	)
)
if %flag_FreshGame%==1 (
	if %flag_RunFiles%==1 call :msg_FreshGameFnd
) else (
	if exist backup\*.ras if %flag_RunFiles%==1 call :msg_ConvGameFnd
)
set flag_OnlyMods=0
if %var_TotModCount% gtr 0 (
	if %flag_ScriptNeeds% == 1 set flag_OnlyMods=1
)
if %flag_AllFiles%==1 (
	color 2F
	if %var_Debug% gtr 0 call :msg_NoProbsDbg
	if %var_TotModCount% gtr 0 ( 
		call :msg_TotMods
	) else (
		call :msg_NoModsFnd
	)
) else (
	if %var_Debug% == 0 call :msg_NoValidGame
	if %var_TotModCount% gtr 0 ( 
		call :msg_TotMods 
	) else (
		call :msg_NoModsFnd
	)
	if %flag_OnlyMods% == 1 (
		color 2F
		if %var_Debug% gtr 0 call :msg_NoProbsModsDbg
		if %var_Debug% == 0 call :msg_NoProbsMods
	) else (
		color 4F
		if %var_Debug% gtr 0 call :msg_ProbsDbg
		if %var_Debug%==0 call :msg_PosProbs
	)
)
goto :EOF

rem ---------------------------------------------------------------------
rem --- detection subs ---
rem ---------------------------------------------------------------------
:sub_DetectMods
set /a var_NewModCount=0
set /a var_ConvModCount=0
set /a var_ExcludedModCount=0
for %%i in (*.mpm) do (
	if not exist "backup\%%i" ( 
		if not exist "convexcl\%%~ni.log" (
			set /a var_NewModCount += 1
		) else (
			set /a var_ExcludedModCount += 1
		)
	) else (
		set /a var_ConvModCount += 1
	)
)
set /a var_TotModCount=%var_NewModCount%+%var_ConvModCount%+%var_ExcludedModCount%
goto :EOF

rem ---------------------------------------------------------------------
:sub_DetectGame
set flag_GameExe=0
if /i exist maxpayne.exe set flag_GameExe=1
goto :EOF

rem ---------------------------------------------------------------------
:sub_DetectScriptNeeds
set flag_ScriptNeeds=1
set flag_CanConvert=1
if /i not exist rasmaker.exe (
	set flag_ScriptNeeds=0
	set flag_CanConvert=0
	if "%1"=="1" call :msg_Miss rasmaker.exe
)
if /i not exist rl.dll (
	set flag_ScriptNeeds=0
	if "%1"=="1" call :msg_Miss rl.dll
	set flag_CanConvert=0
)
if /i not exist shortcut.exe (
	set flag_ScriptNeeds=0
	if "%1"=="1" call :msg_Miss shortcut.exe
)
if /i not exist sox.exe (
	set flag_ScriptNeeds=0
	if "%1"=="1" call :msg_Miss sox.exe
	set flag_CanConvert=0
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_DetectConvData
set flag_ConvData=1
if /i not exist x_data.ras (
	set flag_ConvData=0
	if "%1"=="1" call :msg_Miss x_data.ras
)
if /i not exist x_music.ras (
	set flag_ConvData=0
	if "%1"=="1" call :msg_Miss x_music.ras
)
if %flag_LangFiles%==0 (
	set flag_ConvData=0
	if "%1"=="1" call :msg_Miss x_^(language^).ras
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_DetectLang
set flag_LangFiles=0
for %%i in (*.ras) do call :sub_CheckLang %%i
goto :EOF

rem ---------------------------------------------------------------------
:sub_CheckLang
set flag_Dont=0
if /i %1==x_level1.ras set flag_Dont=1
if /i %1==x_level2.ras set flag_Dont=1
if /i %1==x_level3.ras set flag_Dont=1
if /i %1==x_data.ras set flag_Dont=1
if /i %1==x_music.ras set flag_Dont=1
if %flag_Dont%==0 (
	if "%2"=="" (
		set flag_LangFiles=1
	) else (
		call :msg_LangFndDbg %1
	)
)
set flag_Dont=
goto :EOF

rem ---------------------------------------------------------------------
:sub_DetectRun
set flag_RunFiles=1
if /i not exist e2driver\e2_d3d8_driver_mfc.dll (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss e2driver\e2_d3d8_driver_mfc.dll
)
if /i not exist movies\intro.mpg (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss movies\intro.mpg
)
if /i not exist e2mfc.dll (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss e2mfc.dll
)
if /i not exist grphmfc.dll (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss grphmfc.dll
)
if %flag_GameExe%==0 (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss maxpayne.exe
)
if /i not exist mfc42.dll ( 
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss mfc42.dll
)
if /i not exist msvcirt.dll (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss msvcirt.dll
)
if /i not exist msvcp60.dll (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss msvcp60.dll
)
if /i not exist msvcrt.dll (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss msvcrt.dll
)
if /i not exist rlmfc.dll (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss rlmfc.dll
)
if /i not exist sndmfc.dll (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss sndmfc.dll
)
if /i not exist x_data.ras (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss x_data.ras
)
if %flag_LangFiles%==0 (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss x_^(language^).ras
)
if /i not exist x_level1.ras (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss x_level1.ras
)
if /i not exist x_level2.ras (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss x_level2.ras
)
if /i not exist x_level3.ras (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss x_level3.ras
)
if /i not exist x_music.ras (
	set flag_RunFiles=0
	if "%1"=="1" call :msg_Miss x_music.ras
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_DetectFreshGame
set flag_FreshGame=0
if exist *.ras (
	set flag_FreshGame=1
	for %%i in (*.ras) do call :sub_FreshSize %%i
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_FreshSize
if exist x_english.ras if %1==x_data.ras if not "%~z1" == "134236027" set flag_FreshGame=0
if %1==x_music.ras if not "%~z1" == "144606272" set flag_FreshGame=0
goto :EOF

rem ---------------------------------------------------------------------
:sub_DetectUac
set flag_Uac=0
mkdir uactest 2>nul
if errorlevel 1 (
	set flag_Uac=1
) else (
	rd uactest /s /q
	echo.
)
if %flag_Uac%==1 goto :lbl_Handle_Uac
goto :EOF

rem ---------------------------------------------------------------------
:sub_DetectTmp
if exist tmp (
:sub_RemoveTmp
	rd tmp /s /q 2>nul
	call :sub_Waitasec %var_ConversionDelay%
	if exist tmp (
		call :msg_TmpProb
		pause >nul
		goto :sub_RemoveTmp
	)
	if "%1"=="1" call :msg_TmpCleared
)
goto :EOF

rem ---------------------------------------------------------------------
rem --- backup sync steam verify ---
rem ---------------------------------------------------------------------
:sub_DetectBackupProbs
set flag_BackupProbs=0
for %%i in (backup/*.ras) do call :sub_CompareGameFileSize %%i
call :sub_SyncBackupDir
if %flag_BackupProbs%==1 call :msg_BackupsSynced
set flag_BackupProbs=
set var_UsedFileSize=
set var_BakFileSize=
goto :EOF

rem ---------------------------------------------------------------------
:sub_CompareGameFileSize
if exist %1 set var_UsedFileSize=%~z1
call :sub_CheckBakFileSize backup\%1
goto :EOF

rem ---------------------------------------------------------------------
:sub_CheckBakFileSize
if exist %1 set var_BakFileSize=%~z1
if "%var_UsedFileSize%" == "%var_BakFileSize%" (
	set flag_BackupProbs=1
	del %1
)
goto :EOF

rem ---------------------------------------------------------------------
:sub_SyncBackupDir
if exist backup (
	if not exist backup\*.mpm (
		if not exist backup\*.ras (
			set flag_BackupProbs=1
			rd backup /s /q
		)
	)
)
goto :EOF

rem ---------------------------------------------------------------------
rem --- helper subs ---
rem ---------------------------------------------------------------------
:sub_Waitasec
timeout /t %1 >nul
goto :EOF

rem ---------------------------------------------------------------------
:sub_CreateShortcut
if not exist "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\MaxBatch.lnk" shortcut /f:"%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\MaxBatch.lnk" /a:c /i:"%cd%\maxpayne.exe",1 /t:"%cd%\MaxBatch.bat" /w:"%cd%" >nul
goto :EOF

rem ---------------------------------------------------------------------
rem --- goto routines ---
rem ---------------------------------------------------------------------
:lbl_ToggleDebug
if %var_Debug%==0 (
	set var_Debug=1
	goto :lbl_EndDebug
) 
if %var_Debug%==1 (
	set var_Debug=2
	goto :lbl_EndDebug
)
if %var_Debug%==2 (
	set var_Debug=0
	goto :lbl_EndDebug
) 
:lbl_EndDebug
goto :lbl_GameMenu

rem ---------------------------------------------------------------------
:lbl_LaunchGame
if %flag_GameExe% == 1 start /b maxpayne.exe
goto :lbl_Exit 

rem ---------------------------------------------------------------------
:lbl_Handle_Uac
call :msg_Welcome
color 4F
call :msg_AnalyseCurrent
call :msg_Elevate
set str_ElevName=%temp%\elevate.vbs
echo ' // Based on Elevation PowerToys for Windows Vista v1.1 (04/29/2008) > %str_ElevName%
echo ' // Adapted by Darkje for Max Payne Conversion Tool v0.3 >> %str_ElevName%
echo Set objShell = CreateObject("Shell.Application") >> %str_ElevName%
echo Set objWshShell = WScript.CreateObject("WScript.Shell") >> %str_ElevName%
echo Set objWshProcessEnv = objWshShell.Environment("PROCESS") >> %str_ElevName%
echo strDir = objWshProcessEnv("ELEVATE_DIR") >> %str_ElevName%
echo strApp = objWshProcessEnv("ELEVATE_APP") >> %str_ElevName%
echo objShell.ShellExecute "" ^& strApp, "" ^& strDir, "", "runas" >> %str_ElevName%
call :sub_Waitasec %var_ExitDelay%
set ELEVATE_APP=%~nx0
set ELEVATE_DIR=%cd%
start wscript //nologo "%str_ElevName%" %*
goto :lbl_Exit

rem ---------------------------------------------------------------------
:lbl_Exit
call :sub_CreateShortcut
echo.
call :msg_Done
call :sub_Waitasec %var_ExitDelay%
rem --- cleanup used vars ---
set var_File=
set var_ConvModCount=
set var_NewModCount=
set var_ExcludedModCount=
set var_TotModCount=
set var_Debug=
set var_ConversionDelay=
set var_ExitDelay=
set var_ActionFinishedDelay=
set var_DbgL2Delay=
set str_Title=
set flag_OnlyMods=
set flag_Uac=
set flag_AllFiles=
set flag_ConvData=
set flag_ScriptNeeds=
set flag_CanConvert=
set flag_GameExe=
set flag_LangFiles=
set flag_RunFiles=
set flag_FreshGame=
set flag_RasCheck=
exit 

rem ---------------------------------------------------------------------
rem --- dialog subs ---
rem ---------------------------------------------------------------------
:msg_Welcome
cls
Title %str_Title%
call :msg_HorLine
goto :EOF

rem ---------------------------------------------------------------------
:msg_GameConvScreen
echo                             Game Conversion Screen
goto :EOF

rem ---------------------------------------------------------------------
:msg_ModConvScreen
echo                             Mod Conversion Screen
goto :EOF

rem ---------------------------------------------------------------------
:msg_YouWantTo
call :msg_HorLine
if %var_Debug% == 0 (
	echo Main options:
) else (
	echo Main options ^(%1^):
)
goto :EOF

rem ---------------------------------------------------------------------
:msg_ModYouWantTo
call :msg_HorLine
if %var_Debug% == 0 (
	echo Main options:
) else (
	echo Main options ^(%1^):
)
goto :EOF

rem ---------------------------------------------------------------------
:msg_OtherOpt
echo.
echo Other options:
goto :EOF

rem ---------------------------------------------------------------------
:msg_HorLine
echo _______________________________________________________________________________
echo.
goto :EOF

rem ---------------------------------------------------------------------
rem --- game menu option messages ---
rem ---------------------------------------------------------------------
:msg_ConvGameOptOk
echo  [C] - Convert game.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvGameOptBad
echo  [C] - Convert game.                     [!] Option affected by problem^(s^).
goto :EOF

rem ---------------------------------------------------------------------
:msg_RestoreGameOpt
echo  [R] - Restore game to unconverted.
goto :EOF

rem ---------------------------------------------------------------------
:msg_LaunchOptOk
echo  [L] - Launch unconverted game.
goto :EOF

rem ---------------------------------------------------------------------
:msg_LaunchOptBad
echo  [L] - Launch unconverted game.             [!] Option affected by problem^(s^). 
goto :EOF

rem ---------------------------------------------------------------------
:msg_LaunchConvOptOk
echo  [L] - Launch converted game.
goto :EOF

rem ---------------------------------------------------------------------
:msg_LaunchConvOptBad
echo  [L] - Launch converted game.            [!] Option affected by problem^(s^). 
goto :EOF

rem ---------------------------------------------------------------------
:msg_ModOpt
echo  [M] - Mod Conversion Screen.
goto :EOF

rem ---------------------------------------------------------------------
:msg_DebugOpt
echo  [D] - Debug Level 0/1/2.
goto :EOF

rem ---------------------------------------------------------------------
:msg_StartOpt
echo  [S] - Start analysis again.
goto :EOF

rem ---------------------------------------------------------------------
:msg_EndOpt
echo  [E] - End.
echo.
goto :EOF

rem ---------------------------------------------------------------------
:msg_NoMainOpt
echo  [!] - No main options, No game, No mods. Can't do much...
goto :EOF

rem ---------------------------------------------------------------------
:msg_SdeOpt
rem --- option group sde ---
call :msg_StartOpt
call :msg_DebugOpt
call :msg_EndOpt
goto :EOF

rem ---------------------------------------------------------------------
:msg_LaunchOpt
if %flag_GameExe%==1 (
	call :msg_LaunchOptOk
) else (
	call :msg_LaunchOptBad
)
goto :EOF

rem ---------------------------------------------------------------------
:msg_LaunchConvOpt
if %flag_GameExe%==1 (
	call :msg_LaunchConvOptOk
) else (
	call :msg_LaunchConvOptBad
)
goto :EOF

rem ---------------------------------------------------------------------
:msg_GameConvOpt
if %flag_ConvData%==1 (
	if %flag_CanConvert%==1 call :msg_ConvGameOptOk
) else (
	call :msg_ConvGameOptBad
)
goto :EOF

rem ---------------------------------------------------------------------
rem --- mod menu option messages ---
rem ---------------------------------------------------------------------
:msg_ConvModsOptOk
echo  [M] - Convert new mod^(s^).
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvModsOptBad
echo  [M] - Convert new mod^(s^).                   [!] Option affected by problem^(s^).
goto :EOF

rem ---------------------------------------------------------------------
:msg_RestoreModOpt
echo  [R] - Restore converted mod^(s^) to unconverted.
goto :EOF

rem ---------------------------------------------------------------------
:msg_AddModExclOpt
echo  [A] - Add new mod^(s^) to exclusion list.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ClrModExclOpt
echo  [H] - Remove mod^(s^) from exclusion list.
goto :EOF

rem ---------------------------------------------------------------------
:msg_EndModOpt
call :msg_StartOpt
echo  [E] - End, back to Game Conversion Screen.
echo.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvModOpt
if %flag_CanConvert%==1 (
	call :msg_ConvModsOptOk
) else ( 
	call :msg_ConvModsOptBad
)
goto :EOF

rem ---------------------------------------------------------------------
rem --- Analisis status messages ---
rem ---------------------------------------------------------------------
:msg_AnalyseCurrent
echo Analysing current status:
goto :EOF

rem ---------------------------------------------------------------------
:msg_WorkDir
echo  + Work directory: %cd%.
goto :EOF

rem ---------------------------------------------------------------------
:msg_FreshGameFnd
echo  + Original, unconverted game found.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvGameFnd
echo  + Converted game found.
goto :EOF

rem ---------------------------------------------------------------------
:msg_NoValidGame
echo  + No valid game detected.
goto :EOF

rem ---------------------------------------------------------------------
:msg_TotMods
echo  + Mod^(s^) found. %var_TotModCount% in total.
goto :EOF

rem ---------------------------------------------------------------------
:msg_NewModFnd
echo  + New, unconverted mod^(s^) [%var_NewModCount%]:
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvModsFnd
echo  + Converted mod^(s^) [%var_ConvModCount%]:
goto :EOF

rem ---------------------------------------------------------------------
:msg_ExcludedModsFnd
echo  + Excluded mod^(s^) [%var_ExcludedModCount%]:
goto :EOF

rem ---------------------------------------------------------------------
:msg_NoProbsMods
echo  + Mod^(s^) and script needs detected, Mod conversion can proceed.
goto :EOF

rem ---------------------------------------------------------------------
:msg_NoModsFnd
echo  + No Mod^(s^) found.
goto :EOF

rem ---------------------------------------------------------------------
:msg_BackupsSynced
echo  + Patch backup synchronization issue repaired.
goto :EOF

rem ---------------------------------------------------------------------
:msg_TmpCleared
echo  + A temporary directory was found and cleared.
goto :EOF

rem ---------------------------------------------------------------------
:msg_PosProbs
echo  + File scan shows:
echo    - Possible problem(s) detected, use debug level 1 for more info.
goto :EOF

rem ---------------------------------------------------------------------
:msg_TmpProb
echo  + Problem Detected! Can't delete tmp dir, file in use. Any key to retry.
goto :EOF

rem ---------------------------------------------------------------------
rem --- Work progress messages ---
rem ---------------------------------------------------------------------
:msg_StartConvGame
echo.
echo -^> Starting game conversion phase: converting three files ...
goto :EOF

rem ---------------------------------------------------------------------
:msg_GameConvDone
echo -^> Game conversion phase finished.
goto :EOF

rem ---------------------------------------------------------------------
:msg_StartConvMod
echo.
echo -^> Starting new mod conversion phase ...
goto :EOF

rem ---------------------------------------------------------------------
:msg_ModConvDone
echo -^> Mod Conversion phase finished.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvFileSizeBad
echo -^> File %~1 converted but resulting size not as expected.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvFileOk
echo -^> File %~1 converted.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvFileBad
if %var_Debug% == 0 echo -^> File %~1 NOT converted, added to exclude list.
call :msg_LogExcludedFile %1
goto :EOF

rem ---------------------------------------------------------------------
:msg_LogExcludedFile
echo MaxBatch: Excluded %~1 from conversion. > "convexcl\%~n1.log"
goto :EOF

rem ---------------------------------------------------------------------
:msg_ExcludeRemove
echo -^> Removing %~1 from exclusions.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ExcludeListRemoved
echo -^> Exclusion list removed.
goto :EOF

rem ---------------------------------------------------------------------
:msg_FileExclude
echo -^> Adding %~1 to exclusions.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvFile
echo echo -^> Converting file %~1.
goto :EOF

rem ---------------------------------------------------------------------
:msg_FileNotFound
echo -^> File %~1 not found!
goto :EOF

rem ---------------------------------------------------------------------
:msg_NoAction
echo -^> No action taken.
goto :EOF

rem ---------------------------------------------------------------------
:msg_TypeFileName
echo -^> Type a file name (no extension, enter to skip, * for all)
goto :EOF

rem ---------------------------------------------------------------------
:msg_StartRestore
echo.
echo -^> Starting restore phase ...
goto :EOF

rem ---------------------------------------------------------------------
:msg_RestoreDone
echo -^> Restore phase finished.
goto :EOF

rem ---------------------------------------------------------------------
:msg_StartAddExclusion
echo.
echo -^> Starting add exclusions phase ...
goto :EOF

rem ---------------------------------------------------------------------
:msg_StartDelExclusion
echo.
echo -^> Starting remove exclusions phase ...
goto :EOF

rem ---------------------------------------------------------------------
:msg_ExclusionDone
echo -^> Modify exclusions phase finished.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ExclRestored
echo -^> Exclusion^(s^) removed.
goto :EOF

rem ---------------------------------------------------------------------
:msg_FileRestored
echo -^> File %~1 restored.
goto :EOF

rem ---------------------------------------------------------------------
:msg_Done
echo -^> Max Payne Conversion Script is done!
echo -^> Run it again for other options.
goto :EOF

rem ---------------------------------------------------------------------
:msg_Elevate
echo -^> UAC restrictions detected, restarting at administrator level.
goto :EOF

rem ---------------------------------------------------------------------
:msg_FileSizeGood
echo -^> Size of converted files okay! 
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvFailed
echo -^> Conversion of one or more files failed, restoring backups!
goto :EOF

rem ---------------------------------------------------------------------
rem --- Debug messages ---
rem ---------------------------------------------------------------------
:msg_CheckConvDbg
echo -^> Checking result of conversion.
goto :EOF

rem ---------------------------------------------------------------------
:msg_BadConvEqualDbg
echo -^> Converted file same size as unconverted file, conversion not needed.
goto :EOF

rem ---------------------------------------------------------------------
:msg_BadConvZeroDbg
echo -^> Converted file zero bytes size, that can't be right.
goto :EOF

rem ---------------------------------------------------------------------
:msg_BackupRestDbg
echo -^> Conversion of %1 failed, restoring original. 
echo -^> %1 logged in exclusion list.
goto :EOF

rem ---------------------------------------------------------------------
:msg_DebugStat
echo  + Debug Level=%var_Debug%.
call :sub_Waitasec %var_ExitDelay%
goto :EOF

rem ---------------------------------------------------------------------
:msg_LangFndDbg
echo    - Language file found: %1.
goto :EOF

rem ---------------------------------------------------------------------
:msg_RestoreDbg
echo -^> Restoring backup files.
goto :EOF

rem ---------------------------------------------------------------------
:msg_LangBadDbg
echo    + Language file missing.
goto :EOF

rem ---------------------------------------------------------------------
:msg_StartConvfileDbg
echo -^> Starting conversion of file %1
echo -^> Creating backup of %1
goto :EOF

rem ---------------------------------------------------------------------
:msg_ExtractDbg
echo -^> Extracting %1 to tmp.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvertDbg
echo -^> Converting tmp files with SoX.
goto :EOF

rem ---------------------------------------------------------------------
:msg_PackDbg
echo -^> Repacking tmp files to %1.
goto :EOF

rem ---------------------------------------------------------------------
:msg_DeltmpDbg
echo -^> Deleting tmp files.
goto :EOF

rem ---------------------------------------------------------------------
:msg_FiledoneDbg
echo -^> File %1 done.
echo.
goto :EOF

rem ---------------------------------------------------------------------
:msg_FilesdetectedDbg
echo  + File scan shows:
goto :EOF

rem ---------------------------------------------------------------------
:msg_ScriptNeedFndDbg
echo    - Files needed by script found.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ScriptNeedBadDbg
echo    + File(s) needed by script missing:
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvDataFndDbg
echo    - Target files for game conversion found.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ConvDataBadDbg
echo    + Target file(s) for game conversion missing:
goto :EOF

rem ---------------------------------------------------------------------
:msg_GameExeFndDbg
echo    - MaxPayne.exe found, Launch option will attempt launch.
goto :EOF

rem ---------------------------------------------------------------------
:msg_GameExeBadDbg
echo    + MaxPayne.exe missing.
goto :EOF

rem ---------------------------------------------------------------------
:msg_AdtlFndDbg
echo    - All files required to run the game found.
goto :EOF

rem ---------------------------------------------------------------------
:msg_AdtlBadDbg
echo    + Some file(s) required to run the standard game missing:
goto :EOF

rem ---------------------------------------------------------------------
:msg_BackupFndDbg
echo    - Backup detected.
goto :EOF

rem ---------------------------------------------------------------------
:msg_NoProbsDbg
echo  + No missing file problems detected, OK!.
goto :EOF

rem ---------------------------------------------------------------------
:msg_NoProbsModsDbg
echo  + Crucial game files missing, but mod conversion can proceed.
goto :EOF

rem ---------------------------------------------------------------------
:msg_ProbsDbg
echo  + This looks Bad! Possible problem(s) detected.
goto :EOF

rem ---------------------------------------------------------------------
:msg_DelbakDbg
echo -^> Deleting old backup files.
goto :EOF

rem ---------------------------------------------------------------------
:msg_LineDbg
echo --------------------------------------------------------------------
goto :EOF

rem --------------------- missing file messages -------------------------
:msg_Miss
echo      - %1
goto :EOF

rem --------------------- large status messages -------------------------
:msg_working
rem cls
echo.
echo  л     л  ллллл  лллллл  л     л ллллл л     л  ллллл
echo  л     л л     л л     л л    л    л   лл    л л     л
echo  л     л л     л л     л л   л     л   л л   л л
echo  л     л л     л лллллл  лллл      л   л  л  л л
echo  л  л  л л     л л   л   л   л     л   л   л л л    лл
echo  л л л л л     л л    л  л    л    л   л    лл л     л  лл  лл  лл
echo   л   л   ллллл  л     л л     л ллллл л     л  ллллл   лл  лл  лл
echo.
echo                      *** PLEASE WAIT ***
goto :EOF

:msg_finished
rem cls
echo.
echo  ллллллл ллллл л     л ллллл  ллллл  л     л ллллллл ллллл     л
echo  л         л   лл    л   л   л     л л     л л       л    л   ллл
echo  л         л   л л   л   л   л       л     л л       л     л  ллл
echo  лллл      л   л  л  л   л    ллллл  ллллллл лллл    л     л   л
echo  л         л   л   л л   л         л л     л л       л     л   л
echo  л         л   л    лл   л   л     л л     л л       л    л 
echo  л       ллллл л     л ллллл  ллллл  л     л ллллллл ллллл     л
echo.
echo                    *** ANY KEY TO CONTINUE ***
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
pause >nul
goto :EOF
