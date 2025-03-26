@echo off
SETLOCAL ENABLEEXTENSIONS

:: ==============================
:: Information Block
:: ==============================
IF "%1"=="info" (
    echo.
    echo ============================================
    echo GDAL Raster Cropping and Compression Script
    echo ============================================
    echo.
    echo Description:
    echo    This script crops a raster file using a shapefile, applies LZW compression, 
    echo    and optionally supports BigTIFF for large files, using GDAL tools.
    echo.
    echo Prerequisites:
    echo    - GDAL should be installed and available in your system's PATH.
    echo    - A valid input raster and shapefile are required.
    echo.
    echo How to Use:
    echo    raster_clip_by_mask_layer.bat input.tif shapefile.shp output.tif
    echo.
    echo Author: Meherzad Chinoy
    echo ==========================================
    exit /b 0
)

:: Check for correct number of arguments
IF "%~3"=="" (
    echo ERROR: Missing arguments. Usage: raster_clip_by_mask_layer.bat input.tif shape.shp output.tif
    echo For detailed information, use "raster_clip_by_mask_layer.bat info".
    exit /b 1
)

:: Get arguments
SET INPUT_RASTER=%~1
SET SHAPEFILE=%~2
SET OUTPUT_RASTER=%~3
SET TMP_VRT=tmp_output.vrt

:: Check if input raster exists
IF NOT EXIST "%INPUT_RASTER%" (
    echo ERROR: Input raster "%INPUT_RASTER%" not found!
    exit /b 2
)

:: Check if shapefile exists
IF NOT EXIST "%SHAPEFILE%" (
    echo ERROR: Shapefile "%SHAPEFILE%" not found!
    exit /b 3
)

:: ======================
:: PHASE 1: Run gdalwarp
:: ======================
echo.
echo --------------------------------
echo Phase 1: Running gdalwarp
echo --------------------------------

:: Run gdalwarp to crop the raster using the shapefile
gdalwarp -of vrt -cutline "%SHAPEFILE%" -crop_to_cutline -dstnodata 0.0 "%INPUT_RASTER%" "%TMP_VRT%"
IF ERRORLEVEL 1 (
    echo ERROR: gdalwarp failed!
    exit /b 4
)

echo gdalwarp completed successfully.
echo.

:: =============================
:: PHASE 2: Run gdal_translate
:: =============================
echo --------------------------------
echo Phase 2: Running gdal_translate
echo --------------------------------

:: Run gdal_translate to apply compression and additional options
gdal_translate -co compress=LZW -co BIGTIFF=YES -co NUM_THREADS=ALL_CPUS "%TMP_VRT%" "%OUTPUT_RASTER%"
IF ERRORLEVEL 1 (
    echo ERROR: gdal_translate failed!
    exit /b 5
)

echo gdal_translate completed successfully.
echo.

:: ===========================
:: PHASE 3: Clean up VRT file
:: ===========================
echo --------------------------------
echo Phase 3: Cleaning up VRT file
echo --------------------------------

:: Delete temporary VRT file
del "%TMP_VRT%"
IF ERRORLEVEL 1 (
    echo WARNING: Failed to delete temporary VRT file "%TMP_VRT%"!
)

echo Temporary VRT file deleted successfully.
echo.

:: =======================
:: Final Message
:: =======================
echo --------------------------------
echo Process completed successfully.
echo --------------------------------
echo.

ENDLOCAL
exit /b 0
