# Installing with Cocoapods

## Podfile
Firstly, download/clone the Chat SDK and copy the local directory path of this folder.
Then put the copied directory path and replace it with REPLACE_SDK_DIR, in your podfile.
Next, run the pod install like before.

```ruby
    # Define the base path
    BASE_DIR = 'REPLACE_SDK_DIR'

    # Define the other paths relative to BASE_DIR
    CHAT_DIR = File.join(BASE_DIR, 'Chat')
    BASE_PATH = File.join(CHAT_DIR, 'submodules')

    pod 'Additive', :path => "#{BASE_PATH}/Additive"
    pod 'Mocks', :path => "#{BASE_PATH}/Mocks"
    pod 'Additive', :path => "#{BASE_PATH}/Additive"
    pod 'Logger', :path => "#{BASE_PATH}/Logger"
    pod 'Async', :path => "#{BASE_PATH}/Async"
    pod 'ChatCore', :path => "#{BASE_PATH}/ChatCore"
    pod 'ChatModels', :path => "#{BASE_PATH}/ChatModels"
    pod 'ChatDTO', :path => "#{BASE_PATH}/ChatDTO"
    pod 'ChatTransceiver', :path => "#{BASE_PATH}/ChatTransceiver"
    pod 'ChatExtensions', :path => "#{BASE_PATH}/ChatExtensions"
    pod 'ChatCache', :path => "#{BASE_PATH}/ChatCache"
    pod 'Chat', :path => "#{CHAT_DIR}"
```
