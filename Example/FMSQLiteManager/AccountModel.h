//
//  AccountModel.h
//  SWTikTokDylib
//
//  Created by iOS on 2022/11/14.
//

#import <Foundation/Foundation.h>
#import "FMSQLiteBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AccountModel : FMSQLiteBaseModel

@property long long userID;
@property NSString *customID;
@property NSString *email;
@property NSString *password;
@property NSString *nickname;
@property NSString *avatar;
@property NSString *region;
@property NSInteger fans;
@property NSInteger followed;
@property NSDate *addDate;
@property NSDate *updateDate;
@property NSString *areaCode;

@end

NS_ASSUME_NONNULL_END
