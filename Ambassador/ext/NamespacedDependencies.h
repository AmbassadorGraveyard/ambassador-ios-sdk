// Namespaced Header

#ifndef __NS_SYMBOL
// We need to have multiple levels of macros here so that __NAMESPACE_PREFIX_ is
// properly replaced by the time we concatenate the namespace prefix.
#define __NS_REWRITE(ns, symbol) ns ## _ ## symbol
#define __NS_BRIDGE(ns, symbol) __NS_REWRITE(ns, symbol)
#define __NS_SYMBOL(symbol) __NS_BRIDGE(YOUR_PREFIX_HERE, symbol)
#endif


// Classes
#ifndef AmbassadorSDK
#define AmbassadorSDK __NS_SYMBOL(AmbassadorSDK)
#endif

#ifndef AuthorizeLinkedIn
#define AuthorizeLinkedIn __NS_SYMBOL(AuthorizeLinkedIn)
#endif

#ifndef Contact
#define Contact __NS_SYMBOL(Contact)
#endif

#ifndef ContactCell
#define ContactCell __NS_SYMBOL(ContactCell)
#endif

#ifndef ContactLoader
#define ContactLoader __NS_SYMBOL(ContactLoader)
#endif

#ifndef ContactSelector
#define ContactSelector __NS_SYMBOL(ContactSelector)
#endif

#ifndef Conversion
#define Conversion __NS_SYMBOL(Conversion)
#endif

#ifndef ConversionParameters
#define ConversionParameters __NS_SYMBOL(ConversionParameters)
#endif

#ifndef FMDatabase
#define FMDatabase __NS_SYMBOL(FMDatabase)
#endif

#ifndef FMDatabasePool
#define FMDatabasePool __NS_SYMBOL(FMDatabasePool)
#endif

#ifndef FMDatabaseQueue
#define FMDatabaseQueue __NS_SYMBOL(FMDatabaseQueue)
#endif

#ifndef FMResultSet
#define FMResultSet __NS_SYMBOL(FMResultSet)
#endif

#ifndef FMStatement
#define FMStatement __NS_SYMBOL(FMStatement)
#endif

#ifndef Identify
#define Identify __NS_SYMBOL(Identify)
#endif

#ifndef LinkedInShare
#define LinkedInShare __NS_SYMBOL(LinkedInShare)
#endif

#ifndef MFMailComposeViewController
#define MFMailComposeViewController __NS_SYMBOL(MFMailComposeViewController)
#endif

#ifndef MFMessageComposeViewController
#define MFMessageComposeViewController __NS_SYMBOL(MFMessageComposeViewController)
#endif

#ifndef NamePrompt
#define NamePrompt __NS_SYMBOL(NamePrompt)
#endif

#ifndef PTBlockEventListener
#define PTBlockEventListener __NS_SYMBOL(PTBlockEventListener)
#endif

#ifndef PTJSON
#define PTJSON __NS_SYMBOL(PTJSON)
#endif

#ifndef PTNSJSONParser
#define PTNSJSONParser __NS_SYMBOL(PTNSJSONParser)
#endif

#ifndef PTPusher
#define PTPusher __NS_SYMBOL(PTPusher)
#endif

#ifndef PTPusherAPI
#define PTPusherAPI __NS_SYMBOL(PTPusherAPI)
#endif

#ifndef PTPusherChannel
#define PTPusherChannel __NS_SYMBOL(PTPusherChannel)
#endif

#ifndef PTPusherChannelAuthorizationBypassOperation
#define PTPusherChannelAuthorizationBypassOperation __NS_SYMBOL(PTPusherChannelAuthorizationBypassOperation)
#endif

#ifndef PTPusherChannelAuthorizationOperation
#define PTPusherChannelAuthorizationOperation __NS_SYMBOL(PTPusherChannelAuthorizationOperation)
#endif

#ifndef PTPusherChannelMember
#define PTPusherChannelMember __NS_SYMBOL(PTPusherChannelMember)
#endif

#ifndef PTPusherChannelMembers
#define PTPusherChannelMembers __NS_SYMBOL(PTPusherChannelMembers)
#endif

#ifndef PTPusherConnection
#define PTPusherConnection __NS_SYMBOL(PTPusherConnection)
#endif

#ifndef PTPusherErrorEvent
#define PTPusherErrorEvent __NS_SYMBOL(PTPusherErrorEvent)
#endif

#ifndef PTPusherEvent
#define PTPusherEvent __NS_SYMBOL(PTPusherEvent)
#endif

#ifndef PTPusherEventBinding
#define PTPusherEventBinding __NS_SYMBOL(PTPusherEventBinding)
#endif

#ifndef PTPusherEventDispatcher
#define PTPusherEventDispatcher __NS_SYMBOL(PTPusherEventDispatcher)
#endif

#ifndef PTPusherMockConnection
#define PTPusherMockConnection __NS_SYMBOL(PTPusherMockConnection)
#endif

#ifndef PTPusherPresenceChannel
#define PTPusherPresenceChannel __NS_SYMBOL(PTPusherPresenceChannel)
#endif

#ifndef PTPusherPrivateChannel
#define PTPusherPrivateChannel __NS_SYMBOL(PTPusherPrivateChannel)
#endif

#ifndef PTTargetActionEventListener
#define PTTargetActionEventListener __NS_SYMBOL(PTTargetActionEventListener)
#endif

#ifndef PTURLRequestOperation
#define PTURLRequestOperation __NS_SYMBOL(PTURLRequestOperation)
#endif

#ifndef RemoveButton
#define RemoveButton __NS_SYMBOL(RemoveButton)
#endif

