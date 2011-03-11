module LolitaComments
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.join(File.dirname(__FILE__),"templates")
      
      def copy_migrations
        if defined?(ActiveRecord)
          filename="#{Time.now.strftime("%Y%m%d%H%M%S")}_lolita_create_comments.rb"
          exist=Dir.new(File.join(Rails.root,"db","migrate")).detect{|f| 
            f.match(/\d{14}_lolita_create_comments\.rb/)
          }
          if exist
            print "Migration already exit #{filename}! Create new? [Yn] "
            do_copy=gets
            do_copy=do_copy=="Y" || do_copy=="y" ? true : false
          else 
            do_copy=true
          end
          template "migration.rb", "db/migrate/#{filename}" if do_copy
        end
      end

    end
  end
end