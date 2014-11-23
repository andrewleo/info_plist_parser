class Main

  require "info_plist_parser/version"
  require "info_plist_parser"
  require 'zip/zipfilesystem'
  require 'zip'
  require 'cfpropertylist'
  require 'pngdefry'

  include InfoPlistParser

  Dir.glob("../ipa_list/kik.ipa").each do |f|
    puts "---------------------------------------------------------------------------"
    puts "f====#{f}"
    parser = InfoPlistParser::AttrParser.new(f)
    puts "parser.version=#{parser.version}"
    puts "parser.app_name=#{parser.app_name}"
    puts "parser.bundle_identifier=#{parser.bundle_identifier}"
    puts "parser.minimum_os_version=#{parser.minimum_os_version}"
    puts "parser.icon_file_name=#{parser.icon_file_name}"
    parser.read_icon_file("#{f}-icon.png",true)
  end
end