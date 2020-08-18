//
//  FilterBarCell.h
//  Mosaic
//
//  Created by JH on 2020/8/18.
//  Copyright © 2020 JH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterBarCell : UICollectionViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isSelect;


@end

NS_ASSUME_NONNULL_END
