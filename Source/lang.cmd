@echo off

rem ���� ����� ���������� �����
rem http://msdn.microsoft.com/en-us/library/windows/desktop/dd318693%28v=vs.85%29.aspx
rem brcc32 �� ����� ������������� ������� � ��������� LANGUAGE, ������� ���������� rc.exe ��  Microsoft SDK
rem brcc32 MGLangStr.rc -foMGLangStr.res
"C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Bin\rc.exe" MGLangStrGoogle.rc
"C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Bin\rc.exe" MGLangStrYandex.rc
