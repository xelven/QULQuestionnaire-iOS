//
//  QULQuestionnaireBaseViewController.h
//  Pods
//
//  Created by Scott Chou on 24/05/2017.
//
//

#import <UIKit/UIKit.h>

@interface QULQuestionnaireBaseViewController : UIViewController

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *questionLabel;

@property (nonatomic, getter=isRequired) BOOL required;

- (void)updateQuestionTitle:(NSString *)title;

- (BOOL)proceed;
- (void)previousProceed;

@end
