# OpenAI and Prompt Engineering

## Python SDK

`from openai import OpenAI`

The Python SDK (openai package) abstracts API calls, providing convenient functions like `chat.completions.create` You simply specify parameters, and the SDK handles request setup, error handling, and parsing.

## SwiftUI OpenAI API through HTTP requests

Swift does not have an official OpenAI SDK, so you use native networking tools like `URLSession` to manually set up and send HTTP requests. This requires additional steps to construct the request, add headers, serialize data into JSON, and parse responses manually.

- `Info.plist`: 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
</dict>
</plist>
```
>In iOS, secure storage of sensitive data (like API keys) requires handling through Keychain, .plist files (in development), or scheme's environment variables configured in Xcode, which adds complexity.

![](./images/openai-swift1.png)

>Swift heavily uses async calls for network operations, typically requiring `DispatchQueue.main.async` to update UI from background tasks. 

## References

- [openAI-guide](https://platform.openai.com/docs/overview)
	- [text](https://platform.openai.com/docs/guides/text-generation)
	- [image](https://platform.openai.com/docs/guides/images)
	- [vision](https://platform.openai.com/docs/guides/vision)
- [Embeddings](https://platform.openai.com/docs/guides/embeddings)
- [api-reference](https://platform.openai.com/docs/api-reference/introduction)
