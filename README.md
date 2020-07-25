#  Locus

**Merriam-Webster dictionary -** _1a: the place where something is situated or occurs. 1b: a center of activity, attention, or concentration. **2: the set of all points whose location is determined by stated conditions** 3: the position in a chromosome of a particular gene or allele.__

*… or 4: An iOS API for managing an applications settings.*

## So what is Locus…?

Locus is an API for managing applications settings. It facilitates loading settings from local and remote configuration files, local user defaults and hard coded values in code. It validates and secures settings through a simple API that ensures consistency when accessing settings whilst it manages the complexity for your. 

## Features

* Container driven repositories to manage application settings.
* Auto-registration of `Root.plist` defaults.
* Access control to ensure settings are used as intended.
* Release locked settings which are only writable in debug configurations.
* Domains for related settings.
* Pre-configured and custom loaders for reading settings from local and remote sources.
* Duplicate and orphan settings detection.
* Protocol driven design for extensibilty.

# Quick guide

Although Locus is protocol driven and extremely flexible in how you can use it the following examples show just how easy it is to use. 

## Step 1: Define your settings in a protocol

In this example we'll define some basic settings for accessing a server in a protocol like this:

```swift
protocol MyApplicationSettings {
    var serverUrl: URL { get }
    var path: String { get } 
    var timeout: Int { get }
}
```

## Step 2: Define your setting keys

Next we need the keys that the settings are to be stored under. Typically these would also match any keys used in preferences if you're making them editable in that way. You can define the keys in a variety of ways (plain old hard coded `"String.key"` values for example) but it's nicer to use an enum like this:

```swift
enum SettingKey: String {
    case serverUrl = "server.url"
    case path = "server.query.path"
    case timeout = "server.timeout"
} 
```

Locus has a full set of function overrides that take `RawRepresentable` keys as well as `String` keys just to make things easier.

## Step 3: Create the settings container

Locus uses a container to manage settings and there are several options here: we can manually setup one, use a `.shared` instance, or create multiple containers if that suites the app. For this guide we'll manually create one like this: 

```swift
let locus: SettingsContainer = LocusContainer()
```

_Another useful technique to employee, especially in large applications, is to employ a DI framework such as [Swinject](https://github.com/Swinject/Swinject) or [Resolver](https://github.com/hmlongco/Resolver) to manage not just the Locus container, but other shared objects as well._

## Step 4: Register your settings.

Now that we have our container we need to register the settings and some /default values.

_Locus is built on the architectural idea that every setting has a default value. That value can be overridden by subsequently loading a new default or values stored in user defaults or configuration files, but it must have a default._

The simplest way to register settings with a container is to call the `.register(...)` function like this:

```swift
locus.register(key: SettingKey.serverUrl, value: URL(string: "http://nyserver.com")!)
locus.register(key: SettingKey.timeout, value: 30.0)
locus.register(key: SettingKey.path, value: "/hello")
```

By default `.register(...)` assigns a `.readonly` access level to settings. If you later try to change the values, Locus it will trigger a fatal error. This was a deliberate decision to help developers catch situations where they are modifying something they 
shouldn't be. _See later in this document for how you can change a setting's access level._

## Step 5: Load configuration file

In larger apps we often want to update settings from a JSON file or plist stored locally or on a remote server. To do this we setup and run some loaders using the container's `.load(...)` function like this during the application's startup:

```swift
let remoteUrl = URL("http://abc.com/config.json")!
locus.load(from: EmbeddedJSONFile("config.json"), RemoteJSONFileLoader(url: remoteUrl))
```

## Step 6: Accessing settings

Now we've got our settings configured and loaded. So all we have to do is access them:

```swift
let url: URL = locus.resolve(SettingKey.serverUrl)
let timeout: NSTimeInterval = locus.resolve(SettingKey.timeout)
let path: String = locus.resolve(SettingKey.path)
```

Locus also supports subscripts so this works too:

```swift
let url: URL = locus[SettingKey.serverUrl]
let timeout: NSTimeInterval = locus[SettingKey.timeout]
let path: String = locus[.SettingKey.path]
```

