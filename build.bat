@echo off
rem Basic build script for Subtitle Dumper
rem Requires MSBuild 15 with C# 7.0 compatible compiler
rem NOTE: PLACE THE NEEDED ASSEMBLIES INTO "Libs" FOLDER
rem You may specify the build configuration as an argument to this batch
rem If no arguments are specified, will build the Release version

rem SOLUTION-SPECIFIC VARIABLES:

set subdump=CM3D2.SubtitleDumper

rem SOLUTION-SPECIFIC VARIABLES END

echo Locating MSBuild

set libspath=%cd%\Libs
set buildconf=Release
set buildplat=AnyCPU
set vswhere="%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

for /f "usebackq tokens=*" %%i in (`%vswhere% -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
	set InstallDir=%%i
)

set msbuild="%InstallDir%\MSBuild\15.0\Bin\MSBuild.exe"

if not exist %msbuild% (
	echo Failed to locate MSBuild.exe
	echo This project uses MSBuild 15 to compile
	pause
	exit /b 1
)

if not -%1-==-- (
	echo Using %1 as building configuration
	set buildconf=%1
)
if -%1-==-- (
	echo No custom build configuration specified. Using Release
)

if not -%2-==-- (
	echo Using %2 as building platform
	set buildplat=%2
)
if -%2-==-- (
	echo No custom platform specified. Using AnyCPU
)

if not [%subdump%] == [] (
	rmdir /Q /S "%cd%\%subdump%\bin\%buildconf%" >NUL
	rmdir /Q /S "%cd%\%subdump%\obj" >NUL

	%msbuild% "%cd%\%subdump%\%subdump%.csproj" /p:Configuration=%buildconf%,Platform=%buildplat%

	if not %ERRORLEVEL%==0 (
		echo Failed to compile Subtitle dumper!
	)
)

mkdir Build
move /Y "%cd%\%subdump%\bin\%buildconf%\*" "%cd%\Build"

echo All done!
pause