#ifndef SLComposeServiceViewController
#define SLComposeServiceViewController __NS_SYMBOL(SLComposeServiceViewController)
#endif

#ifndef SLComposeViewController
#define SLComposeViewController __NS_SYMBOL(SLComposeViewController)
#endif

#ifndef SRIOConsumer
#define SRIOConsumer __NS_SYMBOL(SRIOConsumer)
#endif

#ifndef SRIOConsumerPool
#define SRIOConsumerPool __NS_SYMBOL(SRIOConsumerPool)
#endif

#ifndef SRWebSocket
#define SRWebSocket __NS_SYMBOL(SRWebSocket)
#endif

#ifndef SelectedCell
#define SelectedCell __NS_SYMBOL(SelectedCell)
#endif

#ifndef SendCompletionModal
#define SendCompletionModal __NS_SYMBOL(SendCompletionModal)
#endif

#ifndef ServiceSelector
#define ServiceSelector __NS_SYMBOL(ServiceSelector)
#endif

#ifndef ServiceSelectorPreferences
#define ServiceSelectorPreferences __NS_SYMBOL(ServiceSelectorPreferences)
#endif

#ifndef ShareService
#define ShareService __NS_SYMBOL(ShareService)
#endif

#ifndef ShareServiceCell
#define ShareServiceCell __NS_SYMBOL(ShareServiceCell)
#endif

#ifndef _SRRunLoopThread
#define _SRRunLoopThread __NS_SYMBOL(_SRRunLoopThread)
#endif

// Functions
#ifndef FACEBOOK_BACKGROUND_COLOR
#define FACEBOOK_BACKGROUND_COLOR __NS_SYMBOL(FACEBOOK_BACKGROUND_COLOR)
#endif

#ifndef PTPusherConnectionURL
#define PTPusherConnectionURL __NS_SYMBOL(PTPusherConnectionURL)
#endif

#ifndef b64_ntop
#define b64_ntop __NS_SYMBOL(b64_ntop)
#endif

#ifndef lkdnBuildRequestTokenHTTPBody
#define lkdnBuildRequestTokenHTTPBody __NS_SYMBOL(lkdnBuildRequestTokenHTTPBody)
#endif

#ifndef parseQueryString
#define parseQueryString __NS_SYMBOL(parseQueryString)
#endif

#ifndef FACEBOOK_BACKGROUND_COLOR
#define FACEBOOK_BACKGROUND_COLOR __NS_SYMBOL(FACEBOOK_BACKGROUND_COLOR)
#endif

#ifndef PTPusherConnectionURL
#define PTPusherConnectionURL __NS_SYMBOL(PTPusherConnectionURL)
#endif

#ifndef b64_ntop
#define b64_ntop __NS_SYMBOL(b64_ntop)
#endif

#ifndef lkdnBuildRequestTokenHTTPBody
#define lkdnBuildRequestTokenHTTPBody __NS_SYMBOL(lkdnBuildRequestTokenHTTPBody)
#endif

#ifndef parseQueryString
#define parseQueryString __NS_SYMBOL(parseQueryString)
#endif

#ifndef FACEBOOK_BORDER_COLOR
#define FACEBOOK_BORDER_COLOR __NS_SYMBOL(FACEBOOK_BORDER_COLOR)
#endif

#ifndef TWITTER_BACKGROUND_COLOR
#define TWITTER_BACKGROUND_COLOR __NS_SYMBOL(TWITTER_BACKGROUND_COLOR)
#endif

#ifndef TWITTER_BORDER_COLOR
#define TWITTER_BORDER_COLOR __NS_SYMBOL(TWITTER_BORDER_COLOR)
#endif

#ifndef LINKEDIN_BACKGROUND_COLOR
#define LINKEDIN_BACKGROUND_COLOR __NS_SYMBOL(LINKEDIN_BACKGROUND_COLOR)
#endif

#ifndef LINKEDIN_BORDER_COLOR
#define LINKEDIN_BORDER_COLOR __NS_SYMBOL(LINKEDIN_BORDER_COLOR)
#endif

#ifndef SMS_BACKGROUND_COLOR
#define SMS_BACKGROUND_COLOR __NS_SYMBOL(SMS_BACKGROUND_COLOR)
#endif

#ifndef SMS_BORDER_COLOR
#define SMS_BORDER_COLOR __NS_SYMBOL(SMS_BORDER_COLOR)
#endif

#ifndef EMAIL_BACKGROUND_COLOR
#define EMAIL_BACKGROUND_COLOR __NS_SYMBOL(EMAIL_BACKGROUND_COLOR)
#endif

#ifndef EMAIL_BORDER_COLOR
#define EMAIL_BORDER_COLOR __NS_SYMBOL(EMAIL_BORDER_COLOR)
#endif

#ifndef b64_pton
#define b64_pton __NS_SYMBOL(b64_pton)
#endif

#ifndef ColorFromRGB
#define ColorFromRGB __NS_SYMBOL(ColorFromRGB)
#endif

#ifndef imageFromBundleNamed
#define imageFromBundleNamed __NS_SYMBOL(imageFromBundleNamed)
#endif

#ifndef sendAlert
#define sendAlert __NS_SYMBOL(sendAlert)
#endif

#ifndef frameworkBundle
#define frameworkBundle __NS_SYMBOL(frameworkBundle)
#endif

#ifndef FMDBExecuteBulkSQLCallback
#define FMDBExecuteBulkSQLCallback __NS_SYMBOL(FMDBExecuteBulkSQLCallback)
#endif

#ifndef FMDBBlockSQLiteCallBackFunction
#define FMDBBlockSQLiteCallBackFunction __NS_SYMBOL(FMDBBlockSQLiteCallBackFunction)
#endif

