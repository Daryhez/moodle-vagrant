@ECHO OFF

IF NOT EXIST "%MOODLE_DOCKER_WWWROOT%" (
    ECHO Error: MOODLE_DOCKER_WWWROOT is not set or not an existing directory
    EXIT /B 1
)

IF "%MOODLE_DOCKER_DB%"=="" (
    ECHO Error: MOODLE_DOCKER_DB is not set
    EXIT /B 1
)

PUSHD %cd%
CD %~dp0..
SET BASEDIR=%cd%
POPD
SET ASSETDIR=%BASEDIR%\assets

SET COMPOSE_CONVERT_WINDOWS_PATHS=true

SET DOCKERCOMPOSE=docker-compose -f "%BASEDIR%\base.yml"
SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%BASEDIR%\service.mail.yml"

IF "%MOODLE_DOCKER_PHP_VERSION%"=="" (
    SET MOODLE_DOCKER_PHP_VERSION=7.3
)

IF NOT "%MOODLE_DOCKER_DB%"=="pgsql" (
    SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%BASEDIR%\db.%MOODLE_DOCKER_DB%.yml"
)

SET filename=%BASEDIR%\db.%MOODLE_DOCKER_DB%.%MOODLE_DOCKER_PHP_VERSION%.yml
if exist %filename% (
    SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%filename%"
)

IF NOT "%MOODLE_APP_VERSION%"=="" (
    ECHO Warning: MOODLE_APP_VERSION is deprecated, use MOODLE_DOCKER_APP_VERSION instead

    IF "%MOODLE_DOCKER_APP_VERSION%"=="" (
        SET MOODLE_DOCKER_APP_VERSION=%MOODLE_APP_VERSION%
    )
)

IF "%MOODLE_DOCKER_APP_RUNTIME%"=="" (
    SET MOODLE_DOCKER_APP_RUNTIME=ionic5
)

IF "%MOODLE_DOCKER_BROWSER%"=="chrome" (
    IF NOT "%MOODLE_DOCKER_APP_PATH%"=="" (
        SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%BASEDIR%\moodle-app-dev-%MOODLE_DOCKER_APP_RUNTIME%.yml"
    ) ELSE IF NOT "%MOODLE_DOCKER_APP_VERSION%"=="" (
        SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%BASEDIR%\moodle-app-%MOODLE_DOCKER_APP_RUNTIME%.yml"
    )
)

IF NOT "%MOODLE_DOCKER_BROWSER%"=="" (
    IF NOT "%MOODLE_DOCKER_BROWSER%"=="firefox" (
        SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%BASEDIR%\selenium.%MOODLE_DOCKER_BROWSER%.yml"
    )
)

IF NOT "%MOODLE_DOCKER_PHPUNIT_EXTERNAL_SERVICES%"=="" (
    SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%BASEDIR%\phpunit-external-services.yml"
)

IF "%MOODLE_DOCKER_WEB_HOST%"=="" (
    SET MOODLE_DOCKER_WEB_HOST=localhost
)

IF "%MOODLE_DOCKER_WEB_PORT%"=="" (
    SET MOODLE_DOCKER_WEB_PORT=8000
)

SET "TRUE="
IF NOT "%MOODLE_DOCKER_WEB_PORT%"=="%MOODLE_DOCKER_WEB_PORT::=%" SET TRUE=1
IF NOT "%MOODLE_DOCKER_WEB_PORT%"=="0" SET TRUE=1
IF DEFINED TRUE (
    REM If no bind ip has been configured (bind_ip:port), default to 127.0.0.1
    IF "%MOODLE_DOCKER_WEB_PORT%"=="%MOODLE_DOCKER_WEB_PORT::=%" (
        SET MOODLE_DOCKER_WEB_PORT=127.0.0.1:%MOODLE_DOCKER_WEB_PORT%
    )
    SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%BASEDIR%\webserver.port.yml"
)

IF "%MOODLE_DOCKER_SELENIUM_VNC_PORT%"=="" (
    SET MOODLE_DOCKER_SELENIUM_SUFFIX=
) ELSE (
    SET "TRUE="
    IF NOT "%MOODLE_DOCKER_SELENIUM_VNC_PORT%"=="%MOODLE_DOCKER_SELENIUM_VNC_PORT::=%" SET TRUE=1
    IF NOT "%MOODLE_DOCKER_SELENIUM_VNC_PORT%"=="0" SET TRUE=1
    IF DEFINED TRUE (
        SET MOODLE_DOCKER_SELENIUM_SUFFIX=-debug
        SET DOCKERCOMPOSE=%DOCKERCOMPOSE% -f "%BASEDIR%\selenium.debug.yml"
        REM If no bind ip has been configured (bind_ip:port), default to 127.0.0.1
        IF "%MOODLE_DOCKER_SELENIUM_VNC_PORT%"=="%MOODLE_DOCKER_SELENIUM_VNC_PORT::=%" (
            SET MOODLE_DOCKER_SELENIUM_VNC_PORT=127.0.0.1:%MOODLE_DOCKER_SELENIUM_VNC_PORT%
        )
    )
)

%DOCKERCOMPOSE% %*
