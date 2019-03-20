#include "../sdk/7z.h"
#include "../sdk/7zFile.h"
#include "../sdk/7zAlloc.h"
#include "../sdk/7zBuf.h"
#include "../sdk/7zCrc.h"

#include <stdio.h>
#include <string.h>
#include <shlobj_core.h>


#define USE_WINDOWS_FILE

enum { kInputBufSize = ((size_t)1 << 18) };
static const ISzAlloc g_Alloc = { SzAlloc, SzFree };

// archive: utf-8 encoded path to the archive, can be both relative and absolute
// dest: utf-8 encoded path to the destination folder, must be absolute
int extract(const char* archive, const char* dest)
{
    if ((archive == NULL) || (dest == NULL))
        return -1;
    
    CFileInStream archiveStream;
    CLookToRead2 lookStream;

    if (InFile_Open(&archiveStream.file, archive))
    {
        printf("Can't open input file (%s)\n", archive);
        return -1;
    }

    FileInStream_CreateVTable(&archiveStream);
    LookToRead2_CreateVTable(&lookStream, False);
    lookStream.buf = NULL;

    ISzAlloc allocImp = g_Alloc;
    ISzAlloc allocTempImp = g_Alloc;

    {
        lookStream.buf = (Byte*) ISzAlloc_Alloc(&allocImp, kInputBufSize);
        if (!lookStream.buf)
        {
            printf("Failed to allocate memory for resource\n");
            return -1;
        }
        else
        {
            lookStream.bufSize = kInputBufSize;
            lookStream.realStream = &archiveStream.vt;
            LookToRead2_Init(&lookStream);
        }
    }

    CrcGenerateTable();

    CSzArEx db;
    SzArEx_Init(&db);

    SRes res = SzArEx_Open(&db, &lookStream.vt, &allocImp, &allocTempImp);
    if (res != SZ_OK)
    {
        printf("Failed to allocate memory for resource\n");
        return -1;
    }

    UInt32 i;
    size_t tempSize = 0;
    UInt16 *temp = NULL;
    UInt32 blockIndex = 0xFFFFFFFF; /* it can have any value before first call (if outBuffer = 0) */
    Byte *outBuffer = 0; /* it must be 0 before first call for each new archive. */
    size_t outBufferSize = 0;  /* it can have any value before first call (if outBuffer = 0) */

    UInt16 old_dir[MAX_PATH];
    GetCurrentDirectoryW(MAX_PATH, old_dir);
    UInt16 new_dir[MAX_PATH];
    MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, dest, -1, new_dir, MAX_PATH);
    if (SHCreateDirectoryExW(0, new_dir, NULL) != ERROR_SUCCESS)
        printf("Failed to create new dir (%ls)\n", new_dir);
    if (!SetCurrentDirectoryW(new_dir))
        printf("Failed to set new dir (%ls)\n", new_dir);

    for (i = 0; i < db.NumFiles; i++)
    {
        size_t offset = 0;
        size_t outSizeProcessed = 0;
        size_t len;
        unsigned isDir = SzArEx_IsDir(&db, i);
        len = SzArEx_GetFileNameUtf16(&db, i, NULL);

        if (len > tempSize)
        {
            SzFree(NULL, temp);
            tempSize = len;
            temp = (UInt16 *)SzAlloc(NULL, tempSize * sizeof(temp[0]));

            if (!temp)
            {
                res = SZ_ERROR_MEM;
                break;
            }
        }

        SzArEx_GetFileNameUtf16(&db, i, temp);

        if (!isDir)
        {
            res = SzArEx_Extract(&db, &lookStream.vt, i,
                &blockIndex, &outBuffer, &outBufferSize,
                &offset, &outSizeProcessed,
                &allocImp, &allocTempImp);
            if (res != SZ_OK)
                break;
        }

        CSzFile outFile;
        size_t processedSize;
        size_t j;
        UInt16 *name = temp;
        const UInt16 *destPath = (const UInt16 *)name;

        for (j = 0; name[j] != 0; j++)
        {
            if (name[j] == '/')
            {
                name[j] = 0;
                CreateDirectoryW((LPCWSTR)name, NULL);
                name[j] = CHAR_PATH_SEPARATOR;
            }
        }

        if (isDir)
        {
            CreateDirectoryW((LPCWSTR)destPath, NULL);
            continue;
        }
        else if (OutFile_OpenW(&outFile, (LPCWSTR)destPath))
        {
            // can not open output file
            res = SZ_ERROR_FAIL;
            break;
        }

        processedSize = outSizeProcessed;

        if (File_Write(&outFile, outBuffer + offset, &processedSize) != 0 || processedSize != outSizeProcessed)
        {
            // can not write output file
            res = SZ_ERROR_FAIL;
            break;
        }

        {
            FILETIME mtime, ctime;
            FILETIME *mtimePtr = NULL;
            FILETIME *ctimePtr = NULL;

            if (SzBitWithVals_Check(&db.MTime, i))
            {
                const CNtfsFileTime *t = &db.MTime.Vals[i];
                mtime.dwLowDateTime = (DWORD)(t->Low);
                mtime.dwHighDateTime = (DWORD)(t->High);
                mtimePtr = &mtime;
            }
            if (SzBitWithVals_Check(&db.CTime, i))
            {
                const CNtfsFileTime *t = &db.CTime.Vals[i];
                ctime.dwLowDateTime = (DWORD)(t->Low);
                ctime.dwHighDateTime = (DWORD)(t->High);
                ctimePtr = &ctime;
            }
            if (mtimePtr || ctimePtr)
                SetFileTime(outFile.handle, ctimePtr, NULL, mtimePtr);
        }

        if (File_Close(&outFile))
        {
            // can not close output file
            res = SZ_ERROR_FAIL;
            break;
        }

        if (SzBitWithVals_Check(&db.Attribs, i))
        {
            UInt32 attrib = db.Attribs.Vals[i];
            /* p7zip stores posix attributes in high 16 bits and adds 0x8000 as marker.
                We remove posix bits, if we detect posix mode field */
            if ((attrib & 0xF0000000) != 0)
                attrib &= 0x7FFF;
            SetFileAttributesW((LPCWSTR)destPath, attrib);
        }
    }

    ISzAlloc_Free(&allocImp, outBuffer);
    SzFree(NULL, temp);
    SzArEx_Free(&db, &allocImp);
    ISzAlloc_Free(&allocImp, lookStream.buf);

    File_Close(&archiveStream.file);
    SetCurrentDirectoryW(old_dir);

    return res == SZ_OK ? 0 : -1;
}
