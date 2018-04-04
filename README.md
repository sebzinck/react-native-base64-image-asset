
# react-native-base64-image-asset

> This package allows you to grab base64 data of an image from the iOs Photo Library based on its localIdentifier. It also allows to get the still representation of an LivePhoto.


## Install

```bash
npm i -S react-native-base64-image-asset
react-native link react-native-base64-image-asset
```

## Usage

 1. Get asset URI from CameraRoll https://facebook.github.io/react-native/docs/cameraroll.html
 2. Grab the localIdentifier from URI, then...
 
```javascript
import {readB64Image} from "react-native-base64-image-asset"
import {Platform} from "react-native"

if (Platform.OS === "ios") {
	const options = {
		localIdentifier,
		still: true
	}

	readB64Image(options).then(b64 => {
		/* Do your thing */
	}).catch(e => {
		console.log(e)
	})
}
```

## Supported options:

| Property        | Value   | Required                   | Default    | Note
| :-------------- | :------ | :------------------------- | :--------  | :----------
| localIdentifier | String  | Yes                        |            |
| still           | Bool    | No                         | false      | Set to true for LivePhoto still representation

## License

[MIT](http://vjpr.mit-license.org)