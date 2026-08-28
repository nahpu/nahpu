#!/bin/bash
dart run drift_dev schema dump \
  lib/services/database/database.dart \
  db_schemas/drift_schema_v21.json
