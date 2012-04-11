require 'rails/generators'
require 'rails/generators/migration'

class DataMigrationGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def manifest
    migration_template 'migration.rb', DataMigrations::DATA_MIGRATION_DIR + "/#{file_name}.rb"
  end
end
