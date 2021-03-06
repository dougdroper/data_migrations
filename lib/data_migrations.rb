module DataMigrations
  require "data_migrations/data_migrator"
  require "data_migrations/data_migrator_tasks"

  # Where data migrations are stored
  DATA_MIGRATION_DIR   = "db/data_migrations"

  # The table that records which data migrations have been run, like
  # schema_info
  DATA_MIGRATION_TABLE = "data_migrations"
end
