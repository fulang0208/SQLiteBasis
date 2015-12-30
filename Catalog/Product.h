//
//  Product.h
//  Catalog
//
//  Created by 傅浪 on 15/12/30.
//  Copyright © 2015年 傅浪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject
@property (assign, nonatomic) int ID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *manufacturer;
@property (strong, nonatomic) NSString *details;
@property (assign, nonatomic) float price;
@property (assign, nonatomic) int quantity;
@property (strong, nonatomic) NSString *countryOfOrigin;
@property (strong, nonatomic) NSString *image;
@end
