#  Locus

_Merriam-Webster dictionary -
1a: the place where something is situated or occurs.
1b: a center of activity, attention, or concentration.
**2: the set of all points whose location is determined by stated conditions**
3: the position in a chromosome of a particular gene or allele._

_… or 4: An iOS API for managing an applications settings._

## So what is Locus… really.

Locus is an API for managing an applications settings. It was built as a response to the complexities of managing settings in larger applications which are often sourced from local and remote configuration files, local user defaults and hard coded values scattered through out the code. Mix in the complexities of dealing with settings for multiple APIs and the fact that the code has been written over a long period of time by numerous developers using different techniques and the results can be messy, inconsistent, hard to understand and difficult to maintain.

Locus solves these problems with a simple API that lets you manage all your settings in a consistent manner whilst it deals with the complexity. 

## Features

* Central container for all application settings.
* Auto-registration of `Root.plist` defaults.
* Access control scope to ensure settings are used appropriately.
* Release locked scope for settings which are writable until release.
* Optional domains for grouping related settings.
* A variety of loaders for reading settings from local and remote sources.
* Reset to default.
* Duplicate setting detection.
* Protocol driven design.

# Quick guide

Although Locus is protocol driven and therefore extremely flexible in how you use it, the following is perhaps the simplest way to implement your settings with it. In this example I'll define some basic settings for accessing a server.

## Step 1: Define your settings in a protocol

Simply create your own protocol like this:

```swift
protocol MyApplicationSettings {
    var serverUrl: URL { get }
    var path: String { get } 
    var timeout: Int { get }
}
```

There is nothing special about this protocol. It's just how you'd typically define a source of values.

## Step 2: Define your setting keys

Next you need to define the keys that unique identify each setting. You can do this in a variety of ways (plain old hard coded `String` values for example), but it's nicer to use an enum like this:

```swift
enum SettingKey: String {
    case serverUrl = "server.url"
    case path = "server.query.path"
    case timeout = "server.timeout"
} 
```

Note that the enum has to be a `String` enum where the raw values are the keys that Locus will use to locate and read the values.

## Step 3: Create the container

As per the feature list Locus uses a container instance to manage settings. You have several options here, you can manually setup one, use a `.shared` instance provided by Locus, or create multiple containers if that suites your needs. 

```swift
let locus: SettingsContainer = LocusContainer()
```

_Note: If I was to make a recommendation it would be to employ a DI framework such as [Swinject](https://github.com/Swinject/Swinject) or [Resolver](https://github.com/hmlongco/Resolver) and use that to manage your Locus instance. `.shared` is a convenience, but singletons are notoriously hard to test._

## Step 4: Register your settings.

This is where we tell Locus about the settings you have and their default values.

_Important: Locus is built on the assumption that every setting has a value. Therefore it always has a hard coded default for every setting which can be overridden by subsequently loaded configurations or values in user defaults._

Of course Locus provides a number of ways you can register you settings but the simplest is just to call the `.register(...)` function on the container.

```swift
locus.register(key: SettingKey.serverUrl, defaultValue: URL(string: "http://nyserver.com")!)
locus.register(key: SettingKey.timeout, defaultValue: 30.0)
locus.register(key: SettingKey.path, defaultValue: "/hello")
```

Note: By default `.register(...)` assigns a `.readonly`` scope to settings. If you later try to change the values, Locus it will trigger a fatal error. This was a deliberate decision to help developers catch situations where they are modifying something they 
shouldn't be. _See later in this document for how you can change a setting's scope._

## Step 5: (Optional) Load updated values

By default Locus assumes all settings have either hard coded values or values sourced from the applications user defaults. However you may want to load settings from a JSON configuration file, a plist or some other source, local or remote. You can do this by calling the `.load(...)` function like this:

```swift
Let remoteUrl = URL("http://abc.com/config.json")!
locus.load(from: EmbeddedJSONFile("config.json"), RemoteJSONFileLoader(url: remoteUrl))
```

## Step 6: Access the settings

This is the easy bit:

```swift
let url = locus.resolve(SettingKey.serverUrl)
let timeout = locus.resolve(SettingKey.timeout)
let path = locus.resolve(SettingKey.path)
```

Note that Locus also supports the use of subscripts, so this works too:

```swift
let url = locus[SettingKey.serverUrl]
let timeout = locus[SettingKey.timeout]
let path = locus[.SettingKey.path]
```

# Reference

## The container

## Registering settings

## Custom stores and factories

## Custom loaders