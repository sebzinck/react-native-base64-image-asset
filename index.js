import { NativeModules, Platform } from 'react-native';

const B64ImageAsset = NativeModules.B64ImageAsset;

const _readB64Image = options => {
  return B64ImageAsset.readB64Image(options);
};

export const readB64Image = options => {
  if (Platform.OS === 'ios') {
	return _readB64Image(options);
  }
};
