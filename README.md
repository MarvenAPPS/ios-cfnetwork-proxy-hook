# iOS CFNetwork Proxy Hook

A dynamic library (dylib) for iOS 18+ that intercepts CFNetwork API calls and forces network traffic through a custom HTTP proxy. Features a floating toggle button for easy on/off control.

## Features

- **Floating Toggle Button**: Draggable button that appears in any injected app
- **Proxy Toggle**: Easy on/off switch to enable/disable proxy interception
- **CFNetwork Hooking**: Intercepts all major CFNetwork methods including:
  - `CFReadStreamCreateForHTTPRequest`
  - `CFHTTPMessageCreateRequest`
  - `CFURLCache`
  - `CFURLSession` (iOS 18+ APIs)
- **Settings GUI**: Full configuration panel for proxy settings

## Requirements

- iOS 15.0+ (Compiled for iOS 18+)
- Theos or Xcode toolchain
- Jailbroken device or injection framework (e.g., ElleKit, libhooker, TrollStore)
- macOS or Linux for building

## Building

### Using VS Code

1. Open the project in VS Code
2. Press `Cmd+Shift+B` (macOS) or `Ctrl+Shift+B` (Linux/Windows)
3. Select `Build dylib (Debug)` or `Build dylib (Release)`

### Using Command Line

```bash
# Clone the repository
git clone https://github.com/MarvenAPPS/ios-cfnetwork-proxy-hook.git
cd ios-cfnetwork-proxy-hook

# Build the dylib
make

# Or build with Theos
make -f Makefile.theos
```

## Installation

### Method 1: TrollStore (Recommended for iOS 18+)
Inject using ElleKit or similar framework.

### Method 2: Jailbreak
Copy the dylib to `/var/jb/usr/lib/TweakInject/` or equivalent path.

### Method 3: Manual Injection
Use `insert_dylib` or a custom loader to inject into target app.

## Configuration

Edit `src/ProxySettings.h` to set default proxy settings:

```objc
#define DEFAULT_PROXY_HOST @"127.0.0.1"
#define DEFAULT_PROXY_PORT 8080
```

## Usage

1. Inject the dylib into target app
2. Tap the floating button (default: top-right corner)
3. Toggle the switch to enable proxy interception
4. Configure proxy settings via the settings button

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      Target App                         │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │ Floating UI │  │ Proxy Hook  │  │ Settings Panel  │ │
│  │   Button    │  │   Engine    │  │                 │ │
│  └──────┬──────┘  └──────┬──────┘  └─────────────────┘ │
│         │                │                              │
│         └────────────────┘                              │
│                   │                                     │
│              ┌────┴────┐                                │
│              │ Toggle  │                                │
│              └────┬────┘                                │
│                   │                                     │
│         ┌─────────┴──────────┐                         │
│         ▼                      ▼                        │
│  ┌─────────────┐      ┌───────────────┐                │
│  │ CFNetwork   │      │ Original      │                │
│  │ Hooks       │      │ Network Flow  │                │
│  │ (when ON)   │      │ (when OFF)    │                │
│  └──────┬──────┘      └───────────────┘                │
│         │                                               │
│         ▼                                               │
│  ┌─────────────┐                                       │
│  │ HTTP Proxy  │                                       │
│  └─────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

## Hooked Methods

### CFNetwork Core

| Method | Description |
|--------|-------------|
| `CFReadStreamCreateForHTTPRequest` | Creates HTTP read stream |
| `CFHTTPMessageCreateRequest` | Creates HTTP request message |
| `CFHTTPMessageSetHeaderFieldValue` | Sets HTTP headers |
| `CFReadStreamOpen` | Opens read stream |

### NSURLSession (via swizzling)

| Method | Description |
|--------|-------------|
| `dataTaskWithRequest:` | Creates data task |
| `uploadTaskWithRequest:` | Creates upload task |
| `downloadTaskWithRequest:` | Creates download task |

### CFURLCache

| Method | Description |
|--------|-------------|
| `CFURLCacheSetMemoryCapacity` | Cache configuration |

## Security Considerations

- This tool is for **educational and debugging purposes only**
- Only use on apps you own or have permission to modify
- Be aware of local laws and app terms of service
- Proxy traffic may be detectable by sophisticated apps

## Troubleshooting

### dylib not loading
- Check architecture compatibility (arm64/arm64e)
- Verify code signing
- Check injection method logs

### Proxy not working
- Verify proxy server is running and accessible
- Check firewall settings
- Some apps may use certificate pinning

### Button not appearing
- Check that the app uses UIKit
- Verify the view controller hierarchy
- Check console logs for errors

## Contributing

Contributions are welcome! Please submit pull requests or open issues.

## License

MIT License - See LICENSE file for details

## Disclaimer

This tool is provided as-is for educational purposes. The authors are not responsible for any misuse or damage caused by this software.

## Credits

- Built with [Theos](https://github.com/theos/theos)
- Inspired by various iOS networking research projects
