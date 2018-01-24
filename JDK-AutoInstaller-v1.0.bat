@echo off
color 0a
MODE con: COLS=45 LINES=13
title JDK-AutoInstaller-v1.0
::https://github.com/KingFalse/JDK-AutoInstaller
CLS
ECHO ============================================
ECHO 作者：鹞之神乐        http://kagura.me
ECHO ============================================
:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion
:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )
:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO *******************************************
ECHO 请求 UAC 权限批准……
ECHO *******************************************
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B
:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     以下为执行JDK安装操作的主要代码     ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF EXIST %ProgramData%\Oracle\Java\java.settings.cfg (del /s /f /q %ProgramData%\Oracle\Java\java.settings.cfg>nul)
IF EXIST "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg" (del /s /f /q "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg">nul)
IF EXIST "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg" (del /s /f /q "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg">nul)

set "basepath="%~dp0""
::检测32位JDK安装包
for /R %basepath% %%s in (jdk-*-i586.exe) do (
echo 检测到32位JDK
set "exe=%%~ns"
if /i "%processor_architecture%"=="x86" (
set "jdkpath=%ProgramFiles%\Java\jdk" 
set "jrepath=%ProgramFiles%\Java\jre"
) else (
set "jdkpath=%SystemDrive%\PROGRA~2\Java\jdk" 
set "jrepath=%SystemDrive%\PROGRA~2\Java\jre"
)
goto end
)

::检测64位JDK安装包
for /R %basepath% %%s in (jdk-*-x64*.exe) do (
echo 检测到64位JDK
set exe=%%~ns
if /i "%processor_architecture%"=="x86" (
echo 32位系统无法安装64位jdk
echo 任意键打开Oracle JDK下载页面...
@pause>nul
start http://www.oracle.com/technetwork/java/javase/downloads/index.html
exit
) else (
set "jdkpath=%ProgramFiles%\Java\jdk" 
set "jrepath=%ProgramFiles%\Java\jre"
)
goto end
)
echo 当前路径下未检测到JDK安装包!
echo 任意键打开Oracle JDK下载页面...
@pause>nul
start http://www.oracle.com/technetwork/java/javase/downloads/index.html
exit


:end
set "absjdkpath=" 
set "absjrepath=" 
if "" neq "%absjdkpath%" (set jdkpath=%absjdkpath%)
if "" neq "%absjrepath%" (set jrepath=%absjrepath%)
::判断是否有路径参数 根据参数设置路径
if "" neq "%1" (set jdkpath=%1)
if "" neq "%2" (set jrepath=%2)
echo JDK安装位置:%jdkpath:PROGRA~2=ProgramFiles(x86)%
echo JRE安装位置:%jrepath:PROGRA~2=ProgramFiles(x86)%
echo 正在安装...
::写入用于JDK安装的配置文件并使用配置文件启动
echo AUTO_UPDATE=Disable>%tmp%\java.settings.cfg
echo INSTALL_SILENT=Enable>>%tmp%\java.settings.cfg
echo INSTALLDIR=%jdkpath%>>%tmp%\java.settings.cfg
start %exe% installcfg=%tmp%\java.settings.cfg


::此循环用于检测java.settings.cfg是否存在，如果存在则覆写文件内容，用于安装JRE
:loop
IF EXIST %ProgramData%\Oracle\Java\java.settings.cfg (
echo AUTO_UPDATE=Disable>"%ProgramData%\Oracle\Java\java.settings.cfg"
echo INSTALL_SILENT=Enable>>"%ProgramData%\Oracle\Java\java.settings.cfg"
echo INSTALLDIR=%jrepath%>>"%ProgramData%\Oracle\Java\java.settings.cfg"
call :wait %exe%
)
IF EXIST "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg" (
echo AUTO_UPDATE=Disable>"%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg"
echo INSTALL_SILENT=Enable>>"%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg"
echo INSTALLDIR=%jrepath%>>"%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg"
call :wait %exe%
)
IF EXIST "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg" (
echo AUTO_UPDATE=Disable>"%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg"
echo INSTALL_SILENT=Enable>>"%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg"
echo INSTALLDIR=%jrepath%>>"%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg"
call :wait %exe%
)
choice /t 1 /d y /n >nul
goto loop


::此循环用于等待安装进程结束
:wait
tasklist|find /i "%exe%">nul
if ERRORLEVEL 1 (
goto env
) else (
choice /t 1 /d y /n >nul
goto wait
)


:env
echo 正在配置环境变量...
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v JAVA_HOME /t REG_SZ /d "%jdkpath%" /f>nul
for /f "tokens=3" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "Path"') do Set aa=%%a
if "%aa:;%JAVA_HOME%\bin;=%"=="%aa%" (
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%aa%;%%JAVA_HOME%%\bin;" /f>nul
)
IF EXIST %ProgramData%\Oracle\Java\java.settings.cfg (del /s /f /q %ProgramData%\Oracle\Java\java.settings.cfg>nul)
IF EXIST "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg" (del /s /f /q "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg">nul)
IF EXIST "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg" (del /s /f /q "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg">nul)
echo 安装完成!请重新启动计算机以应用环境变量更改
echo 按任意键重启...
@pause>nul
shutdown -r -t 0
exit

