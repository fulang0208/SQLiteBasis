//
//  DBAccess.m
//  Catalog
//
//  Created by 傅浪 on 15/12/30.
//  Copyright © 2015年 傅浪. All rights reserved.
//

#import "DBAccess.h"
#import <sqlite3.h>
#import "Product.h"

@interface DBAccess ()
{
    sqlite3 *_database;
    NSString *_writableDBPath;
}
@end

@implementation DBAccess

- (instancetype)init {
    if (self = [super init]) {
        _writableDBPath = [self createEditableDatabase];
        [self initializeDatabase];
    }
    return self;
}

#pragma mark 打开数据库连接
- (void)initializeDatabase {
    NSString *path = nil;
    if (_writableDBPath) {
        path = [_writableDBPath copy];
    }
    else {
        path = [[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"db"];
    }
    if (sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
        NSLog(@"Opening Database");
    }
    else {
        sqlite3_close(_database);
        NSAssert1(0, @"Failed to open database:'%s'.", sqlite3_errmsg(_database));
    }
}

#pragma mark 关闭数据库连接
- (void)closeDatabase {
    if (sqlite3_close(_database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database: '%s'.", sqlite3_errmsg(_database));
    }
}

#pragma mark 获取数据库中所有Product数据
- (NSMutableArray *)getAllProducts {
    NSMutableArray *products = [NSMutableArray array];
    const char *sql = "SELECT product.ID, product.name, Manufacturer.name, product.details, product.price, product.quantityonhand, country.country, product.image FROM Product, Manufacturer, Country WHERE manufacturer.manufacturerid=product.manufacturerid AND product.countryoforiginid=country.countryid";
    sqlite3_stmt *statement;
    int sqlResult = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Product *product = [[Product alloc] init];
            char *name              = (char *)sqlite3_column_text(statement, 1);
            char *manufacturer      = (char *)sqlite3_column_text(statement, 2);
            char *details           = (char *)sqlite3_column_text(statement, 3);
            char *countryOfOrigin   = (char *)sqlite3_column_text(statement, 6);
            char *image             = (char *)sqlite3_column_text(statement, 7);
            
            product.ID              = sqlite3_column_int(statement, 0);
            product.name            = (name) ? [NSString stringWithUTF8String:name] : @"";
            product.manufacturer    = (manufacturer) ? [NSString stringWithUTF8String:manufacturer] : @"";
            product.details         = (details) ? [NSString stringWithUTF8String:details] : @"";
            product.price           = sqlite3_column_double(statement, 4);
            product.quantity        = sqlite3_column_int(statement, 5);
            product.countryOfOrigin = (countryOfOrigin) ? [NSString stringWithUTF8String:countryOfOrigin] : @"";
            product.image           = (image) ? [NSString stringWithUTF8String:image] : @"";
            
            [products addObject:product];
        }
        
        sqlite3_finalize(statement);
    }
    else {
        NSLog(@"Problem with the database: %d.", sqlResult);
    }
    return products;
}
#pragma mark 创建一个可写的数据库副本到沙盒
- (NSString *)createEditableDatabase {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *writableDB = [documentsDir stringByAppendingPathComponent:@"catalog.db"];
    success = [fileManager fileExistsAtPath:writableDB];
    
    if (success) {
        return writableDB;
    }
    
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"catalog.db"];
    success = [fileManager copyItemAtPath:defaultPath toPath:writableDB error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file: '%@'", [error localizedDescription]);
        return nil;
    }
    return writableDB;
}

@end