#ifndef FACEBOOK_BORDER_COLOR
#define FACEBOOK_BORDER_COLOR __NS_SYMBOL(FACEBOOK_BORDER_COLOR)
#endif

#ifndef TWITTER_BACKGROUND_COLOR
#define TWITTER_BACKGROUND_COLOR __NS_SYMBOL(TWITTER_BACKGROUND_COLOR)
#endif

#ifndef TWITTER_BORDER_COLOR
#define TWITTER_BORDER_COLOR __NS_SYMBOL(TWITTER_BORDER_COLOR)
#endif

#ifndef LINKEDIN_BACKGROUND_COLOR
#define LINKEDIN_BACKGROUND_COLOR __NS_SYMBOL(LINKEDIN_BACKGROUND_COLOR)
#endif

#ifndef LINKEDIN_BORDER_COLOR
#define LINKEDIN_BORDER_COLOR __NS_SYMBOL(LINKEDIN_BORDER_COLOR)
#endif

#ifndef SMS_BACKGROUND_COLOR
#define SMS_BACKGROUND_COLOR __NS_SYMBOL(SMS_BACKGROUND_COLOR)
#endif

#ifndef SMS_BORDER_COLOR
#define SMS_BORDER_COLOR __NS_SYMBOL(SMS_BORDER_COLOR)
#endif

#ifndef EMAIL_BACKGROUND_COLOR
#define EMAIL_BACKGROUND_COLOR __NS_SYMBOL(EMAIL_BACKGROUND_COLOR)
#endif

#ifndef EMAIL_BORDER_COLOR
#define EMAIL_BORDER_COLOR __NS_SYMBOL(EMAIL_BORDER_COLOR)
#endif

#ifndef b64_pton
#define b64_pton __NS_SYMBOL(b64_pton)
#endif

#ifndef ColorFromRGB
#define ColorFromRGB __NS_SYMBOL(ColorFromRGB)
#endif

#ifndef imageFromBundleNamed
#define imageFromBundleNamed __NS_SYMBOL(imageFromBundleNamed)
#endif

#ifndef sendAlert
#define sendAlert __NS_SYMBOL(sendAlert)
#endif

#ifndef frameworkBundle
#define frameworkBundle __NS_SYMBOL(frameworkBundle)
#endif

#ifndef FMDBExecuteBulkSQLCallback
#define FMDBExecuteBulkSQLCallback __NS_SYMBOL(FMDBExecuteBulkSQLCallback)
#endif

#ifndef FMDBBlockSQLiteCallBackFunction
#define FMDBBlockSQLiteCallBackFunction __NS_SYMBOL(FMDBBlockSQLiteCallBackFunction)
#endif

// Externs
#ifndef LKDN_ERROR_DICT_KEY
#define LKDN_ERROR_DICT_KEY __NS_SYMBOL(LKDN_ERROR_DICT_KEY)
#endif

#ifndef LKDN_CODE_DICT_KEY
#define LKDN_CODE_DICT_KEY __NS_SYMBOL(LKDN_CODE_DICT_KEY)
#endif

#ifndef LKDN_EXPIRES_DICT_KEY
#define LKDN_EXPIRES_DICT_KEY __NS_SYMBOL(LKDN_EXPIRES_DICT_KEY)
#endif

#ifndef LKDN_OAUTH_TOKEN_KEY
#define LKDN_OAUTH_TOKEN_KEY __NS_SYMBOL(LKDN_OAUTH_TOKEN_KEY)
#endif

#ifndef LKDN_COMMENT_DICT_KEY
#define LKDN_COMMENT_DICT_KEY __NS_SYMBOL(LKDN_COMMENT_DICT_KEY)
#endif

#ifndef LKDN_VISIBILITY_DICT_KEY
#define LKDN_VISIBILITY_DICT_KEY __NS_SYMBOL(LKDN_VISIBILITY_DICT_KEY)
#endif

#ifndef LKDN_AUTH_URL
#define LKDN_AUTH_URL __NS_SYMBOL(LKDN_AUTH_URL)
#endif

#ifndef LKDN_AUTH_CALLBACK_URL
#define LKDN_AUTH_CALLBACK_URL __NS_SYMBOL(LKDN_AUTH_CALLBACK_URL)
#endif

#ifndef LKDN_REQUEST_OAUTH_TOKEN_URL
#define LKDN_REQUEST_OAUTH_TOKEN_URL __NS_SYMBOL(LKDN_REQUEST_OAUTH_TOKEN_URL)
#endif

#ifndef LKDN_SHARE_URL
#define LKDN_SHARE_URL __NS_SYMBOL(LKDN_SHARE_URL)
#endif

#ifndef AMB_IDENTIFY_NOTIFICATION_NAME
#define AMB_IDENTIFY_NOTIFICATION_NAME __NS_SYMBOL(AMB_IDENTIFY_NOTIFICATION_NAME)
#endif

#ifndef AMB_IDENTIFY_USER_DEFAULTS_KEY
#define AMB_IDENTIFY_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_IDENTIFY_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY
#define AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_INSIGHTS_USER_DEFAULTS_KEY
#define AMB_INSIGHTS_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_INSIGHTS_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_PUSHER_KEY
#define AMB_PUSHER_KEY __NS_SYMBOL(AMB_PUSHER_KEY)
#endif

#ifndef AMB_PUSHER_AUTHENTICATION_URL
#define AMB_PUSHER_AUTHENTICATION_URL __NS_SYMBOL(AMB_PUSHER_AUTHENTICATION_URL)
#endif

