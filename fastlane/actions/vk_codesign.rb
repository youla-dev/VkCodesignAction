require 'openssl'
require 'net/http'

module Fastlane
  module Actions

    class VkCodesignAction < Action

      def self.run(params)
        endpoint = params[:endpoint]
        cert = Pathname.new(params[:cert_path]).expand_path.realpath.to_s
        key = Pathname.new(params[:key_path]).expand_path.realpath.to_s
        archive_path = Pathname.new(params[:xcarchive_zip_path]).expand_path.realpath.to_s
        output_path = params[:output_path]

        # sh("curl -k -X POST -F file=@#{archive_path} --cert #{cert} --key #{key} #{endpoint} -o #{output_path}")

        options = {
          use_ssl: true,
          verify_mode: OpenSSL::SSL::VERIFY_NONE,
          cert: OpenSSL::X509::Certificate.new(File.read(cert)),
          key: OpenSSL::PKey::RSA.new(File.read(key)),
          read_timeout: 10*60
        }

        uri = URI.parse(endpoint)

        Net::HTTP.start(uri.host, uri.port, options) do |http|
          body = {
            "file" => UploadIO.new(File.open(archive_path), 'application/zip', File.basename(archive_path)),
          }

          # Create Request
          request =  Net::HTTP::Post::Multipart.new(uri, body)
          # Add headers
          request.add_field "Content-Type", "multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__"
          
          UI.important "Start uploading xcarchive..."
          http.request request do |response|
            UI.success "xcarchive uploaded"
            open output_path, 'w' do |io|
              response.read_body do |chunk|
                io.write chunk
              end
            end if response.is_a?(Net::HTTPSuccess)

            if response.is_a?(Net::HTTPSuccess)
              UI.success "Codesign successfull"
              output = Pathname.new(output_path).expand_path.realpath.to_s
              UI.success "ipa path #{output}"
            else
              UI.user_error!("Codesign error #{response.value} #{response.body}")
            end
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Codesign xcarchive via mail.ru codesign machine by vk certificate"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :cert_path,
                                       env_name: "VK_CODESIGN_SSL_CERT_PATH", 
                                       description: "SSL cert path", 
                                       verify_block: proc do |value|
                                          UI.user_error!("No SSL cert path for VKCodesignAction given, pass using `cert_path: 'path'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :key_path,
                                       env_name: "VK_CODESIGN_SSL_KEY_PATH", 
                                       description: "SSL key path", 
                                       verify_block: proc do |value|
                                          UI.user_error!("No SSL key path for VKCodesignAction given, pass using `key_path: 'path'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: "VK_CODESIGN_ENDPOINT", 
                                       description: "Codesign endpoint", 
                                       verify_block: proc do |value|
                                          UI.user_error!("No codesign endpoint for VKCodesignAction given, pass using `endpoint: 'url'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :xcarchive_zip_path,
                                       env_name: "VK_CODESIGN_SSL_XCARCHIVE_ZIP_PATH", 
                                       description: "xcarchive zip path", 
                                       verify_block: proc do |value|
                                          UI.user_error!("No xcarchive zip path for VKCodesignAction given, pass using `xcarchive_zip_path: 'path'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       env_name: "VK_CODESIGN_OUTPUT_IPA_PATH", 
                                       description: "output ipa path", 
                                       verify_block: proc do |value|
                                          UI.user_error!("No output ipa path for VKCodesignAction given, pass using `output_path: 'path'`") unless (value and not value.empty?)
                                       end),
        ]
      end

      def self.authors
        ["Aleksandr Skandakov"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
