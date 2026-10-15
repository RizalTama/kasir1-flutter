// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_settings_dao.dart';

// ignore_for_file: type=lint
mixin _$StoreSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoreSettingsTable get storeSettings => attachedDatabase.storeSettings;
  StoreSettingsDaoManager get managers => StoreSettingsDaoManager(this);
}

class StoreSettingsDaoManager {
  final _$StoreSettingsDaoMixin _db;
  StoreSettingsDaoManager(this._db);
  $$StoreSettingsTableTableManager get storeSettings =>
      $$StoreSettingsTableTableManager(_db.attachedDatabase, _db.storeSettings);
}