#ifndef AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY
#define AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_RAF_SHARE_SERVICES_TITLE
#define AMB_RAF_SHARE_SERVICES_TITLE __NS_SYMBOL(AMB_RAF_SHARE_SERVICES_TITLE)
#endif

#ifndef AMB_CLOSE_BUTTON_NAME
#define AMB_CLOSE_BUTTON_NAME __NS_SYMBOL(AMB_CLOSE_BUTTON_NAME)
#endif

#ifndef AMB_BACK_BUTTON_NAME
#define AMB_BACK_BUTTON_NAME __NS_SYMBOL(AMB_BACK_BUTTON_NAME)
#endif

#ifndef AMB_LINKEDIN_USER_DEFAULTS_KEY
#define AMB_LINKEDIN_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_LINKEDIN_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_SHARE_TRACK_URL
#define AMB_SHARE_TRACK_URL __NS_SYMBOL(AMB_SHARE_TRACK_URL)
#endif

#ifndef AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY
#define AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY __NS_SYMBOL(AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY)
#endif

#ifndef AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY
#define AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY __NS_SYMBOL(AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY)
#endif

#ifndef AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY
#define AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY __NS_SYMBOL(AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY)
#endif

#ifndef AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY
#define AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY __NS_SYMBOL(AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY)
#endif

#ifndef AMB_SMS_SHARE_URL
#define AMB_SMS_SHARE_URL __NS_SYMBOL(AMB_SMS_SHARE_URL)
#endif

#ifndef PTPusherAuthorizationBypassURL
#define PTPusherAuthorizationBypassURL __NS_SYMBOL(PTPusherAuthorizationBypassURL)
#endif

#ifndef AMB_EMAIL_SHARE_URL
#define AMB_EMAIL_SHARE_URL __NS_SYMBOL(AMB_EMAIL_SHARE_URL)
#endif

#ifndef AMB_UPDATE_IDENTIFY_URL
#define AMB_UPDATE_IDENTIFY_URL __NS_SYMBOL(AMB_UPDATE_IDENTIFY_URL)
#endif

#ifndef AMB_ERROR_DOMAIN
#define AMB_ERROR_DOMAIN __NS_SYMBOL(AMB_ERROR_DOMAIN)
#endif

#ifndef FACEBOOK_TITLE
#define FACEBOOK_TITLE __NS_SYMBOL(FACEBOOK_TITLE)
#endif

#ifndef FACEBOOK_LOGO_IMAGE
#define FACEBOOK_LOGO_IMAGE __NS_SYMBOL(FACEBOOK_LOGO_IMAGE)
#endif

#ifndef TWITTER_TITLE
#define TWITTER_TITLE __NS_SYMBOL(TWITTER_TITLE)
#endif

#ifndef TWITTER_LOGO_IMAGE
#define TWITTER_LOGO_IMAGE __NS_SYMBOL(TWITTER_LOGO_IMAGE)
#endif

#ifndef LINKEDIN_TITLE
#define LINKEDIN_TITLE __NS_SYMBOL(LINKEDIN_TITLE)
#endif

#ifndef LINKEDIN_LOGO_IMAGE
#define LINKEDIN_LOGO_IMAGE __NS_SYMBOL(LINKEDIN_LOGO_IMAGE)
#endif

#ifndef SMS_TITLE
#define SMS_TITLE __NS_SYMBOL(SMS_TITLE)
#endif

#ifndef SMS_LOGO_IMAGE
#define SMS_LOGO_IMAGE __NS_SYMBOL(SMS_LOGO_IMAGE)
#endif

#ifndef EMAIL_TITLE
#define EMAIL_TITLE __NS_SYMBOL(EMAIL_TITLE)
#endif

#ifndef EMAIL_LOGO_IMAGE
#define EMAIL_LOGO_IMAGE __NS_SYMBOL(EMAIL_LOGO_IMAGE)
#endif

#ifndef PTPusherDataKey
#define PTPusherDataKey __NS_SYMBOL(PTPusherDataKey)
#endif

#ifndef PTPusherEventKey
#define PTPusherEventKey __NS_SYMBOL(PTPusherEventKey)
#endif

#ifndef PTPusherChannelKey
#define PTPusherChannelKey __NS_SYMBOL(PTPusherChannelKey)
#endif

#ifndef PTPusherConnectionEstablishedEvent
#define PTPusherConnectionEstablishedEvent __NS_SYMBOL(PTPusherConnectionEstablishedEvent)
#endif

#ifndef PTPusherConnectionPingEvent
#define PTPusherConnectionPingEvent __NS_SYMBOL(PTPusherConnectionPingEvent)
#endif

#ifndef PTPusherConnectionPongEvent
#define PTPusherConnectionPongEvent __NS_SYMBOL(PTPusherConnectionPongEvent)
#endif

#ifndef AMB_CONVERSION_DB_NAME
#define AMB_CONVERSION_DB_NAME __NS_SYMBOL(AMB_CONVERSION_DB_NAME)
#endif

#ifndef AMB_CONVERSION_SQL_TABLE_NAME
#define AMB_CONVERSION_SQL_TABLE_NAME __NS_SYMBOL(AMB_CONVERSION_SQL_TABLE_NAME)
#endif

#ifndef AMB_CONVERSION_URL
#define AMB_CONVERSION_URL __NS_SYMBOL(AMB_CONVERSION_URL)
#endif

#ifndef AMB_CONVERSION_INSERT_QUERY
#define AMB_CONVERSION_INSERT_QUERY __NS_SYMBOL(AMB_CONVERSION_INSERT_QUERY)
#endif

#ifndef AMB_CREATE_CONVERSION_TABLE
#define AMB_CREATE_CONVERSION_TABLE __NS_SYMBOL(AMB_CREATE_CONVERSION_TABLE)
#endif

