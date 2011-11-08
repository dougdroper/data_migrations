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

    desc "Run Data Migrations"
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

    desc "Current version"
    task :version => :environment do
      dm_table = 'data_migrations'
      version = "Unknown"
      if ActiveRecord::Base.connection.table_exists?(dm_table)
        version = ActiveRecord::Base.connection.select_values("SELECT version FROM #{dm_table}").map(&:to_i).sort.max || 0
      end
      puts "Current version: #{version}"
    end

    desc "Raises an error if there are pending data migrations"
    task :abort_if_pending_migrations => :environment do
      pending_migrations = DataMigrations::DataMigrator.new(:up, 'db/migrate').pending_migrations

      if pending_migrations.any?
        puts "You have #{pending_migrations.size} pending migrations:"
        pending_migrations.each do |pending_migration|
          puts '  %4d %s' % [pending_migration.version, pending_migration.name]
        end
        abort %{Run "rake db:data:migrate" to update your database then try again.}
      end
    end
  end

end
