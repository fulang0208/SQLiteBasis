//
//  DetailViewController.m
//  Catalog
//
//  Created by 傅浪 on 15/12/30.
//  Copyright © 2015年 傅浪. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.title = NSLocalizedString(_detailItem.name, _detailItem.name);
        _nameLabel.text = _detailItem.name;
        _manufacturerLabel.text = _detailItem.manufacturer;
        _detailsLabel.text = _detailItem.details;
        _priceLabel.text = [NSString stringWithFormat:@"%.2f", _detailItem.price];
        _quantityLabel.text = [NSString stringWithFormat:@"%d", _detailItem.quantity];
        _countryLabel.text = _detailItem.countryOfOrigin;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
