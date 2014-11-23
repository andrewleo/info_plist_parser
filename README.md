# InfoPlistParser

A gem for parsing info.plist in Apple ipa.

## Installation

First of all, make sure the 'unzip' command is available. 

    apt-get install unzip (Linux)
    brew install unzip (Mac)
    
    
Add this line to your application's Gemfile:

    gem 'rubyzip'
    gem 'plist'

And then execute:

    $ bundle install

## Usage

    info_plist = InfoPlistParser::AttrParser.new(IPA_PATH)
    info_plist.version
    info_plist.app_name
    info_plist.bundle_identifier
    info_plist.target_os_version
    info_plist.minimum_os_version
    info_plist.read_icon_file(saved_file_path)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/info_plist_parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request