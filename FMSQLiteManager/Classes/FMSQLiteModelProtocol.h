//
//  FMSQLiteModelProtocol.h
//  Tool
//
//  Created by iOS on 2022/11/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FMResultSet;
@protocol FMSQLiteModelProtocol <NSObject>

+ (NSInteger)version;
+ (NSString *)tableName;
+ (NSString *)createTableSQL;
+ (NSString *)primaryKey;
- (NSString *)insertSQL;
+ (instancetype)modelWithFMResultSet:(FMResultSet *)set;

- (NSString *)updateSQLFromColumns:(NSArray *)columns;

- (BOOL)canDencodeFronColumnName:(NSString *)columnName;
- (id)dencodeValueFronColumnName:(NSString *)columnName withFMResultSet:(FMResultSet *)set;

- (BOOL)canEncodeFronColumnName:(NSString *)columnName;
- (id)encodeValueFronColumnName:(NSString *)columnName;

@end

NS_ASSUME_NONNULL_END
