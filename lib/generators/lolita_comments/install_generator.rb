require 'rails/generators/active_record'
module LolitaComments
  module Generators
    class InstallGenerator < ActiveRecord::Generators::Base

      @@root=File.expand_path("#{__FILE__}/../../../..")
      
      hook_for :orm
      
      def copy_migrations
        migration_template "migration.rb"
      end
      
    end
  end
end