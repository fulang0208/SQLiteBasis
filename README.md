# SQLiteBasis
SQLite入门

### 创建数据库
* 在命令行中转到你想要保存数据库文件的目录
* 输入 sqlite3 <文件名>

        sqlite3 catalog.db
* 使用SQL语句创建表

        CREATE TABLE "main"."Product" ("ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "Name" TEXT, "ManufacturerID" INTEGER, "Details" TEXT, "Price" DOUBLE, "QuantityOnHand" INTEGER, "CountryOfOriginID" INTEGER, "Image" TEXT )
* 填充数据库，可以用INSERT语句一条一条的填充，也可以从文件导入

        //设置分隔符，前面为列分隔符(字段分隔符)，后面为行分隔符
        .rowseparator "\n" "\t"
        //导入文件，每一行为一条数据，字段的顺序必须和创建表时字段的顺序一致
        .import <product.txt> Product
* 更多命令输入.help查看

### 连接到数据库
* 将数据库文件catalog.db放入项目中
* 连接数据库代码

        sqlite3 *_database;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"db"];
        if (sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
          NSLog(@"Opening Database");
        }
        else {
          sqlite3_close(_database);
          NSAssert1(0, @"Failed to open database:'%s'.", sqlite3_errmsg(_database));
        }
* 从数据库读取数据

        const char *sql = "SELECT product.ID, product.name, Manufacturer.name, product.details, product.price,
                           product.quantityonhand, country.country, product.image FROM Product, Manufacturer, 
                           Country WHERE manufacturer.manufacturerid=product.manufacturerid AND 
                           product.countryoforiginid=country.countryid";
        sqlite3_stmt *statement;
        //注意，此时并不会开始执行sql语句
        int sqlResult = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (sqlResult == SQLITE_OK) {
          //逐行读取数据
          while (sqlite3_step(statement) == SQLITE_ROW) {
            int  ID                 = sqlite3_column_int(statement, 0);
            char *name              = (char *)sqlite3_column_text(statement, 1);
            char *manufacturer      = (char *)sqlite3_column_text(statement, 2);
            char *details           = (char *)sqlite3_column_text(statement, 3);
            float price             = sqlite3_column_double(statement, 4);
            int   quantity          = sqlite3_column_int(statement, 5);
            char *countryOfOrigin   = (char *)sqlite3_column_text(statement, 6);
            char *image             = (char *)sqlite3_column_text(statement, 7);
          }
          //读取完成后释放资源
          sqlite3_finalize(statement);
        }
* 关闭数据库连接
 
        if (sqlite3_close(_database) != SQLITE_OK) {
          NSAssert1(0, @"Error: failed to close database: '%s'.", sqlite3_errmsg(_database));
        }
* 因为数据库文件是在应用包中，所以无法修改，若要修改数据，可以创建一个副本到沙盒中
 
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

### 参数化查询
* sql语句

        SELECT Product.name, Country.country FROM Product, Country WHERE countryOfOriginid=countryid AND country = ?
* 在使用sqlite3_prepare_v2函数预编译语句后，使用sqlite3_step函数遍历查询结果前，需要绑定参数

        //sqlite3_bind_text(sqlite3_stmt *, int, const char *, int, void (*)(void *))
        sqlite3_bind_text(statement, 1, value, -1, SQLITE_TRANSIENT);
