call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
%bindir%\dub test -a x86_64
%bindir%\dub build -a x86_64
