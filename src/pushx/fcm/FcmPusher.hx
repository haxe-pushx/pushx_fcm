package pushx.fcm;

class FcmPusher<Data> extends pushx.gcm.GcmPusher<Data> {
	public function new(key) {
		super(key);
		url = 'https://fcm.googleapis.com/fcm/send';
	}
}