#ifndef PTPusherEventReceivedNotification
#define PTPusherEventReceivedNotification __NS_SYMBOL(PTPusherEventReceivedNotification)
#endif

#ifndef PTPusherEventUserInfoKey
#define PTPusherEventUserInfoKey __NS_SYMBOL(PTPusherEventUserInfoKey)
#endif

#ifndef PTPusherErrorDomain
#define PTPusherErrorDomain __NS_SYMBOL(PTPusherErrorDomain)
#endif

#ifndef PTPusherFatalErrorDomain
#define PTPusherFatalErrorDomain __NS_SYMBOL(PTPusherFatalErrorDomain)
#endif

#ifndef PTPusherErrorUnderlyingEventKey
#define PTPusherErrorUnderlyingEventKey __NS_SYMBOL(PTPusherErrorUnderlyingEventKey)
#endif

#ifndef TITLE
#define TITLE __NS_SYMBOL(TITLE)
#endif

#ifndef AMB_CONVERSION_FLUSH_TIME
#define AMB_CONVERSION_FLUSH_TIME __NS_SYMBOL(AMB_CONVERSION_FLUSH_TIME)
#endif

#ifndef AMBASSADOR_INFO_URLS_KEY
#define AMBASSADOR_INFO_URLS_KEY __NS_SYMBOL(AMBASSADOR_INFO_URLS_KEY)
#endif

#ifndef CAMPAIGN_UID_KEY
#define CAMPAIGN_UID_KEY __NS_SYMBOL(CAMPAIGN_UID_KEY)
#endif

#ifndef SHORT_CODE_KEY
#define SHORT_CODE_KEY __NS_SYMBOL(SHORT_CODE_KEY)
#endif

#ifndef SHORT_CODE_URL_KEY
#define SHORT_CODE_URL_KEY __NS_SYMBOL(SHORT_CODE_URL_KEY)
#endif

#ifndef AMB_IDENTIFY_URL
#define AMB_IDENTIFY_URL __NS_SYMBOL(AMB_IDENTIFY_URL)
#endif

#ifndef AMB_IDENTIFY_JS_VAR
#define AMB_IDENTIFY_JS_VAR __NS_SYMBOL(AMB_IDENTIFY_JS_VAR)
#endif

#ifndef AMB_IDENTIFY_SIGNAL_URL
#define AMB_IDENTIFY_SIGNAL_URL __NS_SYMBOL(AMB_IDENTIFY_SIGNAL_URL)
#endif

#ifndef AMB_IDENTIFY_SEND_URL
#define AMB_IDENTIFY_SEND_URL __NS_SYMBOL(AMB_IDENTIFY_SEND_URL)
#endif

#ifndef AMB_INSIGHTS_URL
#define AMB_INSIGHTS_URL __NS_SYMBOL(AMB_INSIGHTS_URL)
#endif

#ifndef SEND_IDENTIFY_EMAIL_KEY
#define SEND_IDENTIFY_EMAIL_KEY __NS_SYMBOL(SEND_IDENTIFY_EMAIL_KEY)
#endif

#ifndef SEND_IDENTIFY_FP_KEY
#define SEND_IDENTIFY_FP_KEY __NS_SYMBOL(SEND_IDENTIFY_FP_KEY)
#endif

#ifndef SEND_IDENTIFY_MBSY_SOURCE_KEY
#define SEND_IDENTIFY_MBSY_SOURCE_KEY __NS_SYMBOL(SEND_IDENTIFY_MBSY_SOURCE_KEY)
#endif

#ifndef SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY
#define SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY __NS_SYMBOL(SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY)
#endif

#ifndef SEND_IDENTIFY_SOURCE_KEY
#define SEND_IDENTIFY_SOURCE_KEY __NS_SYMBOL(SEND_IDENTIFY_SOURCE_KEY)
#endif

#ifndef PUSHER_AUTH_AUTHTYPE_KEY
#define PUSHER_AUTH_AUTHTYPE_KEY __NS_SYMBOL(PUSHER_AUTH_AUTHTYPE_KEY)
#endif

#ifndef PUSHER_AUTH_CHANNEL_KEY
#define PUSHER_AUTH_CHANNEL_KEY __NS_SYMBOL(PUSHER_AUTH_CHANNEL_KEY)
#endif

#ifndef PUSHER_AUTH_SOCKET_ID_KEY
#define PUSHER_AUTH_SOCKET_ID_KEY __NS_SYMBOL(PUSHER_AUTH_SOCKET_ID_KEY)
#endif

#ifndef AMB_IDENTIFY_RETRY_TIME
#define AMB_IDENTIFY_RETRY_TIME __NS_SYMBOL(AMB_IDENTIFY_RETRY_TIME)
#endif

#ifndef CONTACT_CELL_IDENTIFIER
#define CONTACT_CELL_IDENTIFIER __NS_SYMBOL(CONTACT_CELL_IDENTIFIER)
#endif

#ifndef SELECTED_CELL_IDENTIFIER
#define SELECTED_CELL_IDENTIFIER __NS_SYMBOL(SELECTED_CELL_IDENTIFIER)
#endif

#ifndef NAME_PROMPT_SEGUE_IDENTIFIER
#define NAME_PROMPT_SEGUE_IDENTIFIER __NS_SYMBOL(NAME_PROMPT_SEGUE_IDENTIFIER)
#endif

#ifndef COMPOSE_MESSAGE_VIEW_HEIGHT
#define COMPOSE_MESSAGE_VIEW_HEIGHT __NS_SYMBOL(COMPOSE_MESSAGE_VIEW_HEIGHT)
#endif

