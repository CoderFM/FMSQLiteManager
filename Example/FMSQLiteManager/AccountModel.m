//
//  AccountModel.m
//  SWTikTokDylib
//
//  Created by iOS on 2022/11/14.
//

#import "AccountModel.h"
#import <FMDB.h>

NSDateFormatter *AccountDateFormatter(void){
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return formatter;
}

@implementation AccountModel

+ (NSString *)primaryKey{
    return @"userID";
}

- (BOOL)canEncodeFronColumnName:(NSString *)columnName{
    if ([columnName isEqualToString:NSStringFromSelector(@selector(addDate))]) {
        
        return YES;
    }
    if ([columnName isEqualToString:NSStringFromSelector(@selector(updateDate))]) {
        
        return YES;
    }
    return NO;
}

- (id)encodeValueFronColumnName:(NSString *)columnName{
    if ([columnName isEqualToString:NSStringFromSelector(@selector(addDate))]) {
        return [AccountDateFormatter() stringFromDate:self.addDate];
    }
    if ([columnName isEqualToString:NSStringFromSelector(@selector(updateDate))]) {
        return [AccountDateFormatter() stringFromDate:self.updateDate];
    }
    return NULL;
}

- (BOOL)canDencodeFronColumnName:(NSString *)columnName{
    if ([columnName isEqualToString:NSStringFromSelector(@selector(addDate))]) {
        
        return YES;
    }
    if ([columnName isEqualToString:NSStringFromSelector(@selector(updateDate))]) {
        
        return YES;
    }
    return NO;
}

- (id)dencodeValueFronColumnName:(NSString *)columnName withFMResultSet:(FMResultSet *)set{
    if ([columnName isEqualToString:NSStringFromSelector(@selector(addDate))]) {
        NSString *string = [set stringForColumn:columnName];
        return [AccountDateFormatter() dateFromString:string];
    }
    if ([columnName isEqualToString:NSStringFromSelector(@selector(updateDate))]) {
        NSString *string = [set stringForColumn:columnName];
        return [AccountDateFormatter() dateFromString:string];
    }
    return NULL;
}

@end
