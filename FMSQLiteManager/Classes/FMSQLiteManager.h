//
//  FMSQLiteManager.h
//

#import <Foundation/Foundation.h>
#import "FMSQLiteModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMSQLiteManager : NSObject

+ (instancetype)managerWithDBPath:(NSString *)path;

- (void)openWithDBPath:(NSString *)path;

- (BOOL)createTableIfNotExistFrom:(Class<FMSQLiteModelProtocol>)class0;

- (BOOL)executeSQL:(NSString *)sql;

- (BOOL)saveObject:(id<FMSQLiteModelProtocol>)model;

- (BOOL)saveOrUpdateObject:(id<FMSQLiteModelProtocol>)model;

- (BOOL)updateObject:(id<FMSQLiteModelProtocol>)model columns:(NSArray<NSString *> *)columns;

- (BOOL)deleteObject:(id<FMSQLiteModelProtocol>)model;

- (BOOL)deleteObject:(id<FMSQLiteModelProtocol>)model column:(NSString *)column;

- (BOOL)deleteAllObjectsFrom:(Class<FMSQLiteModelProtocol>)class0;

- (void)loadAllObjectsFrom:(Class<FMSQLiteModelProtocol>)class0 orderBy:(NSString * _Nullable)orderBy complete:(void(^)(NSArray<FMSQLiteModelProtocol> *models))complete;

- (BOOL)clearTableFrom:(Class<FMSQLiteModelProtocol>)class0;

@end

NS_ASSUME_NONNULL_END
