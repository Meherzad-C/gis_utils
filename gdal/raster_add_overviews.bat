@echo off
SETLOCAL ENABLEEXTENSIONS

:: ==============================
:: Information Block
:: ==============================
IF "%1"=="info" (
    echo.
    echo ===========================================
    echo GDAL Raster Overview Creation Script
    echo ===========================================
    echo.
    echo Description:
    echo    This script adds resampled versions of overviews to a raster file using the GDAL tool 'gdaladdo'.
    echo    Overviews are useful for improving performance when displaying large raster datasets.
    echo.
    echo Prerequisites:
    echo    - GDAL should be installed and available in your system's PATH.
    echo    - A valid input raster file is required.
    echo.
    echo How to Use:
    echo    raster_add_overviews.bat input.tif [resampling_method] [overview_levels]
    echo.
    echo Example:
    echo    raster_add_overviews.bat input.tif bilinear 2 4 8 16
    echo    If resampling_method is not specified, 'nearest' will be used by default
    echo.
    echo Author: Meherzad Chinoy
    echo ===========================================
    exit /b 0
)

:: Check for correct number of arguments 
IF "%~1"=="" (
    echo ERROR: Missing arguments. Usage: raster_add_overviews.bat input.tif
    echo For detailed information, use "raster_add_overviews.bat info".
    exit /b 1
)

:: Get the first argument (input raster)
SET INPUT_RASTER=%~1

:: Check if the input raster exists
IF NOT EXIST "%INPUT_RASTER%" (
    echo ERROR: Input raster "%INPUT_RASTER%" not found!
    exit /b 2
)

:: Set default values for resampling method and overview levels
SET RESAMPLING_METHOD=nearest
SET OVERVIEW_LEVELS=

:: Parse the second argument (resampling method) if provided
IF NOT "%~2"=="" (
    SET RESAMPLING_METHOD=%~2
    SHIFT
)

:: Collect the remaining arguments as overview levels
SET OVERVIEW_LEVELS=%*

:: If no overview levels are provided, set default levels
IF "%OVERVIEW_LEVELS%"=="" (
    echo No overview levels provided, using default: 2 4 8 16
    SET OVERVIEW_LEVELS=2 4 8 16
)

:: ======================
:: PHASE 1: Run gdaladdo
:: ======================
echo.
echo ----------------------------------------------------------------
echo Phase 1: Running gdaladdo with %RESAMPLING_METHOD% resampling
echo ----------------------------------------------------------------

:: Run gdaladdo to add overviews with the specified resampling method and BigTIFF option
gdaladdo -r %RESAMPLING_METHOD% --config BIGTIFF_OVERVIEW=YES %INPUT_RASTER% %OVERVIEW_LEVELS%
IF ERRORLEVEL 1 (
    echo ERROR: gdaladdo failed!
    exit /b 3
)

echo gdaladdo completed successfully.
echo.

:: =======================
:: Final Message
:: =======================
echo ----------------------------------------------------------------
echo Process completed successfully.
echo ----------------------------------------------------------------
echo.

ENDLOCAL
exit /b 0