#ifndef SEND_BUTTON_HEIGHT
#define SEND_BUTTON_HEIGHT __NS_SYMBOL(SEND_BUTTON_HEIGHT)
#endif

#ifndef SRWebSocketErrorDomain
#define SRWebSocketErrorDomain __NS_SYMBOL(SRWebSocketErrorDomain)
#endif

#ifndef CELL_IDENTIFIER
#define CELL_IDENTIFIER __NS_SYMBOL(CELL_IDENTIFIER)
#endif

#ifndef CONTACT_SELECTOR_SEGUE
#define CONTACT_SELECTOR_SEGUE __NS_SYMBOL(CONTACT_SELECTOR_SEGUE)
#endif

#ifndef LKND_AUTHORIZE_SEGUE
#define LKND_AUTHORIZE_SEGUE __NS_SYMBOL(LKND_AUTHORIZE_SEGUE)
#endif

#ifndef CELL_BORDER_WIDTH
#define CELL_BORDER_WIDTH __NS_SYMBOL(CELL_BORDER_WIDTH)
#endif

#ifndef CELL_CORNER_RADIUS
#define CELL_CORNER_RADIUS __NS_SYMBOL(CELL_CORNER_RADIUS)
#endif

#ifndef LKDN_ERROR_DICT_KEY
#define LKDN_ERROR_DICT_KEY __NS_SYMBOL(LKDN_ERROR_DICT_KEY)
#endif

#ifndef LKDN_CODE_DICT_KEY
#define LKDN_CODE_DICT_KEY __NS_SYMBOL(LKDN_CODE_DICT_KEY)
#endif

#ifndef LKDN_EXPIRES_DICT_KEY
#define LKDN_EXPIRES_DICT_KEY __NS_SYMBOL(LKDN_EXPIRES_DICT_KEY)
#endif

#ifndef LKDN_OAUTH_TOKEN_KEY
#define LKDN_OAUTH_TOKEN_KEY __NS_SYMBOL(LKDN_OAUTH_TOKEN_KEY)
#endif

#ifndef LKDN_COMMENT_DICT_KEY
#define LKDN_COMMENT_DICT_KEY __NS_SYMBOL(LKDN_COMMENT_DICT_KEY)
#endif

#ifndef LKDN_VISIBILITY_DICT_KEY
#define LKDN_VISIBILITY_DICT_KEY __NS_SYMBOL(LKDN_VISIBILITY_DICT_KEY)
#endif

#ifndef LKDN_AUTH_URL
#define LKDN_AUTH_URL __NS_SYMBOL(LKDN_AUTH_URL)
#endif

#ifndef LKDN_AUTH_CALLBACK_URL
#define LKDN_AUTH_CALLBACK_URL __NS_SYMBOL(LKDN_AUTH_CALLBACK_URL)
#endif

#ifndef LKDN_REQUEST_OAUTH_TOKEN_URL
#define LKDN_REQUEST_OAUTH_TOKEN_URL __NS_SYMBOL(LKDN_REQUEST_OAUTH_TOKEN_URL)
#endif

#ifndef LKDN_SHARE_URL
#define LKDN_SHARE_URL __NS_SYMBOL(LKDN_SHARE_URL)
#endif

#ifndef AMB_IDENTIFY_NOTIFICATION_NAME
#define AMB_IDENTIFY_NOTIFICATION_NAME __NS_SYMBOL(AMB_IDENTIFY_NOTIFICATION_NAME)
#endif

#ifndef AMB_IDENTIFY_USER_DEFAULTS_KEY
#define AMB_IDENTIFY_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_IDENTIFY_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY
#define AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_INSIGHTS_USER_DEFAULTS_KEY
#define AMB_INSIGHTS_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_INSIGHTS_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_PUSHER_KEY
#define AMB_PUSHER_KEY __NS_SYMBOL(AMB_PUSHER_KEY)
#endif

#ifndef AMB_PUSHER_AUTHENTICATION_URL
#define AMB_PUSHER_AUTHENTICATION_URL __NS_SYMBOL(AMB_PUSHER_AUTHENTICATION_URL)
#endif

#ifndef AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY
#define AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_RAF_SHARE_SERVICES_TITLE
#define AMB_RAF_SHARE_SERVICES_TITLE __NS_SYMBOL(AMB_RAF_SHARE_SERVICES_TITLE)
#endif

#ifndef AMB_CLOSE_BUTTON_NAME
#define AMB_CLOSE_BUTTON_NAME __NS_SYMBOL(AMB_CLOSE_BUTTON_NAME)
#endif

#ifndef AMB_BACK_BUTTON_NAME
#define AMB_BACK_BUTTON_NAME __NS_SYMBOL(AMB_BACK_BUTTON_NAME)
#endif

#ifndef AMB_LINKEDIN_USER_DEFAULTS_KEY
#define AMB_LINKEDIN_USER_DEFAULTS_KEY __NS_SYMBOL(AMB_LINKEDIN_USER_DEFAULTS_KEY)
#endif

#ifndef AMB_SHARE_TRACK_URL
#define AMB_SHARE_TRACK_URL __NS_SYMBOL(AMB_SHARE_TRACK_URL)
#endif

#ifndef AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY
#define AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY __NS_SYMBOL(AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY)
#endif

#ifndef AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY
#define AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY __NS_SYMBOL(AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY)
#endif

#ifndef AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY
#define AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY __NS_SYMBOL(AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY)
#endif

#ifndef AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY
#define AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY __NS_SYMBOL(AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY)
#endif

