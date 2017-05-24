//
//  QULQuestionnaireBaseViewController.m
//  Pods
//
//  Created by Scott Chou on 24/05/2017.
//
//

#import "QULQuestionnaireBaseViewController.h"
#import "RMStepsController.h"
#import "QULLabel.h"

@interface QULQuestionnaireBaseViewController ()

@property (strong, nonatomic) NSBundle *resourceBundle;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *requiredImageView;
@property (strong, nonatomic) UILabel *requiredLabel;

@property (strong, nonatomic) QULLabel *alertBottomLabel;
@property (strong, nonatomic) UIButton *previousButton;
@property (strong, nonatomic) UIButton *nextButton;

@end

@implementation QULQuestionnaireBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	_scrollView = [[UIScrollView alloc] init];
	self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.scrollView];

	_contentView = [[UIView alloc] init];
	self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.scrollView addSubview:self.contentView];

	NSInteger viewIndex = [self.stepsController.childViewControllers indexOfObject:self];
	BOOL isShowPrevious = viewIndex == 0? NO : YES;

	if (isShowPrevious == YES) {
		[self.view addSubview:self.previousButton];
		if (self.stepsController.stepButtonColor)
			[self.previousButton setTitleColor:self.stepsController.stepButtonColor forState:UIControlStateNormal];
	}

	if (self.stepsController.stepButtonColor)
		[self.nextButton setTitleColor:self.stepsController.stepButtonColor forState:UIControlStateNormal];
	[self.view addSubview:self.nextButton];
	[self.view addSubview:self.alertBottomLabel];

	[self.contentView addSubview:self.questionLabel];
	[self.contentView addSubview:self.requiredImageView];
	[self.contentView addSubview:self.requiredLabel];

	[self setAutolayoutViews];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.scrollView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Layout

- (void)setAutolayoutViews {
	NSDictionary *views;
	if (_previousButton) {
		views = @{@"mainView": self.view,
				  @"scrollView": self.scrollView,
				  @"contentView": self.contentView,
				  @"questionLabel": self.questionLabel,
				  @"requiredImageView": self.requiredImageView,
				  @"requiredLabel": self.requiredLabel,
				  @"alertBottomLabel": self.alertBottomLabel,
				  @"nextButton": self.nextButton,
				  @"previousButton": self.previousButton};
	} else {
		views = @{@"mainView": self.view,
				  @"scrollView": self.scrollView,
				  @"contentView": self.contentView,
				  @"questionLabel": self.questionLabel,
				  @"requiredImageView": self.requiredImageView,
				  @"requiredLabel": self.requiredLabel,
				  @"alertBottomLabel": self.alertBottomLabel,
				  @"nextButton": self.nextButton};
	}

	// View

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
																	  options:0
																	  metrics:nil
																		views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]-(0@999)-[nextButton(50)]-|"
																	  options:0
																	  metrics:nil
																		views:views]];
	if (_previousButton)
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView][previousButton(50)]|"
																		  options:0
																		  metrics:nil
																			views:views]];

	if (_previousButton) {
		NSInteger button_width = self.view.frame.size.width/2;
		NSString *visualFormat = [NSString stringWithFormat:@"H:|-(-1)-[previousButton(%zd)]-(-1)-[nextButton]-(-1)-|", button_width];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
																		  options:0
																		  metrics:nil
																			views:views]];
	} else {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-1)-[nextButton]-(-1)-|"
																		  options:0
																		  metrics:nil
																			views:views]];
	}

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[alertBottomLabel(54)][nextButton]"
																	  options:0
																	  metrics:nil
																		views:views]];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[alertBottomLabel]|"
																	  options:0
																	  metrics:nil
																		views:views]];

	// Inside scrollview
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]"
																	  options:0
																	  metrics:nil
																		views:views]];
	[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
																			options:0
																			metrics:nil
																			  views:views]];
	[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
																			options:0
																			metrics:nil
																			  views:views]];

	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[questionLabel]-(15@999)-|"
																			options:0
																			metrics:nil
																			  views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[questionLabel]-(20)-[requiredLabel]"
																			options:0
																			metrics:nil
																			  views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[requiredImageView]-(5)-[requiredLabel]"
																			options:NSLayoutFormatAlignAllCenterY
																			metrics:nil
																			  views:views]];
}

#pragma mark - Update

- (void)updateQuestionTitle:(NSString *)title {
	UIColor *noColor = self.questionLabel.textColor;
	if (self.stepsController.stepsBar.mainColor)
		noColor = self.stepsController.stepsBar.mainColor;

	NSInteger index = [self.stepsController.childViewControllers indexOfObject:self];
	NSAttributedString *noTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Q%zd. ", index + 1]
																  attributes:@{NSForegroundColorAttributeName: noColor}];

	NSMutableAttributedString *finalTitle = [[NSMutableAttributedString alloc] initWithAttributedString:noTitle];
	[finalTitle appendAttributedString:[[NSAttributedString alloc] initWithString:title]];

	self.questionLabel.attributedText = finalTitle;
}

#pragma mark - Actions

- (BOOL)proceed {
	if (self.isRequired && self.alertBottomLabel.hidden == YES) {
		self.alertBottomLabel.text = [NSString stringWithFormat:@"This is a required function. If you wish to skip, please tap the '%@' button again.", [self.nextButton titleForState:UIControlStateNormal]];
		self.alertBottomLabel.hidden = NO;
		return NO;
	} else {
		self.alertBottomLabel.hidden = YES;
		return YES;
	}
}

