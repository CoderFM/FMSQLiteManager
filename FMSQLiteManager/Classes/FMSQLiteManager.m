//
//  FMSQLiteManager.m
//

#import "FMSQLiteManager.h"
#import "FMDB.h"
#import "FMSQLHelper.h"

@interface FMSQLiteManager ()

@property(nonatomic, strong)FMDatabaseQueue *databaseQueue;

@end

@implementation FMSQLiteManager

+ (instancetype)managerWithDBPath:(NSString *)path{
    FMSQLiteManager *manager = [[self alloc] init];
    [manager openWithDBPath:path];
    return manager;
}

- (void)openWithDBPath:(NSString *)path{
    NSLog(@"%@", path);
    self.databaseQueue = [[FMDatabaseQueue alloc] initWithPath:path];
}

- (BOOL)createTableIfNotExistFrom:(Class<FMSQLiteModelProtocol>)class0{
    NSString *sql = [class0 createTableSQL];
    return [self executeSQL:sql];
}

- (BOOL)saveObject:(id<FMSQLiteModelProtocol>)model{
    [self createTableIfNotExistFrom:[model class]];
    NSString *sql = [model insertSQL];
    return [self executeSQL:sql];
}

- (BOOL)saveOrUpdateObject:(id<FMSQLiteModelProtocol>)model{
    [self deleteObject:model];
    return [self saveObject:model];
}

- (BOOL)updateObject:(id<FMSQLiteModelProtocol>)model columns:(NSArray<NSString *> *)columns{
    NSString *sql = [model updateSQLFromColumns:columns];
    return [self executeSQL:sql];
}

- (BOOL)deleteObject:(id<FMSQLiteModelProtocol>)model{
    Class<FMSQLiteModelProtocol> modelClass = [model class];
    return [self deleteObject:model column:[modelClass primaryKey]];
}

- (BOOL)deleteObject:(id<FMSQLiteModelProtocol>)model column:(NSString *)column{
    Class<FMSQLiteModelProtocol> modelClass = [model class];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %@;", [modelClass tableName], column, [FMSQLHelper getValueStringFor:column fromObject:model]];
    return [self executeSQL:sql];
}

- (BOOL)deleteAllObjectsFrom:(Class<FMSQLiteModelProtocol>)class0{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@;", [class0 tableName]];
    return [self executeSQL:sql];
}

- (BOOL)executeSQL:(NSString *)sql{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block BOOL success;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [db executeUpdate:sql];
        if (success) {
            printf("成功\n");
        } else {
            printf("失败\n");
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return success;
}

- (void)loadAllObjectsFrom:(Class<FMSQLiteModelProtocol>)class0 orderBy:(NSString * _Nullable)orderBy complete:(void(^)(NSArray<FMSQLiteModelProtocol> *models))complete{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@%@;", [class0 tableName], orderBy ? [NSString stringWithFormat:@" ORDER BY %@", orderBy] : @""];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray *arrM = [NSMutableArray array];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) {
            [arrM addObject:[class0 modelWithFMResultSet:set]];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (complete) {
        complete([arrM copy]);
    }
}

- (void)existWithCondition:(NSString *)condition class:(Class<FMSQLiteModelProtocol>)class0 compelete:(void(^)(BOOL has, id<FMSQLiteModelProtocol> model))compelete{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIMIT 0,1;", [class0 tableName], condition];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block BOOL success = NO;
    __block id model;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) {
            model = [class0 modelWithFMResultSet:set];
            success = YES;
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    !compelete ?:compelete(success, model);
}

- (void)clearTableFrom:(Class<FMSQLiteModelProtocol>)class0{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@;", [class0 tableName]];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self.databaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        [db executeUpdate:sql];
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

@end

