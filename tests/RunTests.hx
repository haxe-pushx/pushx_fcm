package ;

class RunTests {

  static function main() {
    var key = Sys.getEnv('FCM_SERVER_KEY');
    trace(key);
    var pusher = new pushx.fcm.FcmPusher(key);
    var id = 'eaYz5bVA8AE:APA91bHDaJ7pRsxpyRWK2jyoLk56Y8oHyvaHQWYdSkoDRT_5ys7F4DEFRpzy27HhtRWAH_u-w9pXA8J70ubZVg3fkR9dnaQ0AdsAy2q8NY0em3w03ng6prrT1knKVGdbuJP2kSYtb5WW';
    pusher.single(id, {
      notification: {
        title: 'Title',
        body: 'BODY',
        icon: "firebase-logo.png",
        action: "http://localhost:8081"
      },
      data: {
        optional: 'custom data'
      }
    }).handle(function(o) {
      travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
    });
  }
  
}