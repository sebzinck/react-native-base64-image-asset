# react-native-b64-image-asset

import {call} from 'redux-saga/effects'
import {NativeModules, Platform} from 'react-native'
const B64ImageAsset = NativeModules.B64ImageAsset;

if (Platform.OS === "ios") {
	try {
		b64 = yield call(B64ImageAsset.readB64Image, localidentifier)
	}catch(e){	
		console.log(e)
	}
}
