//
//  QULTapGestureRecognizer.h
//  Pods
//
//  Created by Allen Chan on 06/02/2017.
//
//

#import <UIKit/UIKit.h>

@interface QULButton: UIButton

@property (nonatomic, strong) UILabel *labelObj;

@end

@interface QULTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic, strong) UIButton *buttonObj;

@end
