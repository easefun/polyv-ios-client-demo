#import "PLVURLProtocol.h"

@interface PLVURLProtocol() <NSURLConnectionDelegate> {
    NSMutableURLRequest* myRequest;
    NSURLConnection * connection;
}
@end

static NSString* injectedURL = nil;
static NSString* myCookie = nil;

@implementation PLVURLProtocol
// register the class to intercept all HTTP calls
+ (void) register
{
    [NSURLProtocol registerClass:[self class]];
}

// public static function to call when injecting a cookie
+ (void) injectURL:(NSString*) urlString cookie:(NSString*)cookie
{
    injectedURL = urlString;
    myCookie = cookie;
}

// decide whether or not the call should be intercepted
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    //NSLog(@"%@",[[request URL] absoluteString]);
    if([[[request allHTTPHeaderFields] objectForKey:@"BANANA"] isEqualToString:@"DELICIOUS"])
    {
        return NO;
    }
    //return [[[request URL] absoluteString] isEqualToString:injectedURL];
    return [[[request URL] absoluteString] hasPrefix:@"http://v.polyv.net"];
    
}

// required (don't know what this means)
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

// intercept the request and handle it yourself
- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    
    if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client]) {
        myRequest = request.mutableCopy;
        [myRequest setValue:@"DELICIOUS" forHTTPHeaderField:@"BANANA"]; // add your own signature to the request
    }
    return self;
}

// load the request
- (void)startLoading {
    //  inject your cookie
    //NSLog(@"cookie:%@",myCookie);
    [myRequest setValue:myCookie forHTTPHeaderField:@"Cookie"];
    connection = [[NSURLConnection alloc] initWithRequest:myRequest delegate:self];
}

// overload didReceive data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

// overload didReceiveResponse
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:[myRequest cachePolicy]];
}

// overload didFinishLoading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self client] URLProtocolDidFinishLoading:self];
}

// overload didFail
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
}

// handle load cancelation
- (void)stopLoading {
    [connection cancel];
}

@end