#ifndef AMB_SMS_SHARE_URL
#define AMB_SMS_SHARE_URL __NS_SYMBOL(AMB_SMS_SHARE_URL)
#endif

#ifndef AMB_EMAIL_SHARE_URL
#define AMB_EMAIL_SHARE_URL __NS_SYMBOL(AMB_EMAIL_SHARE_URL)
#endif

#ifndef AMB_UPDATE_IDENTIFY_URL
#define AMB_UPDATE_IDENTIFY_URL __NS_SYMBOL(AMB_UPDATE_IDENTIFY_URL)
#endif

#ifndef AMB_ERROR_DOMAIN
#define AMB_ERROR_DOMAIN __NS_SYMBOL(AMB_ERROR_DOMAIN)
#endif

#ifndef PTPusherAuthorizationBypassURL
#define PTPusherAuthorizationBypassURL __NS_SYMBOL(PTPusherAuthorizationBypassURL)
#endif

#ifndef FACEBOOK_TITLE
#define FACEBOOK_TITLE __NS_SYMBOL(FACEBOOK_TITLE)
#endif

#ifndef FACEBOOK_LOGO_IMAGE
#define FACEBOOK_LOGO_IMAGE __NS_SYMBOL(FACEBOOK_LOGO_IMAGE)
#endif

#ifndef TWITTER_TITLE
#define TWITTER_TITLE __NS_SYMBOL(TWITTER_TITLE)
#endif

#ifndef TWITTER_LOGO_IMAGE
#define TWITTER_LOGO_IMAGE __NS_SYMBOL(TWITTER_LOGO_IMAGE)
#endif

#ifndef LINKEDIN_TITLE
#define LINKEDIN_TITLE __NS_SYMBOL(LINKEDIN_TITLE)
#endif

#ifndef LINKEDIN_LOGO_IMAGE
#define LINKEDIN_LOGO_IMAGE __NS_SYMBOL(LINKEDIN_LOGO_IMAGE)
#endif

#ifndef SMS_TITLE
#define SMS_TITLE __NS_SYMBOL(SMS_TITLE)
#endif

#ifndef SMS_LOGO_IMAGE
#define SMS_LOGO_IMAGE __NS_SYMBOL(SMS_LOGO_IMAGE)
#endif

#ifndef EMAIL_TITLE
#define EMAIL_TITLE __NS_SYMBOL(EMAIL_TITLE)
#endif

#ifndef EMAIL_LOGO_IMAGE
#define EMAIL_LOGO_IMAGE __NS_SYMBOL(EMAIL_LOGO_IMAGE)
#endif

#ifndef PTPusherDataKey
#define PTPusherDataKey __NS_SYMBOL(PTPusherDataKey)
#endif

#ifndef PTPusherEventKey
#define PTPusherEventKey __NS_SYMBOL(PTPusherEventKey)
#endif

#ifndef PTPusherChannelKey
#define PTPusherChannelKey __NS_SYMBOL(PTPusherChannelKey)
#endif

#ifndef PTPusherConnectionEstablishedEvent
#define PTPusherConnectionEstablishedEvent __NS_SYMBOL(PTPusherConnectionEstablishedEvent)
#endif

#ifndef PTPusherConnectionPingEvent
#define PTPusherConnectionPingEvent __NS_SYMBOL(PTPusherConnectionPingEvent)
#endif

#ifndef PTPusherConnectionPongEvent
#define PTPusherConnectionPongEvent __NS_SYMBOL(PTPusherConnectionPongEvent)
#endif

#ifndef AMB_CONVERSION_DB_NAME
#define AMB_CONVERSION_DB_NAME __NS_SYMBOL(AMB_CONVERSION_DB_NAME)
#endif

#ifndef AMB_CONVERSION_SQL_TABLE_NAME
#define AMB_CONVERSION_SQL_TABLE_NAME __NS_SYMBOL(AMB_CONVERSION_SQL_TABLE_NAME)
#endif

#ifndef AMB_CONVERSION_URL
#define AMB_CONVERSION_URL __NS_SYMBOL(AMB_CONVERSION_URL)
#endif

#ifndef AMB_CONVERSION_INSERT_QUERY
#define AMB_CONVERSION_INSERT_QUERY __NS_SYMBOL(AMB_CONVERSION_INSERT_QUERY)
#endif

#ifndef AMB_CREATE_CONVERSION_TABLE
#define AMB_CREATE_CONVERSION_TABLE __NS_SYMBOL(AMB_CREATE_CONVERSION_TABLE)
#endif

#ifndef PTPusherEventReceivedNotification
#define PTPusherEventReceivedNotification __NS_SYMBOL(PTPusherEventReceivedNotification)
#endif

#ifndef PTPusherEventUserInfoKey
#define PTPusherEventUserInfoKey __NS_SYMBOL(PTPusherEventUserInfoKey)
#endif

#ifndef PTPusherErrorDomain
#define PTPusherErrorDomain __NS_SYMBOL(PTPusherErrorDomain)
#endif

#ifndef PTPusherFatalErrorDomain
#define PTPusherFatalErrorDomain __NS_SYMBOL(PTPusherFatalErrorDomain)
#endif

#ifndef PTPusherErrorUnderlyingEventKey
#define PTPusherErrorUnderlyingEventKey __NS_SYMBOL(PTPusherErrorUnderlyingEventKey)
#endif

#ifndef TITLE
#define TITLE __NS_SYMBOL(TITLE)
#endif

#ifndef AMB_CONVERSION_FLUSH_TIME
#define AMB_CONVERSION_FLUSH_TIME __NS_SYMBOL(AMB_CONVERSION_FLUSH_TIME)
#endif

