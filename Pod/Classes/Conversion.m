#import "Conversion.h"
#import "Constants.h"
#import <UIKit/UIKit.h>

@interface Conversion () <UIWebViewDelegate>

@property UIWebView *webView;
@property NSDictionary *conversionJSONResponse;

@end


@implementation Conversion

#pragma mark - Inits
- (id)init
{
    if ([super init]) {
        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;
    }
    return self;
}


#pragma mark - API Functions
- (BOOL)identify
{
    NSURL *url = [NSURL URLWithString:augurFingerprintURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    return YES;
}

- (BOOL)trackConversion
{
    return [self trackConversionWithEmail:noConversionEmailDefualtString];
}

- (BOOL)trackConversionWithEmail:(NSString*)email
{
    if ([email isEqualToString:noConversionEmailDefualtString])
    {
        //TODO: handle the case with no email passed
    }
    else
    {
        //TODO: handle the case with email passed
    }
    
    return YES;
}


#pragma mark - Network Helper Functions
- (BOOL)getIdentifyJSON
{
    NSString *JSONString = [self.webView
                            stringByEvaluatingJavaScriptFromString:JSONJavascriptVariableName];
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *JSONSerialization = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
    if (error)
    {
        NSLog(@"%@\n%@", JSONParseErrorMessage, error);
        return NO;
    }
    else
    {
        NSLog(@"JSON Data Recieved From Server");
        self.conversionJSONResponse = JSONSerialization;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JSONCompletedNotificationName
                                                            object:self];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:JSONSerialization forKey:NSUserDefaultsKeyName];
        [defaults synchronize];
        return YES;
    }
}


#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
                                                 navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@":"];
    if (urlRequestComponents.count > 1 &&
        [(NSString *)urlRequestComponents[0] isEqualToString:internalURLString])
    {
        [self getIdentifyJSON];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache]
                                           cachedResponseForRequest:webView.request];
    response = (NSHTTPURLResponse *)cachedResponse.response;
    
    //TODO: create proper errors to throw for non-200 responses
    if (response.statusCode == 200 || response.statusCode == 202)
    {
        NSLog(@"%@ - %ld", fingerprintSuccessMessage, (long)response.statusCode);
    }
    else
    {
        NSLog(@"%@ - %ld", fingerprintErrorMessage, (long)response.statusCode);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@\n%@", webViewFailedToLoadErrorMessage, error);
}

@end
