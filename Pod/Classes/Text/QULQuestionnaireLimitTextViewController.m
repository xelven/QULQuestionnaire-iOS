//
//  QULQuestionnaireLimitTextViewController.m
//  Pods
//
//  Created by Scott Chou on 24/05/2017.
//
//

#import "QULQuestionnaireLimitTextViewController.h"
#import "RMStepsController.h"
#import "DotBorderTextView.h"

@interface QULQuestionnaireLimitTextViewController () <UITextViewDelegate, NSLayoutManagerDelegate> {
	NSBundle *resourceBundle;
}

@property (strong, nonatomic) DotBorderTextView *textView;

@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *redNextButton;

@property (strong, nonatomic) NSString *placeholder;
@property (nonatomic) NSInteger maxLength;

@end

@implementation QULQuestionnaireLimitTextViewController

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	resourceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]]
											   pathForResource:@"QULQuestionnaire"
											   ofType:@"bundle"]];

	[self updateQuestionTitle:self.questionnaireData[@"question"]];
	self.required = [self.questionnaireData[@"required"] boolValue];
	self.maxLength = self.questionnaireData[@"maxLength"] ? [self.questionnaireData[@"maxLength"] integerValue] : 80;
	self.placeholder = self.questionnaireData[@"placeholder"] ? self.questionnaireData[@"placeholder"] : @"";

	UITextView *textView = self.textView;
	if ([self.questionnaireData[@"content"] isKindOfClass:[NSString class]]) {
		textView.text = self.questionnaireData[@"content"];
		textView.textColor = [UIColor blackColor];
		[self updateMessageLabel:textView.text.length];
	} else {
		textView.text = self.questionnaireData[@"placeholder"];
		textView.textColor = [UIColor lightGrayColor];
		[self updateMessageLabel:0];
	}
	[self.contentView addSubview:textView];

	UILabel *messageLabel = self.messageLabel;
	[self.contentView addSubview:messageLabel];

	UIButton *nextButton = self.redNextButton;
	[self.contentView addSubview:nextButton];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	[self.contentView addGestureRecognizer:tapGestureRecognizer];

	UIView *questionLabel = self.questionLabel;
	NSDictionary *views = NSDictionaryOfVariableBindings(questionLabel,
														 textView,
														 messageLabel,
														 nextButton);

	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[questionLabel]-(66@999)-[textView(78)]-(17@998)-[messageLabel]"
																			 options:0
																			 metrics:nil
																			   views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[textView]-(15@999)-|"
																			 options:0
																			 metrics:nil
																			   views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[messageLabel]"
																			 options:0
																			 metrics:nil
																			   views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textView]-(9)-[nextButton(30)]-(15)-|"
																			 options:0
																			 metrics:nil
																			   views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[nextButton(80@998)]-(15@999)-|"
																			 options:0
																			 metrics:nil
																			   views:views]];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillChangeFrame:)
												 name:UIKeyboardWillChangeFrameNotification
											   object:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)proceed {
	[super proceed];

	if ([self.textView.text isEqualToString:@""] &&
		self.isRequired && self.alertBottomLabel.hidden == YES) {
		self.alertBottomLabel.text = [NSString stringWithFormat:NSLocalizedString(@"This is a required function. If you wish to skip, please tap the '%@' button again.", nil), [self.nextButton titleForState:UIControlStateNormal]];
		self.alertBottomLabel.hidden = NO;
	} else {
		self.alertBottomLabel.hidden = YES;

		[self sendResults];
		[self.stepsController showNextStep];
	}
}

- (void)previousProceed {
	[super previousProceed];

	[self sendResults];
	[self.stepsController showPreviousStep];
}

- (void)sendResults {
	NSString *answer = @"";
	if (![self.textView.text isEqualToString:self.questionnaireData[@"placeholder"]]) {
		answer = self.textView.text;
	}

	NSDictionary *result = @{@"q": self.questionnaireData[@"key"],
							 @"a": answer};
	[self.stepsController.results[@"data"] addObject:result];
}

- (void)updateMessageLabel:(NSInteger)length {
	self.messageLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%zd/%zd characters", nil), length, self.maxLength];

	if (length < self.maxLength) {
		self.messageLabel.textColor = [UIColor colorWithRed:119.f/255.f green:119.f/255.f blue:119.f/255.f alpha:1.f]; // #777777
	} else {
		self.messageLabel.textColor = [UIColor colorWithRed:193/255.f green:26/255.f blue:36/255.f alpha:1.f]; // #C11A24
	}
}

#pragma mark - Action

- (void)tapAction:(UITapGestureRecognizer *)tapGestureRecognizer {
	[self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([textView.text isEqualToString:self.placeholder]) {
		textView.text = @"";
		textView.textColor = [UIColor blackColor];
	}
	[textView becomeFirstResponder];

	[self.textView showDotBorder:NO];
	self.textView.layer.borderColor = [UIColor colorWithRed:193/255.f green:26/255.f blue:36/255.f alpha:1.f].CGColor; // #C11A24
	self.redNextButton.hidden = (textView.text.length == 0);
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if ([textView.text isEqualToString:@""]) {
		textView.text = self.placeholder;
		textView.textColor = [UIColor lightGrayColor];
	}

	[self.textView showDotBorder:YES];
	self.textView.layer.borderColor = [UIColor clearColor].CGColor;

	[textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
	NSInteger length = textView.text.length;
	self.redNextButton.hidden = (length == 0);

	[self updateMessageLabel:length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqualToString:@""]) {
		return YES;
	} else if ([text isEqualToString:@"\n"]) {
		[self.view endEditing:YES];
		return NO;
	} else if (textView.text.length - range.length + text.length > self.maxLength) {
		return NO;
	}

	return YES;
}

#pragma mark - NSLayoutManagerDelegate

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
	return 3;
}

