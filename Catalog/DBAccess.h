//
//  DBAccess.h
//  Catalog
//
//  Created by 傅浪 on 15/12/30.
//  Copyright © 2015年 傅浪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBAccess : NSObject

- (NSMutableArray *) getAllProducts;
- (void)closeDatabase;
@end
