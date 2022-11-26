#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SQLHelper.h"
#import "SQLiteBaseModel.h"
#import "SQLiteManager.h"
#import "SQLiteModelProtocol.h"

FOUNDATION_EXPORT double FMSQLiteManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char FMSQLiteManagerVersionString[];