- (void)previousProceed {

}

#pragma mark - Setter

- (void)setRequired:(BOOL)required {
	_required = required;

	self.requiredImageView.hidden = !required;
	self.requiredLabel.hidden = !required;
}

#pragma mark - Getter

- (NSBundle *)resourceBundle {
	if (_resourceBundle) {
		return _resourceBundle;
	}

	_resourceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"QULQuestionnaire" ofType:@"bundle"]];

	return _resourceBundle;
}

- (UILabel *)questionLabel {
	if (_questionLabel) {
		return _questionLabel;
	}

	_questionLabel = [[UILabel alloc] init];
	_questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_questionLabel.numberOfLines = 0;
	_questionLabel.font = [UIFont boldSystemFontOfSize:24];

	return _questionLabel;
}

- (UIImageView *)requiredImageView {
	if (_requiredImageView) {
		return _requiredImageView;
	}

	NSString *imgPath = [self.resourceBundle pathForResource:@"required" ofType:@"png"];
	UIImage *requiredImage = [UIImage imageWithContentsOfFile:imgPath];
	_requiredImageView = [[UIImageView alloc] initWithImage:requiredImage];
	_requiredImageView.translatesAutoresizingMaskIntoConstraints = NO;
	_requiredImageView.hidden = YES;

	return _requiredImageView;
}

- (UILabel *)requiredLabel {
	if (_requiredLabel) {
		return _requiredLabel;
	}

	_requiredLabel = [[UILabel alloc] init];
	_requiredLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_requiredLabel.text = @"Required";
	_requiredLabel.hidden = YES;

	return _requiredLabel;
}

- (UILabel *)alertBottomLabel {
	if (_alertBottomLabel) {
		return _alertBottomLabel;
	}

	_alertBottomLabel = [[QULLabel alloc] init];
	_alertBottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_alertBottomLabel.textInsets = UIEdgeInsetsMake(0, 15, 0, 15);
	_alertBottomLabel.numberOfLines = 0;
	_alertBottomLabel.hidden = YES;
	_alertBottomLabel.backgroundColor = [UIColor colorWithRed:193/255.0f green:26/255.0f blue:36/255.0f alpha:1.0f]; // #C11A24
	_alertBottomLabel.textColor = [UIColor whiteColor];
	_alertBottomLabel.font = [UIFont systemFontOfSize:14];

	return _alertBottomLabel;
}

- (UIButton *)previousButton {
	if (_previousButton) {
		return _previousButton;
	}

	NSString *imgPath = [self.resourceBundle pathForResource:@"prev" ofType:@"png"];
	UIImage *prevImage = [[UIImage imageWithContentsOfFile:imgPath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

	UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	previousButton.translatesAutoresizingMaskIntoConstraints = NO;
	previousButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
	[previousButton setTitle:NSLocalizedString(NSLocalizedString(@"Prev", nil), nil)
					forState:UIControlStateNormal];
	[previousButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	[previousButton setImage:prevImage forState:UIControlStateNormal];
	previousButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
	previousButton.backgroundColor = [UIColor whiteColor];
	previousButton.layer.borderColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f].CGColor; // #E5E5E5
	previousButton.layer.borderWidth = 1.0f;
	previousButton.layer.shadowColor = previousButton.layer.borderColor;
	previousButton.layer.shadowOpacity = 1.0f;
	previousButton.layer.shadowRadius = 0;
	previousButton.layer.shadowOffset = CGSizeMake(1, -1.0f);
	[previousButton addTarget:self
					   action:@selector(previousProceed)
			 forControlEvents:UIControlEventTouchUpInside];

	_previousButton = previousButton;

	return _previousButton;
}

- (UIButton *)nextButton {
	if (_nextButton) {
		return _nextButton;
	}

	NSString *nextButtonStr;
	UIImage *nextImage;
	if (self == [self.stepsController.childViewControllers lastObject]) {
		nextButtonStr = @"Complete";
	} else {
		nextButtonStr = @"Next";
		NSString *imgPath = [self.resourceBundle pathForResource:@"next" ofType:@"png"];
		nextImage = [[UIImage imageWithContentsOfFile:imgPath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	}

	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	nextButton.translatesAutoresizingMaskIntoConstraints = NO;
	nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
	[nextButton setTitle:NSLocalizedString(nextButtonStr, nil) forState:UIControlStateNormal];
//	[nextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	if (nextImage) {
		[nextButton setImage:nextImage forState:UIControlStateNormal];

		if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0) {
			nextButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
			nextButton.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
		} else {
			nextButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
			nextButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
			nextButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
			nextButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
		}
	}
	nextButton.backgroundColor = [UIColor whiteColor];
	nextButton.layer.borderColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f].CGColor; // #E5E5E5
	nextButton.layer.borderWidth = 1.0f;
	nextButton.layer.shadowColor = nextButton.layer.borderColor;
	nextButton.layer.shadowOpacity = 1.0f;
	nextButton.layer.shadowRadius = 0;
	nextButton.layer.shadowOffset = CGSizeMake(1, -1.0f);
	[nextButton addTarget:self
				   action:@selector(proceed)
		 forControlEvents:UIControlEventTouchUpInside];

	_nextButton = nextButton;

	return _nextButton;
}

@end
