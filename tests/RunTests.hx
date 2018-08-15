package ;

import grest.auth.*;
using haxe.Json;
using sys.io.File;

class RunTests {

  static function main() {
    var pusher = new pushx.fcm.FcmPusher({
      authenticator: new ServiceAccountAuthenticator(Sys.getEnv('SERVICE_ACCOUNT').parse(), ['https://www.googleapis.com/auth/firebase.messaging']),
      projectId: Sys.getEnv('PROJECT_ID'),
      toMessage: _ -> {
        notification: {
          title:'Pushx',
          body:'Pushx Message',
        }
      },
    });
    var id = Sys.getEnv('FCM_TOKEN');
    pusher.single(id, 1).handle(function(o) {
      switch o {
        case Success(v):
          trace('success');
        case Failure(e): 
          trace(e.message);
          switch e.data {
            case Others(e): trace(e.message); trace(e.data);
            case e: trace(e);
          }
      }
      travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
    });
  }
  
}