polyv-ios-client-demo
=====================
参考 POLYV iOS SDK 集成指南 https://github.com/easefun/polyv-ios-sdk/wiki

#### API 文档
- [v1.2.0](https://demo.polyv.net/polyv/ios/sdk/1.2.0/doc/index.html)

## ATS 支持

保利威视点播 iOS SDK 现已全面支持 ATS（App Transport Security），所有 API 都已使用 HTTPS 请求。用户需使用最新版本 SDK 即可完成升级。

## 新版本 SDK 使用

在项目 info.plist 中添加以下内容：

```xml
	<!-- 添加配置 -->
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>localhost</key>
			<dict>
				<key>NSTemporaryExceptionAllowsInsecureHTTPSLoads</key>
				<false/>
				<key>NSIncludesSubdomains</key>
				<true/>
				<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSTemporaryExceptionMinimumTLSVersion</key>
				<string>1.0</string>
				<key>NSTemporaryExceptionRequiresForwardSecrecy</key>
				<false/>
			</dict>
		</dict>
		<!-- 项目还有 HTTP 请求，或开启 HttpDNS 功能，保留以下配置 -->
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
```

若您的项目还有 HTTP 请求，或开启 HttpDNS 功能，应保留以下配置：

```xml
		<key>NSAllowsArbitraryLoads</key>
		<true/>
```

## HttpDNS 支持

保利威视点播 SDK 播放及下载现已支持 HttpDNS。

> 移动解析（HttpDNS）基于Http协议向指定的DNS服务器发送域名解析请求，替代了基于DNS协议向运营商Local DNS发起解析请求的传统方式，可以避免Local DNS造成的域名劫持和跨网访问问题，解决移动互联网服务中域名解析异常带来的困扰。

默认为关闭状态，开启只需设置 `PolyvSettings` 单例对象的 `httpDNSEnable` 为 `YES` 即可。具体参照[集成指南](https://github.com/easefun/polyv-ios-sdk/wiki)。