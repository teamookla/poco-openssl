
:platform
if /i "%JENKINS_PLATFORM%" == "win32" goto x86
if /i "%JENKINS_PLATFORM%" == "win64" goto x64

:x86
set platform=x86
goto check_vs_install_dir
:x64
set platform=x64
goto check_vs_install_dir

:check_vs_install_dir
if not "%VSINSTALLDIR%"=="" (
   set "VSDIR=%VSINSTALLDIR%\VC\"
   goto vs_install_dir_defined
)

:define_vs_install_dir
if not defined VS_VERSION (
  set VS_VERSION=vs140
)
if %VS_VERSION%==vs90 (
  set VS_VERSION_NUMBER=90
  set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio 2008\VC\"
) else if %VS_VERSION%==vs100 (
  set VS_VERSION_NUMBER=100
  set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio 2010\VC\"
) else if %VS_VERSION%==vs110 (
  set VS_VERSION_NUMBER=110
  set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio 2012\VC\"
) else if %VS_VERSION%==vs120 (
  set VS_VERSION_NUMBER=120
  set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio 2013\VC\"
) else if %VS_VERSION%==vs140 (
  set VS_VERSION_NUMBER=140
  if exist "C:\Program Files (x86)\Microsoft Visual Studio 14.0\" (
    set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\"
  ) else (
    set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio 2015\VC\"
  )
) else if %VS_VERSION%==vs150 (
  set VS_VERSION_NUMBER=150
  set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio 2017\\VC\"
) else if %VS_VERSION%==vs150c (
  set VS_VERSION_NUMBER=150
  set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\"
) else if %VS_VERSION%==vs150sa (
   set VS_VERSION_NUMBER=150
   set "VSDIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\"
 )

if not defined VSDIR (
  echo Error: No Visual C++ environment found.
  echo Please run this script from a Visual Studio Command Prompt
  echo or run "%%VSnnCOMNTOOLS%%\VC\vcvarsall.bat" first.
  exit /b 1
)

:vs_install_dir_defined

call "%VSDIR%vcvarsall.bat" %platform%
set PATH=c:\\Strawberry\\perl\\bin;%PATH%
set __CNF_CXXFLAGS=/FS
set __CNF_CFLAGS=/FS
perl Configure no-shared no-tests no-ui-console no-unit-test --prefix=C:\\OpenSSL --openssldir=C:\\OpenSSL\\ssl ${definition.perlPlatform}
set DESTDIR=${OPENSSL}
jom
nmake clean
nmake
nmake test
nmake install


