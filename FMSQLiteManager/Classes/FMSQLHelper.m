//
//  FMSQLHelper.m
//  Tool
//
//  Created by iOS on 2022/11/16.
//

#import "FMSQLHelper.h"
#import <objc/runtime.h>
#import "FMDB.h"

typedef NS_ENUM(NSUInteger, SQLPropertyItemType) {
    SQLPropertyItemTypeObject,
    SQLPropertyItemTypeInteger,
    SQLPropertyItemTypeFloat
};

@interface SQLPropertyItem : NSObject

@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *type;
@property(nonatomic, assign)SQLPropertyItemType itemType;

@end

@implementation SQLPropertyItem

@end

void *SQLHelperGetPropertiesKey = &SQLHelperGetPropertiesKey;
void *SQLHelperGetPropertiesMapKey = &SQLHelperGetPropertiesMapKey;
@implementation FMSQLHelper

+ (NSString *)createTableSQLFrom:(Class<FMSQLiteModelProtocol>)modelClass{
    NSArray<SQLPropertyItem *> *items = [self getPropertyItemsFromClass:modelClass];
    NSMutableArray *columnTexts = [NSMutableArray array];
    NSString *primaryText = @"";
    for (SQLPropertyItem *item in items) {
        if ([item.name isEqualToString:[modelClass primaryKey]]) {
            primaryText = [NSString stringWithFormat:@"%@ %@ PRIMARY KEY NOT NULL", item.name, item.type];
        } else {
            [columnTexts addObject:[NSString stringWithFormat:@"%@ %@", item.name, item.type]];
        }
    }
    if (primaryText.length > 0) {
        [columnTexts insertObject:primaryText atIndex:0];
    }
    NSString *columnTextsString = [columnTexts componentsJoinedByString:@" ,"];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);", [modelClass tableName], columnTextsString];
    return sql;
}

