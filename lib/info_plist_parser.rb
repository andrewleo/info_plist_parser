require "info_plist_parser/version"
require 'zip'
require 'cfpropertylist'
require 'pngdefry'

module InfoPlistParser
  class AttrParser
    attr_accessor :plist, :file_path

    def initialize(file_path)
      self.file_path = file_path
      info_plist_file = nil
      regex = /^[^\/]+\/[^\/]+.app\/Info.plist$/
      cf_plist = CFPropertyList::List.new(:data => read_file(regex), :format => CFPropertyList::List::FORMAT_AUTO)
      cf_plist = cf_plist.value.value
      plist_hash = {}
      cf_plist.keys.each do |key|
        plist_hash[key] = cf_plist[key].value
      end
      self.plist = plist_hash
    end

    # 获取app的版本
    def version
      cfbsv, cfbv, version = plist["CFBundleShortVersionString"], plist["CFBundleVersion"], ""
      version = "v" + cfbsv + " " if cfbsv != ""
      version = version + "build " + cfbv if cfbv != ""
      version
    end

    # 获取app的名称
    def app_name
      display_name = plist["CFBundleDisplayName"]
      if display_name.nil?
        display_name = plist["CFBundleName"]
      end
      display_name
    end

    # 获取app唯一标识，类似android中的包名
    def bundle_identifier
      plist["CFBundleIdentifier"]
    end

    # 获取app的目标系统版本
    def target_os_version
      plist["DTPlatformVersion"].match(/[\d\.]*/)[0]
    end

    # 获取app的最小系统版本
    def minimum_os_version
      plist["MinimumOSVersion"].match(/[\d\.]*/)[0]
    end

    # 获取ipa文件的文件结构
    def ipa_file_list
      file_list = []
      Zip::File.open(self.file_path) do |zip_file|
        zip_file.each do |entry|
          file_list << File.basename(entry.name)
        end
      end
      file_list
    end

    # 获取app的图标名称
    def icon_file_name
      file_list = ipa_file_list.select { |file| file.include? ".png" }
      icon_name = nil
      begin
        if plist["CFBundleIcons"] # 先读取CFBundleIcons字段，如果有则从此处读取图标名称
          begin
            primary_icons = plist["CFBundleIcons"]["CFBundlePrimaryIcon"]
            if primary_icons
              primary_value = primary_icons.value
              primary_icons = primary_value["CFBundleIconFiles"].value
              primary_icons.reverse.each do |icon|
                icon_name = icon.value
                if (icon_list = file_list.select { |file| file.start_with? icon_name }) && icon_list.size>0
                  return icon_list.first
                end
              end
            end
          rescue => err
            Rails.logger.warn "parse CFBundleIcons exception: #{err}"
            nil
          end
        end
        if plist["CFBundleIcons~ipad"]
          begin
            primary_icons = plist["CFBundleIcons~ipad"]["CFBundlePrimaryIcon"]
            if primary_icons
              primary_value = primary_icons.value
              primary_icons = primary_value["CFBundleIconFiles"].value
              primary_icons.reverse.each do |icon|
                icon_name = icon.value
                if (icon_list = file_list.select { |file| file.start_with? icon_name }) && icon_list.size>0
                  return icon_list.first
                end
              end
            end
          rescue => err
            Rails.logger.warn "parse CFBundleIcons~ipad exception: #{err}"
            nil
          end
        end
        # 首先判断 CFBundleIconFile 字段是否为空，为空则进入下个字段判断，否则查找文件是否存在，存在则返回，不存在则继续
        if plist["CFBundleIconFile"]
          icon_name = plist["CFBundleIconFile"]
          if (icon_list = file_list.select { |file| file.start_with? icon_name }) && icon_list.size>0
            return icon_list.first
          end
        end
        if plist["CFBundleIconFiles"]
          icon_files = plist["CFBundleIconFiles"]
          icon_files.reverse.each do |icon|
            icon_name = icon.value
            if (icon_list = file_list.select { |file| file.start_with? icon_name }) && icon_list.size>0
              return icon_list.first
            end
          end
        end
      rescue => ex
        Rails.logger.error "get icon_file_name exception: #{ex}"
      end
      nil
    end

    # ipa文件中icon的完整路径
    def icon_file_path
      file = ""
      if icon_file_name
        regex = /^[^\/]+\/[^\/]+.app\/#{icon_file_name}$/
        Zip::File.open(self.file_path) do |zip_file|
          zip_file.each do |entry|
            if entry.name.match(regex)
              file = entry.name
              break
            end
          end
        end
        file || nil
      else
        Rails.logger.error "***** icon_file_name is nil and please check the format of Info.plist *****"
        nil
      end
    end

    # 读取app图标至本地文件file_path中
    def read_icon_file(file_path, defry = false)
      icon_file = icon_file_name
      unless icon_file.nil?
        regex = /^[^\/]+\/[^\/]+.app\/#{icon_file}$/
        File.open(file_path, "wb") { |f| f.write(read_file(regex)) }
      end
      # 因为是ios的png图片，做过性能优化无法在web端直接显示，需要转化
      Pngdefry.defry(file_path, file_path) if file_path && defry
    end

    # 读取ipa中的文件
    def read_file(regex)
      file = nil
      Zip::File.open(self.file_path) do |zip_file|
        zip_file.each do |entry|
          file = entry if entry.name.match(regex)
        end
      end
      unless file.nil?
        file.get_input_stream.read
      else
        nil
      end
    end
  end
end
