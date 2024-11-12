# https://atlasgo.io/lint/analyzers
lint {
  non_linear {
    error = true
  }
  destructive {
      error = true
  }
  data_depend {
      error = true
  }
  concurrent_index {
      error = true
  }
  incompatible {
      error = true
  }
  naming {
      error   = true
      match   = "^[a-z_0-9]+$"
      message = "must be lowercase"
  }
}

variable "database_url" {
  type = string
  default = "postgres://postgres:pass@:5432/prod?sslmode=disable"
}

variable "dev_database_url" {
  type = string
  default = "postgres://postgres:pass@:5432/dev?sslmode=disable"
}

data "composite_schema" "project" {
  # User schema
  schema "org_user" {
    url = "file://config/schema/user.sql"
  }

  # Product schema
  schema "org_product" {
    url = "file://config/schema/product.sql"
  }

  # ----------------------------------
  # Function files specific to schema
  # ensure that name of schema is same
  # as above
  # ----------------------------------

  # Functions related to user schema
  schema "org_user" {
    url = "file://config/function/user_functions.sql"
  }
}

locals {
    schema_url = data.composite_schema.project.url
}

# environment block
# refer https://atlasgo.io/atlas-schema/projects
env "common" {
  # Define the URL of the database which is managed
  # in this environment
  url = var.database_url

  # define the URL of the Dev Database for this environment
  # refer https://atlasgo.io/concepts/dev-database
  dev = var.dev_database_url

  # Declare where the schema definition resides.
  # uses composite schema
  src = local.schema_url

  # config for the migration step
  migration {
    # directory where migration files are stored
    dir = "file://migrations"
    # refer https://atlasgo.io/versioned/apply#schema-revision-information
    revisions_schema = "atlas_schema_revisions"
  }
}