+ (NSString *)insertSQLFrom:(id<FMSQLiteModelProtocol>)object{
    NSArray<SQLPropertyItem *> *items = [self getPropertyItemsFromClass:object.class];
    NSMutableArray *colums = [NSMutableArray array];
    NSMutableArray *columValues = [NSMutableArray array];
    for (SQLPropertyItem *item in items) {
        [colums addObject:item.name];
        [columValues addObject:[self getValueStringForItem:item fromObject:object]];
    }
    return [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES(%@);", [[object class] tableName], [colums componentsJoinedByString:@","], [columValues componentsJoinedByString:@" ,"]];
}

+ (NSString *)updateSQLFrom:(id<FMSQLiteModelProtocol>)object columns:(NSArray<NSString *> *)columns{
    NSArray<SQLPropertyItem *> *items = [self getPropertyItemsFromClass:object.class];
    NSString *primaryKey = [[object class] primaryKey];
    NSMutableArray *columSets = [NSMutableArray array];
    NSString *where;
    for (SQLPropertyItem *item in items) {
        if ([columns containsObject:item.name]) {
            [columSets addObject:[NSString stringWithFormat:@"%@ = %@", item.name, [self getValueStringForItem:item fromObject:object]]];
        } else if ([item.name isEqualToString:primaryKey]) {
            where = [NSString stringWithFormat:@"%@ = %@", item.name, [self getValueStringForItem:item fromObject:object]];
        }
    }
    NSString *tableName = [[object class] tableName];
    NSString *columnsString = [columSets componentsJoinedByString:@", "];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@;", tableName, columnsString, where];
    return sql;
}

+ (void)updateModel:(NSObject<FMSQLiteModelProtocol> *)model withFMResultSet:(FMResultSet *)set{
    NSArray<SQLPropertyItem *> *items = [self getPropertyItemsFromClass:[model class]];
    for (SQLPropertyItem *item in items) {
        if ([model canDencodeFronColumnName:item.name]) {
            id value = [model dencodeValueFronColumnName:item.name withFMResultSet:set];
            [model setValue:value forKey:item.name];
        } else {
            id value = nil;
            switch (item.itemType) {
                case SQLPropertyItemTypeFloat:
                    value = @([set doubleForColumn:item.name]);
                    break;
                case SQLPropertyItemTypeInteger:
                    value = @([set longLongIntForColumn:item.name]);
                    break;
                default:
                    value = [set stringForColumn:item.name];
                    break;
            }
            if ((value && ![value isKindOfClass:[NSNull class ]])) {
                if ([value isKindOfClass:[NSString class]]) {
                    if (![value isEqualToString:@"null"] && ![value isEqualToString:@"(null)"]) {
                        [model setValue:value forKey:item.name];
                    }
                } else {
                    [model setValue:value forKey:item.name];
                }
            }
        }
    }
}

+ (NSString *)getValueStringFor:(NSString *)key fromObject:(id<FMSQLiteModelProtocol>)object{
    SQLPropertyItem *item = [self getPropertyItemsDictionaryFromClass:[object class]][key];
    return [self getValueStringForItem:item fromObject:object];
}

+ (NSString *)getValueStringForItem:(SQLPropertyItem *)item fromObject:(id<FMSQLiteModelProtocol>)object{
    NSString *value;
    if ([object canEncodeFronColumnName:item.name]) {
        value = [NSString stringWithFormat:@"'%@'", [object encodeValueFronColumnName:item.name]];
    } else {
        switch (item.itemType) {
            case SQLPropertyItemTypeInteger:
            {
                value = [NSString stringWithFormat:@"%lld", [[(NSObject *)object valueForKey:item.name] longLongValue]];
            }
                break;
            case SQLPropertyItemTypeFloat:
            {
                value = [NSString stringWithFormat:@"%f", [[(NSObject *)object valueForKey:item.name] doubleValue]];
            }
                break;
            default:
            {
                value = [NSString stringWithFormat:@"'%@'", [(NSObject *)object valueForKey:item.name]];
            }
                break;
        }
    }
    return value;
}

+(NSArray<SQLPropertyItem *> *)getPropertyItemsFromClass:(Class)class{
    NSArray *caches = objc_getAssociatedObject(class, SQLHelperGetPropertiesKey);
    if (caches) {
        return caches;
    }
    unsigned int count = 0;
    Ivar* ivarList = class_copyIvarList(class, &count);
    NSMutableArray *arrM = [NSMutableArray array];
    for (unsigned int i = 0; i < count; i++) {
        Ivar anIvar = ivarList[i];
        NSString* ivarName = [[NSString alloc] initWithUTF8String:ivar_getName(anIvar)];
        SQLPropertyItem *item = [[SQLPropertyItem alloc] init];
        if ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        item.name = ivarName;
        [self getSaveTypeStringFromEncodingType:ivar_getTypeEncoding(anIvar) complete:^(NSString *type, SQLPropertyItemType itemType) {
            item.type = type;
            item.itemType = itemType;
        }];
        [arrM addObject:item];
    }
    free(ivarList);
    objc_setAssociatedObject(class, SQLHelperGetPropertiesKey, arrM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return arrM;
}

+ (NSDictionary<NSString *, SQLPropertyItem *> *)getPropertyItemsDictionaryFromClass:(Class)class{
    NSDictionary *caches = objc_getAssociatedObject(class, SQLHelperGetPropertiesMapKey);
    if (caches) {
        return caches;
    }
    NSArray<SQLPropertyItem *> *items = [self getPropertyItemsFromClass:class];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (SQLPropertyItem *item in items) {
        dict[item.name] = item;
    }
    objc_setAssociatedObject(self, SQLHelperGetPropertiesMapKey, [dict copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [dict copy];
}

+ (void)getSaveTypeStringFromEncodingType:(const char *)type complete:(void(^)(NSString *type, SQLPropertyItemType itemType))complete{
    switch (*type) {
        case 's':
        case 'I':
        case 'S':
            complete(@"INT", SQLPropertyItemTypeInteger);
            break;
        case 'l':
        case 'q':
        case 'L':
        case 'Q':
        case 'B':
            complete(@"INTEGER", SQLPropertyItemTypeInteger);
            break;
        case 'f':
            complete(@"REAL", SQLPropertyItemTypeFloat);
            break;
        default:
            complete(@"TEXT", SQLPropertyItemTypeObject);
            break;
    }
}

+ (NSString *)getTypeStringFromEncodingType:(const char *)type{
    switch (*type) {
        case '@': //对象
            return @"id";
        case ':': //方法
            return @"SEL";
        case 'c':
            return @"char";
        case 's':
            return @"short";
        case 'l':
            return @"long";
        case 'q':
            return @"long long";
        case 'C':
            return @"unsigned char";
        case 'I':
            return @"unsigned int";
        case 'S':
            return @"unsigned short";
        case 'L':
            return @"unsigned long";
        case 'Q':
            return @"unsigned long long";
        case 'f':
            return @"float";
        case 'd':
            return @"double";
        case 'v':
            return @"void";
        case  '*':
            return @"char *";
        case '#':
            return @"Class";
        case 'B':
            return @"BOOL";
        default:
            return @"Other";
    }
}

@end
