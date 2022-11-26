//
//  FMSQLHelper.h
//  Tool
//
//  Created by iOS on 2022/11/16.
//

#import <Foundation/Foundation.h>
#import "FMSQLiteModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FMSQLHelper : NSObject

+ (NSString *)createTableSQLFrom:(Class<FMSQLiteModelProtocol>)modelClass;

+ (NSString *)insertSQLFrom:(id<FMSQLiteModelProtocol>)object;

+ (NSString *)updateSQLFrom:(id<FMSQLiteModelProtocol>)object columns:(NSArray<NSString *> *)columns;

+ (void)updateModel:(id<FMSQLiteModelProtocol>)model withFMResultSet:(FMResultSet *)set;

+ (NSString *)getValueStringFor:(NSString *)key fromObject:(id<FMSQLiteModelProtocol>)object;

@end

NS_ASSUME_NONNULL_END
