@echo off

:init
    set "__script_name=%~n0"
    set "__script_version=1.0"

    set "__script_file=%~0"
    set "__script_path=%~dp0"

    set "__opt_help="
    set "__opt_version="
    set "__opt_verbose="
    set "__path_cd=%cd%"
    set "PROJECT_NAME=%__script_path%"
    set "__scripts_root=%AutomationScriptsRoot%"
    call :read_script_root development\build-automation BuildAutomation
    echo Read scripts root from registry: %__scripts_root%

    set "__iniconfig_file="
    set "__log_path=%__script_path%log"
    set __log_file=""
    
    set "__lib_out=%__scripts_root%\batlibs\out.bat"
    set "__lib_date=%__scripts_root%\batlibs\date.bat"
    goto :config_compiler


:config_compiler
    set defines=-D_USING_V110_SDK71_ -DSUBSYSTEM_CONSOLE -DDEBUG_OUTPUT
    set link_options=/link /FILEALIGN:512 /OPT:REF /OPT:ICF /INCREMENTAL:NO /subsystem:console,5.01
    set libs=gdiplus.lib user32.lib Gdi32.lib ws2_32.lib Wininet.lib
    goto :prebuild_header




:prebuild_header
   call %__lib_date% :getbuilddate
   call %__lib_out% :__out_d_red " ======================================================================="
   call %__lib_out% :__out_l_red " Compilation started for %PROJECT_NAME%"
   call %__lib_out% :__out_d_yel " Date : %__build_date%"
   call %__lib_out% :__out_d_blu " Libs: %libs%"
   call %__lib_out% :__out_d_red " ======================================================================="
   goto :build


:build
   if not exist bin ( mkdir bin )
   cl /Ox main.c %defines% %link_options% %libs% /out:bin\main.exe
   del /F /Q *.obj
   if %errorlevel% neq 0 (
       call :error_build_failed %errorlevel%
       goto :end
    )
    goto :build_success

:clean
    echo cleaning
    rmdir /s /q bin
    goto :eof


:error_build_failed
    echo.
    call %__lib_out% :__out_l_red "   Error"
    call %__lib_out% :__out_d_yel "   Build failure: %~1"
    echo.
    goto :eof


:build_success
    echo.
    call %__lib_out% :__out_l_grn "   Build successfully completed!"
    echo.
    goto :eof



:read_script_root
    set regpath=%OrganizationHKCU::=%
    for /f "tokens=2,*" %%A in ('REG.exe query %regpath%\%1 /v %2') do (
            set "__scripts_root=%%B"
        )
    goto :eof


:end
    call %__lib_out% :__out_d_yel "End"
    goto :eof