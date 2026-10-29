# QcSdkUnityBridgeSwift

QC 海外 iOS SDK 的 Unity iOS Swift 桥接模块，以预编译静态 XCFramework 通过 Swift Package Manager（SPM）分发，不提供业务实现源码。

## 环境要求

- iOS 17.0 或以上，使用支持 Swift 6.2 的完整 Xcode。
- 当前制品覆盖 iOS 真机 arm64 和模拟器 arm64，不包含 Intel 模拟器 x86_64。
- App / Unity 实际链接 SDK 的 Target 必须满足相同最低系统要求。

## 模块依赖

| 类型 | 自动带入的产品 |
|---|---|
| 自有模块 | `QcSdkCore` |
| 官方第三方 | 无 |

依赖关系和版本以分发 `Package.swift` 为准。无需手动重复添加这些产品；多个功能包使用同一 Core 仓库和兼容的 Core exact 版本。不要把各模块的版本号相同理解为可以忽略依赖约束。

## 在 Xcode 中集成

1. 选择 **File → Add Package Dependencies…**，输入：

   ```text
   https://github.com/YuFengChen77/QcSdkUnityBridgeSwift.git
   ```

2. 在本仓库 Releases 中选择所需的已发布版本，Dependency Rule 使用 **Exact Version**。
3. 选择 **QcSdkUnityBridgeSwift** 产品，将 Add to Target 设为实际使用 SDK 的 App Target；Unity 通常为 `UnityFramework`。
4. 在该 Target 的 **Build Settings → Other Linker Flags** 保留原有值并添加：

   ```text
   $(inherited) -ObjC
   ```

5. 确认最低部署版本为 iOS 17.0 或以上，编译并运行。

SPM 自动下载 Release 中的 XCFramework ZIP、校验 checksum 并链接；不要再手动拖入同一 Framework。只有 README、尚无有效 tag / Package.swift / Release ZIP 的仓库还不能作为已发布 SDK 接入。

## 接入验证

下面仅验证模块可导入、反射类保留，不发起真实业务：

```swift
import Foundation
import QcSdkCore
import QcSdkUnityBridgeSwift

precondition(NSClassFromString("QcSdkUnityBridge") != nil)
precondition(NSClassFromString("QcUnityAppControllerManager") != nil)
```

`-ObjC` 缺失可能使只通过类名访问的实现被裁掉。业务通过 SDK 公开入口调用，不直接依赖内部实现类；通过编译和反射检查后，仍需完成本模块配置及业务联调。

## Unity 宿主接入

本模块提供 Swift / Objective-C 可调用的 Unity 桥接及生命周期代理入口，依赖 Core。Unity 侧 C# / Objective-C++ 胶水代码由宿主工程按现有桥接契约接入；仅添加这个 SPM 产品不会自动生成 Unity 侧代码。

1. 在导出的 Xcode 工程中，把产品添加到实际链接 SDK 的 Target，通常为 `UnityFramework`；在该 Target 添加 `$(inherited) -ObjC`。
2. 将 App 启动、URL 回跳及 Unity 启动等对应生命周期交给既有 `QcUnityAppControllerManager.shared` 入口；不要让多条转发链重复初始化 Core。
3. 通过现有 `QcSdkUnityBridge` 协议入口发送 Unity 命令，并正确注册 iOS → Unity 回调。回调注册前的缓存机制不替代宿主正确绑定监听器。
4. 有自定义代理时，在宿主 Info.plist 的 `QcUnityAppControllerProxyClass` 配置真实可反射的完整类名，并链接包含该类的产品；未配置时按实现回退默认代理。
5. Google、Facebook、Kakao、X、分享和统计仍按所需功能另选对应 SPM 包，不会因为集成桥接模块就全部引入。

在隐私同意及宿主约定的时机使用既有 SDK 初始化入口。需联调 Unity 消息收发、回调线程、启动顺序、前后台和 URL 回跳，最后验证真实 Unity 导出宿主；原生最小 App 的编译不能代替 Unity 验收。

## 启动与生命周期

将 SDK 的启动事件合并进宿主已有 AppDelegate：`QcSdkApi.shared.application(_:didFinishLaunchingWithOptions:)`。它负责基础准备和插件发现，不能替代业务 `sdkInit`。沿用 `QcSdkApi.shared.sdkInit(...)` 及现有 delegate；初始化成功后再调用需要初始化结果的业务 API。

涉及 URL 回跳时，普通 App / Unity 转发 `QcSdkApi.shared.application(_:open:options:)`，Scene 宿主转发 `QcSdkApi.shared.scene(_:openURLContexts:)`。保留其他 SDK 的已有处理，按宿主实际入口转发，避免重复初始化和丢失回跳。Unity 宿主通过既有桥接管理器统一转发时，不要再重复调用同一条 Core 链路。

## 资源与分发目录

```text
Package.swift
README.md
QcSdkUnityBridgeSwift/
└── Sources/
    └── Dependencies.swift
```

`Sources/Dependencies.swift` 只组织导入，不包含业务实现；辅助 target 为 `QcSdkUnityBridgeSwiftSupport`。接入方选择和导入的仍是 `QcSdkUnityBridgeSwift`，不需要额外选择 Support 产品。本模块没有独立资源声明；Core 的图片、字体、多语言和隐私资源由 Core 的资源 bundle 提供。

Xcode 左侧未显示 XCFramework 不代表下载失败，文件通常位于工程 DerivedData 的 `SourcePackages/artifacts`。以包解析、Target 产品链接、构建和运行结果确认接入；不要为显示节点重复手动集成。

## 更新版本

1. 在 **PROJECT → 工程名 → Package Dependencies** 找到 `QcSdkUnityBridgeSwift`，修改 Exact Version 为新的已发布版本。
2. 等待解析下载，必要时执行 **File → Packages → Resolve Package Versions**。
3. 核对其他模块的 Core exact 要求兼容，重新编译并联调。

无需删除依赖、手动替换 Framework 或改 import。已发布版本的 tag、提交、ZIP 和 checksum 固定；出现 `does not match previously recorded value` 或 checksum 冲突时联系维护者使用新版本，不关闭校验。

## 注意事项

- 自有 SDK 为静态链接，不重复同时集成手动 Framework 和 SPM 产品，不手工将自有静态 Framework 设置为 Embed & Sign。第三方若含动态依赖，由最终 App 正常嵌入和签名。
- 包解析与反射检查不代表业务验收完成；仍需验证Unity 消息收发、生命周期及初始化回调。
- SDK 的资源和公开 `.swiftinterface` / Objective-C 头文件可以查看，但不包含业务实现源码。
- 不将 Client Secret、服务端密钥、授权 token 或内部日志提交到公开仓库。
- Core 通用集成和业务配置另见 [QcSdkCore README](https://github.com/YuFengChen77/QcSdkCore#readme)。

本文件在开发仓库的 `QcSdkUnityBridgeSwift/README.md` 维护，生成分发包时自动复制；依赖声明仍以根 `Package.swift` 和本次发布清单为准。
