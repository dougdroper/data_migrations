namespace :db do
  namespace :data do
    task :up => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      DataMigrations::DataMigrator.run(:up, DataMigrations::DATA_MIGRATION_DIR, version)
    end
    
    task :down => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      DataMigrations::DataMigrator.run(:down, DataMigrations::DATA_MIGRATION_DIR, version)
    end
    
    task :rollback => :environment do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      DataMigrations::DataMigrator.rollback(DataMigrations::DATA_MIGRATION_DIR, step)
    end
    
    task :migrate => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      DataMigrations::DataMigrator.migrate(DataMigrations::DATA_MIGRATION_DIR, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
    
    task :redo => :environment do
      if ENV["VERSION"]
        Rake::Task["db:data:down"].invoke
        Rake::Task["db:data:up"].invoke
      else
        Rake::Task["db:data:rollback"].invoke
        Rake::Task["db:data:migrate"].invoke
      end
    end
  end
  
  namespace :data_migrations do
    desc "Apply data migrations in the folder 'db/data_migrations' up to VERSION."
    task :apply => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      DataMigrations::DataMigrator.migrate(DataMigrations::DATA_MIGRATION_DIR, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end
end
