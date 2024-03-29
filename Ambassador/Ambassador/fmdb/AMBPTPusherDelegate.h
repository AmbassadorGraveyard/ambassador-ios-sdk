//
//  PTPusherDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "AMBPTPusherMacros.h"

@class AMBPTPusher;
@class AMBPTPusherConnection;
@class AMBPTPusherChannel;
@class AMBPTPusherEvent;
@class AMBPTPusherErrorEvent;

/** Implementing the PTPusherDelegate protocol lets you react to important events in the Pusher client's
  lifetime, such as connection and disconnection, channel subscription and errors.
 
 All of the delegate methods are optional; you only need to implement what is required for your app.
 
 It may be useful to assign a delegate to monitor the status of the connection; you could use this to update
 your user interface accordingly.
 */
@protocol AMBPTPusherDelegate <NSObject>

@optional

///------------------------------------------------------------------------------------/
/// @name Connection handling
///------------------------------------------------------------------------------------/

/** Notifies the delegate that the PTPusher instance is about to connect to the Pusher service.
 
 @param pusher The PTPusher instance that is connecting.
 @param connection The connection for the pusher instance.
 @return NO to abort the connection attempt.
 */
- (BOOL)pusher:(AMBPTPusher *)pusher connectionWillConnect:(AMBPTPusherConnection *)connection;

/** Notifies the delegate that the PTPusher instance has connected to the Pusher service successfully.
 
 @param pusher The PTPusher instance that has connected.
 @param connection The connection for the pusher instance.
 */
- (void)pusher:(AMBPTPusher *)pusher connectionDidConnect:(AMBPTPusherConnection *)connection;

/** Notifies the delegate that the PTPusher instance has disconnected from the Pusher service.
 
 Clients should check the value of the willAttemptReconnect parameter before trying to reconnect manually. 
 In most cases, the client will try and automatically reconnect, depending on the error code returned by
 the Pusher service. 
 
 If willAttemptReconnect is YES, clients can expect a pusher:connectionWillReconnect:afterDelay: message 
 immediately following this one. Clients can return NO from that delegate method to cancel the automatic
 reconnection attempt.
 
 If the client has disconnected due to a fatal Pusher error (as indicated by the error code),
 willAttemptReconnect will be NO and the error domain will be `PTPusherFatalErrorDomain`.
 
 @param pusher The PTPusher instance that has connected.
 @param connection The connection for the pusher instance.
 @param error If the connection disconnected abnormally, error will be non-nil.
 @param willAttemptReconnect YES if the client will try and reconnect automatically.
 */
- (void)pusher:(AMBPTPusher *)pusher connection:(AMBPTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect;

/** Notifies the delegate that the PTPusher instance failed to connect to the Pusher service.
 
 In the case of connection failures, the client will *not* attempt to reconnect automatically.
 Instead, clients should implement this method and check the error code and manually reconnect
 the client if it makes sense to do so.
 
 @param pusher The PTPusher instance that has connected.
 @param connection The connection for the pusher instance.
 @param error The connection error.
 */
- (void)pusher:(AMBPTPusher *)pusher connection:(AMBPTPusherConnection *)connection failedWithError:(NSError *)error;

/** Notifies the delegate that the PTPusher instance will attempt to automatically reconnect.
 
 You may wish to use this method to keep track of the number of automatic reconnection attempts and abort after a fixed number.
 
 @param pusher The PTPusher instance that has connected.
 @param connection The connection for the pusher instance.
 @return NO if you do not want the client to attempt an automatic reconnection.
 */
- (BOOL)pusher:(AMBPTPusher *)pusher connectionWillAutomaticallyReconnect:(AMBPTPusherConnection *)connection afterDelay:(NSTimeInterval)delay;

///------------------------------------------------------------------------------------/
/// @name Channel subscription and authorization
///------------------------------------------------------------------------------------/

/** Notifies the delegate of the request that will be used to authorize access to a channel.
 
 When using the Pusher Javascript client, authorization typically relies on an existing session cookie
 on the server; when the Javascript client makes an AJAX POST to the server, the server can return
 the user's credentials based on their current session.
 
 When using libPusher, there will likely be no existing server-side session; authorization will
 need to happen by some other means (e.g. an authorization token or HTTP basic auth).
 
 By implementing this delegate method, you will be able to set any credentials as necessary by
 modifying the request as required (such as setting POST parameters or headers).
 
 @param pusher The PTPusher instance that is requesting authorization
 @param channel The channel that requires authorizing
 @param request A mutable URL request that will be POSTed to the configured `authorizationURL`
 */
- (void)pusher:(AMBPTPusher *)pusher willAuthorizeChannel:(AMBPTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request;

/** Allows the delegate to return authorization data in the format required by Pusher from a
 non-standard respnse.
 
 When using a remote server to authorize access to a private channel, the server is expected to 
 return an authorization payload in a specific format which is then sent to Pusher when connecting
 to a private channel.
 
 Sometimes, a server might return a non-standard response, for example, the auth data may be a sub-set
 of some bigger response.
 
 If implemented, Pusher will call this method with the response data returned from the authorization
 URL and will use whatever dictionary is returned instead.
*/
 - (NSDictionary *)pusher:(AMBPTPusher *)pusher authorizationPayloadFromResponseData:(NSDictionary *)responseData;

/** Notifies the delegate that the PTPusher instance has subscribed to the specified channel.
 
 This method will be called after any channel authorization has taken place and when a subscribe event has been received.
 
 @param pusher The PTPusher instance that has connected.
 @param channel The channel that was subscribed to.
 */
- (void)pusher:(AMBPTPusher *)pusher didSubscribeToChannel:(AMBPTPusherChannel *)channel;

/** Notifies the delegate that the PTPusher instance has unsubscribed from the specified channel.
 
 This method will be called immediately after unsubscribing from a channel.
 
 @param pusher The PTPusher instance that has connected.
 @param channel The channel that was unsubscribed from.
 */
- (void)pusher:(AMBPTPusher *)pusher didUnsubscribeFromChannel:(AMBPTPusherChannel *)channel;

/** Notifies the delegate that the PTPusher instance failed to subscribe to the specified channel.
 
 The most common reason for subscribing failing is authorization failing for private/presence channels.
 
 @param pusher The PTPusher instance that has connected.
 @param channel The channel that was subscribed to.
 @param error The error returned when attempting to subscribe.
 */
- (void)pusher:(AMBPTPusher *)pusher didFailToSubscribeToChannel:(AMBPTPusherChannel *)channel withError:(NSError *)error;

///------------------------------------------------------------------------------------/
/// @name Errors
///------------------------------------------------------------------------------------/

/** Notifies the delegate that an error event has been received.
 
 If a client is binding to all events, either through the client or using NSNotificationCentre, they will also
 receive notification of this event like any other.
 
 @param pusher The PTPusher instance that received the event.
 @param errorEvent The error event.
 */
- (void)pusher:(AMBPTPusher *)pusher didReceiveErrorEvent:(AMBPTPusherErrorEvent *)errorEvent;

@end
