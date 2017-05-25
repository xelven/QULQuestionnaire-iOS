//
//  QULQuestionnaireBaseViewController.h
//  Pods
//
//  Created by Scott Chou on 24/05/2017.
//
//

#import <UIKit/UIKit.h>
#import "QULLabel.h"

@class QULLabel;
@interface QULQuestionnaireBaseViewController : UIViewController

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *questionLabel;

@property (strong, nonatomic) QULLabel *alertBottomLabel;
@property (strong, nonatomic) UIButton *previousButton;
@property (strong, nonatomic) UIButton *nextButton;

@property (nonatomic, getter=isRequired) BOOL required;

- (void)updateQuestionTitle:(NSString *)title;

- (void)proceed;
- (void)previousProceed;

@end