#pragma mark - UIKeyboard show / hide

- (void)keyboardWillShow:(NSNotification *)notification {

}

- (void)keyboardWillHide:(NSNotification *)notification {
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	UIScrollView *scrollView = [[self.view subviews] firstObject];
	scrollView.contentInset = contentInsets;
	scrollView.scrollIndicatorInsets = contentInsets;

	self.redNextButton.hidden = YES;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
	CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

	[self keyboardUpdateFrame:keyboardRect];
}

- (void)keyboardUpdateFrame:(CGRect)keyboardRect {
	keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0,
												  0.0,
												  keyboardRect.size.height - self.nextButton.frame.size.height,
												  0.0);
	UIScrollView *scrollView = [[self.view subviews] firstObject];
	scrollView.contentInset = contentInsets;
	scrollView.scrollIndicatorInsets = contentInsets;

	CGRect viewRect = self.view.frame;
	viewRect.size.height -= keyboardRect.size.height;
	if (!CGRectContainsPoint(viewRect, self.textView.frame.origin)) {
		[scrollView scrollRectToVisible:self.textView.frame animated:YES];
	}
}

- (UIKeyboardType)keyboardTypeForInput:(NSString *)input {
	if (!input) {
		return UIKeyboardTypeDefault;
	}

	UIKeyboardType type;
	if ([input isEqualToString:@"text"]) {
		type = UIKeyboardTypeDefault;
	} else if ([input isEqualToString:@"number"]) {
		type = UIKeyboardTypeNumberPad;
	} else if ([input isEqualToString:@"email"]) {
		type = UIKeyboardTypeEmailAddress;
	} else {
		type = UIKeyboardTypeDefault;
	}

	return type;
}

#pragma mark - Getter

- (DotBorderTextView *)textView {
	if (_textView) {
		return _textView;
	}

	// TODO: line: 19px (1.2)
	DotBorderTextView *textView = [[DotBorderTextView alloc] init];
	textView.translatesAutoresizingMaskIntoConstraints = NO;
	textView.delegate = self;
	textView.layoutManager.delegate = self;
	textView.font = [UIFont systemFontOfSize:16];
	textView.keyboardType = [self keyboardTypeForInput:self.questionnaireData[@"input"]];
	textView.returnKeyType = UIReturnKeyDone;
	textView.backgroundColor = [UIColor whiteColor];
	textView.layer.cornerRadius = 4.0;
	textView.layer.borderWidth = 1.0;
	textView.layer.masksToBounds = YES;
	textView.textContainerInset = UIEdgeInsetsMake(5, 5, 0, 5);
	[textView showDotBorder:YES];
	textView.layer.borderColor = [UIColor clearColor].CGColor;

	_textView = textView;

	return _textView;
}

- (UILabel *)messageLabel {
	if (_messageLabel) {
		return _messageLabel;
	}

	UILabel *messageLabel = [[UILabel alloc] init];
	messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
	messageLabel.font = [UIFont systemFontOfSize:12];
	messageLabel.textColor = [UIColor colorWithRed:119.f/255.f green:119.f/255.f blue:119.f/255.f alpha:1.f]; // #777777
	messageLabel.numberOfLines = 0;

	_messageLabel = messageLabel;

	return _messageLabel;
}

- (UIButton *)redNextButton {
	if (_redNextButton) {
		return _redNextButton;
	}

	NSString *nextButtonStr;
	UIImage *nextImage;
	if (self == [self.stepsController.childViewControllers lastObject]) {
		nextButtonStr = NSLocalizedString(@"Complete", nil);
	} else {
		nextButtonStr = NSLocalizedString(@"Next", nil);
		NSString *imgPath = [resourceBundle pathForResource:@"next" ofType:@"png"];
		nextImage = [UIImage imageWithContentsOfFile:imgPath];
	}

	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	nextButton.translatesAutoresizingMaskIntoConstraints = NO;
	nextButton.hidden = YES;
	nextButton.tintColor = [UIColor whiteColor];
	nextButton.titleLabel.font = [UIFont systemFontOfSize:16];
	[nextButton setTitle:NSLocalizedString(nextButtonStr, nil) forState:UIControlStateNormal];
	[nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	if (nextImage) {
		[nextButton setImage:nextImage forState:UIControlStateNormal];

		nextButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
		nextButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
		nextButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
		nextButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
	}
	nextButton.backgroundColor = [UIColor colorWithRed:193/255.f green:26/255.f blue:36/255.f alpha:1.f]; // #C11A24
	nextButton.layer.cornerRadius = 15.f;
	[nextButton addTarget:self
				   action:@selector(proceed)
		 forControlEvents:UIControlEventTouchUpInside];

	_redNextButton = nextButton;

	return _redNextButton;
}

@end
