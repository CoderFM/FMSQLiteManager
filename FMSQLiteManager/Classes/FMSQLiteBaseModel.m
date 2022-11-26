//
//  FMSQLiteBaseModel.m
//  Tool
//
//  Created by iOS on 2022/11/22.
//

#import "FMSQLiteBaseModel.h"
#import "FMSQLHelper.h"

@implementation FMSQLiteBaseModel

+ (NSInteger)version{
    return 1;
}

+ (NSString *)tableName{
    return NSStringFromClass(self);
}

+ (NSString *)createTableSQL{
    return [FMSQLHelper createTableSQLFrom:self];
}

+ (NSString *)primaryKey{
    return @"";
}

+ (instancetype)modelWithFMResultSet:(FMResultSet *)set{
    FMSQLiteBaseModel *model = [[self alloc] init];
    [FMSQLHelper updateModel:model withFMResultSet:set];
    return model;
}

- (NSString *)insertSQL{
    return [FMSQLHelper insertSQLFrom:self];
}

- (NSString *)updateSQLFromColumns:(NSArray *)columns{
    return [FMSQLHelper updateSQLFrom:self columns:columns];
}

- (BOOL)canDencodeFronColumnName:(NSString *)columnName{
    return NO;
}
- (id)dencodeValueFronColumnName:(NSString *)columnName withFMResultSet:(FMResultSet *)set{
    return NULL;
}

- (BOOL)canEncodeFronColumnName:(NSString *)columnName{
    return NO;
}
- (id)encodeValueFronColumnName:(NSString *)columnName{
    return NULL;
}

@end
