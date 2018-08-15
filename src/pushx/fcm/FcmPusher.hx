package pushx.fcm;

import pushx.ErrorType;
import grest.*;
import haxe.DynamicAccess;
import tink.http.clients.*;
import tink.web.proxy.Remote;
import tink.url.Host;

using tink.CoreApi;

class FcmPusher<T> extends pushx.BasePusher<T> {
	var projectId:String;
	var toMessage:T->InputMessage;
	var remote:Remote<Api>;
	
	public function new(options:Options<T>) {
		projectId = options.projectId;
		toMessage = options.toMessage;
		remote = new Remote<Api>(
			new AuthedClient(options.authenticator, new SecureNodeClient(), Header),
			new RemoteEndpoint(new Host('fcm.googleapis.com', 443)).sub({path: ['v1']})
		);
	}
	
	override function single(id:String, data:T):Surprise<Noise, TypedError<ErrorType>> {
		var message:RealInputMessage = cast toMessage(data);
		message.token = id;
		return send(message);
	}
	
	override function topic(topic:String, data:T):Surprise<Noise, TypedError<ErrorType>> {
		var message:RealInputMessage = cast toMessage(data);
		message.topic = topic;
		return send(message);
	}
	
	function send(message:RealInputMessage) {
		trace(message);
		return remote.send(projectId, {message: message})
			.map(function(o) return switch o {
				case Success({error_code: null}): Success(Noise);
				case Success({error_code: code}): Failure(Error.typed('Send Error', Others(new Error(code))));
				case Failure(e): Failure(Error.typed('Send Failed', Others(e)));
			});
	}
}

interface Api {
	@:post('/projects/$projectId/messages:send')
	function send(projectId:String, body:RequestBody):Promise<OutputMessage>;
}

typedef Options<T> = {
	authenticator:Authenticator,
	projectId:String,
	toMessage:T->InputMessage,
}

typedef RequestBody = {
	?validate_only:Bool,
	message:RealInputMessage,
}

typedef InputMessage = {
	?data:DynamicAccess<String>,
	?notification:Notification,
	?android:AndroidConfig,
	?webpush:WebpushConfig,
	?apns:ApnsConfig,
}

typedef RealInputMessage = {
	> Message,
	> InputMessage,
}

typedef OutputMessage = {
	> Message,
	name:String,
	?error_code:FcmErrorCode,
}

@:enum abstract FcmErrorCode(String) to String {
	var UnspecifiedError = 'UNSPECIFIED_ERROR';
	var InvalidArgument = 'INVALID_ARGUMENT';
	var Unregistered = 'UNREGISTERED';
	var SenderIdMismatch = 'SENDER_ID_MISMATCH';
	var QuotaExceeded = 'QUOTA_EXCEEDED';
	var ApnsAuthError = 'APNS_AUTH_ERROR';
	var Unavailable = 'UNAVAILABLE';
	var Internal = 'INTERNAL';
}

typedef Message = {
	?token:String,
	?topic:String,
	?condition:String,
}

typedef Notification = {
	title:String,
	body:String,
}

typedef AndroidConfig = {
	?collapse_key:String,
	?priority:AndroidMessagePriority,
	?ttl:String,
	?restricted_package_name:String,
	?data:DynamicAccess<String>,
	?notification:AndroidNotification,
}

@:enum abstract AndroidMessagePriority(String) to String {
	var Normal = 'NORMAL';
	var High = 'HIGH';
}

typedef AndroidNotification = {
	?title:String,
	?body:String,
	?icon:String,
	?color:String,
	?sound:String,
	?tag:String,
	?click_action:String,
	?body_loc_key:String,
	?body_loc_args:Array<String>,
	?title_loc_key:String,
	?title_loc_args:Array<String>,
}

typedef WebpushConfig = {
	?headers:DynamicAccess<String>,
	?data:DynamicAccess<String>,
	?notification:Dynamic, // TODO
	?fcm_options:WebpushFcmOptions,
}

typedef WebpushFcmOptions = {
	link:String,
}

typedef ApnsConfig = {
	?headers:DynamicAccess<String>,
	?payload:DynamicAccess<Dynamic>, // TODO
}
