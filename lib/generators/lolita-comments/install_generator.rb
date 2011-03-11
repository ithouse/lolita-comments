module LolitaComments
  module Generators
    class InstallGenerator < Rails::Generators::Base

      @@root=File.expand_path("#{__FILE__}/../../../..")
      
      hook_for :orm
      
      def copy_migrations
        copy_dir(File.join("db","migrate"),:root=>@@root) if orm==:active_record
      end
      
      private

      def copy_dir(source,options={})
        root_dir=File.join(options[:root],source)
        Dir[File.join(root_dir, "**/*")].each do |file|
          relative = file.gsub(/^#{root_dir}\//, '')
          if File.file?(file)
            copy_file file, File.join(Rails.root, source, relative)
          end
        end
      end

      def file_exists? path
        File.exists?(File.join(destination_root, path))
      end
    end
  end
end