#ifndef AMBASSADOR_INFO_URLS_KEY
#define AMBASSADOR_INFO_URLS_KEY __NS_SYMBOL(AMBASSADOR_INFO_URLS_KEY)
#endif

#ifndef CAMPAIGN_UID_KEY
#define CAMPAIGN_UID_KEY __NS_SYMBOL(CAMPAIGN_UID_KEY)
#endif

#ifndef SHORT_CODE_KEY
#define SHORT_CODE_KEY __NS_SYMBOL(SHORT_CODE_KEY)
#endif

#ifndef SHORT_CODE_URL_KEY
#define SHORT_CODE_URL_KEY __NS_SYMBOL(SHORT_CODE_URL_KEY)
#endif

#ifndef AMB_IDENTIFY_URL
#define AMB_IDENTIFY_URL __NS_SYMBOL(AMB_IDENTIFY_URL)
#endif

#ifndef AMB_IDENTIFY_JS_VAR
#define AMB_IDENTIFY_JS_VAR __NS_SYMBOL(AMB_IDENTIFY_JS_VAR)
#endif

#ifndef AMB_IDENTIFY_SIGNAL_URL
#define AMB_IDENTIFY_SIGNAL_URL __NS_SYMBOL(AMB_IDENTIFY_SIGNAL_URL)
#endif

#ifndef AMB_IDENTIFY_SEND_URL
#define AMB_IDENTIFY_SEND_URL __NS_SYMBOL(AMB_IDENTIFY_SEND_URL)
#endif

#ifndef AMB_INSIGHTS_URL
#define AMB_INSIGHTS_URL __NS_SYMBOL(AMB_INSIGHTS_URL)
#endif

#ifndef SEND_IDENTIFY_EMAIL_KEY
#define SEND_IDENTIFY_EMAIL_KEY __NS_SYMBOL(SEND_IDENTIFY_EMAIL_KEY)
#endif

#ifndef SEND_IDENTIFY_FP_KEY
#define SEND_IDENTIFY_FP_KEY __NS_SYMBOL(SEND_IDENTIFY_FP_KEY)
#endif

#ifndef SEND_IDENTIFY_MBSY_SOURCE_KEY
#define SEND_IDENTIFY_MBSY_SOURCE_KEY __NS_SYMBOL(SEND_IDENTIFY_MBSY_SOURCE_KEY)
#endif

#ifndef SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY
#define SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY __NS_SYMBOL(SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY)
#endif

#ifndef SEND_IDENTIFY_SOURCE_KEY
#define SEND_IDENTIFY_SOURCE_KEY __NS_SYMBOL(SEND_IDENTIFY_SOURCE_KEY)
#endif

#ifndef PUSHER_AUTH_AUTHTYPE_KEY
#define PUSHER_AUTH_AUTHTYPE_KEY __NS_SYMBOL(PUSHER_AUTH_AUTHTYPE_KEY)
#endif

#ifndef PUSHER_AUTH_CHANNEL_KEY
#define PUSHER_AUTH_CHANNEL_KEY __NS_SYMBOL(PUSHER_AUTH_CHANNEL_KEY)
#endif

#ifndef PUSHER_AUTH_SOCKET_ID_KEY
#define PUSHER_AUTH_SOCKET_ID_KEY __NS_SYMBOL(PUSHER_AUTH_SOCKET_ID_KEY)
#endif

#ifndef AMB_IDENTIFY_RETRY_TIME
#define AMB_IDENTIFY_RETRY_TIME __NS_SYMBOL(AMB_IDENTIFY_RETRY_TIME)
#endif

#ifndef CONTACT_CELL_IDENTIFIER
#define CONTACT_CELL_IDENTIFIER __NS_SYMBOL(CONTACT_CELL_IDENTIFIER)
#endif

#ifndef SELECTED_CELL_IDENTIFIER
#define SELECTED_CELL_IDENTIFIER __NS_SYMBOL(SELECTED_CELL_IDENTIFIER)
#endif

#ifndef NAME_PROMPT_SEGUE_IDENTIFIER
#define NAME_PROMPT_SEGUE_IDENTIFIER __NS_SYMBOL(NAME_PROMPT_SEGUE_IDENTIFIER)
#endif

#ifndef COMPOSE_MESSAGE_VIEW_HEIGHT
#define COMPOSE_MESSAGE_VIEW_HEIGHT __NS_SYMBOL(COMPOSE_MESSAGE_VIEW_HEIGHT)
#endif

#ifndef SEND_BUTTON_HEIGHT
#define SEND_BUTTON_HEIGHT __NS_SYMBOL(SEND_BUTTON_HEIGHT)
#endif

#ifndef SRWebSocketErrorDomain
#define SRWebSocketErrorDomain __NS_SYMBOL(SRWebSocketErrorDomain)
#endif

#ifndef CELL_IDENTIFIER
#define CELL_IDENTIFIER __NS_SYMBOL(CELL_IDENTIFIER)
#endif

#ifndef CONTACT_SELECTOR_SEGUE
#define CONTACT_SELECTOR_SEGUE __NS_SYMBOL(CONTACT_SELECTOR_SEGUE)
#endif

#ifndef LKND_AUTHORIZE_SEGUE
#define LKND_AUTHORIZE_SEGUE __NS_SYMBOL(LKND_AUTHORIZE_SEGUE)
#endif

#ifndef CELL_BORDER_WIDTH
#define CELL_BORDER_WIDTH __NS_SYMBOL(CELL_BORDER_WIDTH)
#endif

#ifndef CELL_CORNER_RADIUS
#define CELL_CORNER_RADIUS __NS_SYMBOL(CELL_CORNER_RADIUS)
#endif

