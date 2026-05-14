// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PriceHistoryTableTable extends PriceHistoryTable
    with TableInfo<$PriceHistoryTableTable, PriceHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hotelCodeMeta = const VerificationMeta(
    'hotelCode',
  );
  @override
  late final GeneratedColumn<String> hotelCode = GeneratedColumn<String>(
    'hotel_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hotelNameMeta = const VerificationMeta(
    'hotelName',
  );
  @override
  late final GeneratedColumn<String> hotelName = GeneratedColumn<String>(
    'hotel_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkinMeta = const VerificationMeta(
    'checkin',
  );
  @override
  late final GeneratedColumn<String> checkin = GeneratedColumn<String>(
    'checkin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkoutMeta = const VerificationMeta(
    'checkout',
  );
  @override
  late final GeneratedColumn<String> checkout = GeneratedColumn<String>(
    'checkout',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _polledAtMeta = const VerificationMeta(
    'polledAt',
  );
  @override
  late final GeneratedColumn<DateTime> polledAt = GeneratedColumn<DateTime>(
    'polled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    hotelCode,
    hotelName,
    price,
    checkin,
    checkout,
    polledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('hotel_code')) {
      context.handle(
        _hotelCodeMeta,
        hotelCode.isAcceptableOrUnknown(data['hotel_code']!, _hotelCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_hotelCodeMeta);
    }
    if (data.containsKey('hotel_name')) {
      context.handle(
        _hotelNameMeta,
        hotelName.isAcceptableOrUnknown(data['hotel_name']!, _hotelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_hotelNameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('checkin')) {
      context.handle(
        _checkinMeta,
        checkin.isAcceptableOrUnknown(data['checkin']!, _checkinMeta),
      );
    } else if (isInserting) {
      context.missing(_checkinMeta);
    }
    if (data.containsKey('checkout')) {
      context.handle(
        _checkoutMeta,
        checkout.isAcceptableOrUnknown(data['checkout']!, _checkoutMeta),
      );
    } else if (isInserting) {
      context.missing(_checkoutMeta);
    }
    if (data.containsKey('polled_at')) {
      context.handle(
        _polledAtMeta,
        polledAt.isAcceptableOrUnknown(data['polled_at']!, _polledAtMeta),
      );
    } else if (isInserting) {
      context.missing(_polledAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PriceHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      hotelCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hotel_code'],
      )!,
      hotelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hotel_name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      checkin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checkin'],
      )!,
      checkout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checkout'],
      )!,
      polledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}polled_at'],
      )!,
    );
  }

  @override
  $PriceHistoryTableTable createAlias(String alias) {
    return $PriceHistoryTableTable(attachedDatabase, alias);
  }
}

class PriceHistoryTableData extends DataClass
    implements Insertable<PriceHistoryTableData> {
  final int id;
  final String taskId;
  final String hotelCode;
  final String hotelName;
  final int price;
  final String checkin;
  final String checkout;
  final DateTime polledAt;
  const PriceHistoryTableData({
    required this.id,
    required this.taskId,
    required this.hotelCode,
    required this.hotelName,
    required this.price,
    required this.checkin,
    required this.checkout,
    required this.polledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<String>(taskId);
    map['hotel_code'] = Variable<String>(hotelCode);
    map['hotel_name'] = Variable<String>(hotelName);
    map['price'] = Variable<int>(price);
    map['checkin'] = Variable<String>(checkin);
    map['checkout'] = Variable<String>(checkout);
    map['polled_at'] = Variable<DateTime>(polledAt);
    return map;
  }

  PriceHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return PriceHistoryTableCompanion(
      id: Value(id),
      taskId: Value(taskId),
      hotelCode: Value(hotelCode),
      hotelName: Value(hotelName),
      price: Value(price),
      checkin: Value(checkin),
      checkout: Value(checkout),
      polledAt: Value(polledAt),
    );
  }

  factory PriceHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      hotelCode: serializer.fromJson<String>(json['hotelCode']),
      hotelName: serializer.fromJson<String>(json['hotelName']),
      price: serializer.fromJson<int>(json['price']),
      checkin: serializer.fromJson<String>(json['checkin']),
      checkout: serializer.fromJson<String>(json['checkout']),
      polledAt: serializer.fromJson<DateTime>(json['polledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<String>(taskId),
      'hotelCode': serializer.toJson<String>(hotelCode),
      'hotelName': serializer.toJson<String>(hotelName),
      'price': serializer.toJson<int>(price),
      'checkin': serializer.toJson<String>(checkin),
      'checkout': serializer.toJson<String>(checkout),
      'polledAt': serializer.toJson<DateTime>(polledAt),
    };
  }

  PriceHistoryTableData copyWith({
    int? id,
    String? taskId,
    String? hotelCode,
    String? hotelName,
    int? price,
    String? checkin,
    String? checkout,
    DateTime? polledAt,
  }) => PriceHistoryTableData(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    hotelCode: hotelCode ?? this.hotelCode,
    hotelName: hotelName ?? this.hotelName,
    price: price ?? this.price,
    checkin: checkin ?? this.checkin,
    checkout: checkout ?? this.checkout,
    polledAt: polledAt ?? this.polledAt,
  );
  PriceHistoryTableData copyWithCompanion(PriceHistoryTableCompanion data) {
    return PriceHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      hotelCode: data.hotelCode.present ? data.hotelCode.value : this.hotelCode,
      hotelName: data.hotelName.present ? data.hotelName.value : this.hotelName,
      price: data.price.present ? data.price.value : this.price,
      checkin: data.checkin.present ? data.checkin.value : this.checkin,
      checkout: data.checkout.present ? data.checkout.value : this.checkout,
      polledAt: data.polledAt.present ? data.polledAt.value : this.polledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceHistoryTableData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('hotelCode: $hotelCode, ')
          ..write('hotelName: $hotelName, ')
          ..write('price: $price, ')
          ..write('checkin: $checkin, ')
          ..write('checkout: $checkout, ')
          ..write('polledAt: $polledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    hotelCode,
    hotelName,
    price,
    checkin,
    checkout,
    polledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceHistoryTableData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.hotelCode == this.hotelCode &&
          other.hotelName == this.hotelName &&
          other.price == this.price &&
          other.checkin == this.checkin &&
          other.checkout == this.checkout &&
          other.polledAt == this.polledAt);
}

class PriceHistoryTableCompanion
    extends UpdateCompanion<PriceHistoryTableData> {
  final Value<int> id;
  final Value<String> taskId;
  final Value<String> hotelCode;
  final Value<String> hotelName;
  final Value<int> price;
  final Value<String> checkin;
  final Value<String> checkout;
  final Value<DateTime> polledAt;
  const PriceHistoryTableCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.hotelCode = const Value.absent(),
    this.hotelName = const Value.absent(),
    this.price = const Value.absent(),
    this.checkin = const Value.absent(),
    this.checkout = const Value.absent(),
    this.polledAt = const Value.absent(),
  });
  PriceHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String taskId,
    required String hotelCode,
    required String hotelName,
    required int price,
    required String checkin,
    required String checkout,
    required DateTime polledAt,
  }) : taskId = Value(taskId),
       hotelCode = Value(hotelCode),
       hotelName = Value(hotelName),
       price = Value(price),
       checkin = Value(checkin),
       checkout = Value(checkout),
       polledAt = Value(polledAt);
  static Insertable<PriceHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? taskId,
    Expression<String>? hotelCode,
    Expression<String>? hotelName,
    Expression<int>? price,
    Expression<String>? checkin,
    Expression<String>? checkout,
    Expression<DateTime>? polledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (hotelCode != null) 'hotel_code': hotelCode,
      if (hotelName != null) 'hotel_name': hotelName,
      if (price != null) 'price': price,
      if (checkin != null) 'checkin': checkin,
      if (checkout != null) 'checkout': checkout,
      if (polledAt != null) 'polled_at': polledAt,
    });
  }

  PriceHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? taskId,
    Value<String>? hotelCode,
    Value<String>? hotelName,
    Value<int>? price,
    Value<String>? checkin,
    Value<String>? checkout,
    Value<DateTime>? polledAt,
  }) {
    return PriceHistoryTableCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      hotelCode: hotelCode ?? this.hotelCode,
      hotelName: hotelName ?? this.hotelName,
      price: price ?? this.price,
      checkin: checkin ?? this.checkin,
      checkout: checkout ?? this.checkout,
      polledAt: polledAt ?? this.polledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (hotelCode.present) {
      map['hotel_code'] = Variable<String>(hotelCode.value);
    }
    if (hotelName.present) {
      map['hotel_name'] = Variable<String>(hotelName.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (checkin.present) {
      map['checkin'] = Variable<String>(checkin.value);
    }
    if (checkout.present) {
      map['checkout'] = Variable<String>(checkout.value);
    }
    if (polledAt.present) {
      map['polled_at'] = Variable<DateTime>(polledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('hotelCode: $hotelCode, ')
          ..write('hotelName: $hotelName, ')
          ..write('price: $price, ')
          ..write('checkin: $checkin, ')
          ..write('checkout: $checkout, ')
          ..write('polledAt: $polledAt')
          ..write(')'))
        .toString();
  }
}

class $MonitorTaskTableTable extends MonitorTaskTable
    with TableInfo<$MonitorTaskTableTable, MonitorTaskTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitorTaskTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta(
    'paramsJson',
  );
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    paramsJson,
    createdAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitor_task_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitorTaskTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('params_json')) {
      context.handle(
        _paramsJsonMeta,
        paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_paramsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonitorTaskTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitorTaskTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      paramsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $MonitorTaskTableTable createAlias(String alias) {
    return $MonitorTaskTableTable(attachedDatabase, alias);
  }
}

class MonitorTaskTableData extends DataClass
    implements Insertable<MonitorTaskTableData> {
  final String id;
  final String name;
  final String paramsJson;
  final DateTime createdAt;
  final bool isActive;
  const MonitorTaskTableData({
    required this.id,
    required this.name,
    required this.paramsJson,
    required this.createdAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['params_json'] = Variable<String>(paramsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MonitorTaskTableCompanion toCompanion(bool nullToAbsent) {
    return MonitorTaskTableCompanion(
      id: Value(id),
      name: Value(name),
      paramsJson: Value(paramsJson),
      createdAt: Value(createdAt),
      isActive: Value(isActive),
    );
  }

  factory MonitorTaskTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitorTaskTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      paramsJson: serializer.fromJson<String>(json['paramsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'paramsJson': serializer.toJson<String>(paramsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MonitorTaskTableData copyWith({
    String? id,
    String? name,
    String? paramsJson,
    DateTime? createdAt,
    bool? isActive,
  }) => MonitorTaskTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    paramsJson: paramsJson ?? this.paramsJson,
    createdAt: createdAt ?? this.createdAt,
    isActive: isActive ?? this.isActive,
  );
  MonitorTaskTableData copyWithCompanion(MonitorTaskTableCompanion data) {
    return MonitorTaskTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      paramsJson: data.paramsJson.present
          ? data.paramsJson.value
          : this.paramsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitorTaskTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, paramsJson, createdAt, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitorTaskTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.paramsJson == this.paramsJson &&
          other.createdAt == this.createdAt &&
          other.isActive == this.isActive);
}

class MonitorTaskTableCompanion extends UpdateCompanion<MonitorTaskTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> paramsJson;
  final Value<DateTime> createdAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const MonitorTaskTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitorTaskTableCompanion.insert({
    required String id,
    required String name,
    required String paramsJson,
    required DateTime createdAt,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       paramsJson = Value(paramsJson),
       createdAt = Value(createdAt);
  static Insertable<MonitorTaskTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? paramsJson,
    Expression<DateTime>? createdAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (paramsJson != null) 'params_json': paramsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitorTaskTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? paramsJson,
    Value<DateTime>? createdAt,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return MonitorTaskTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      paramsJson: paramsJson ?? this.paramsJson,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitorTaskTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PriceHistoryTableTable priceHistoryTable =
      $PriceHistoryTableTable(this);
  late final $MonitorTaskTableTable monitorTaskTable = $MonitorTaskTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    priceHistoryTable,
    monitorTaskTable,
  ];
}

typedef $$PriceHistoryTableTableCreateCompanionBuilder =
    PriceHistoryTableCompanion Function({
      Value<int> id,
      required String taskId,
      required String hotelCode,
      required String hotelName,
      required int price,
      required String checkin,
      required String checkout,
      required DateTime polledAt,
    });
typedef $$PriceHistoryTableTableUpdateCompanionBuilder =
    PriceHistoryTableCompanion Function({
      Value<int> id,
      Value<String> taskId,
      Value<String> hotelCode,
      Value<String> hotelName,
      Value<int> price,
      Value<String> checkin,
      Value<String> checkout,
      Value<DateTime> polledAt,
    });

class $$PriceHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $PriceHistoryTableTable> {
  $$PriceHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hotelCode => $composableBuilder(
    column: $table.hotelCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hotelName => $composableBuilder(
    column: $table.hotelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkin => $composableBuilder(
    column: $table.checkin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkout => $composableBuilder(
    column: $table.checkout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get polledAt => $composableBuilder(
    column: $table.polledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceHistoryTableTable> {
  $$PriceHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hotelCode => $composableBuilder(
    column: $table.hotelCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hotelName => $composableBuilder(
    column: $table.hotelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkin => $composableBuilder(
    column: $table.checkin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkout => $composableBuilder(
    column: $table.checkout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get polledAt => $composableBuilder(
    column: $table.polledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceHistoryTableTable> {
  $$PriceHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get hotelCode =>
      $composableBuilder(column: $table.hotelCode, builder: (column) => column);

  GeneratedColumn<String> get hotelName =>
      $composableBuilder(column: $table.hotelName, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get checkin =>
      $composableBuilder(column: $table.checkin, builder: (column) => column);

  GeneratedColumn<String> get checkout =>
      $composableBuilder(column: $table.checkout, builder: (column) => column);

  GeneratedColumn<DateTime> get polledAt =>
      $composableBuilder(column: $table.polledAt, builder: (column) => column);
}

class $$PriceHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceHistoryTableTable,
          PriceHistoryTableData,
          $$PriceHistoryTableTableFilterComposer,
          $$PriceHistoryTableTableOrderingComposer,
          $$PriceHistoryTableTableAnnotationComposer,
          $$PriceHistoryTableTableCreateCompanionBuilder,
          $$PriceHistoryTableTableUpdateCompanionBuilder,
          (
            PriceHistoryTableData,
            BaseReferences<
              _$AppDatabase,
              $PriceHistoryTableTable,
              PriceHistoryTableData
            >,
          ),
          PriceHistoryTableData,
          PrefetchHooks Function()
        > {
  $$PriceHistoryTableTableTableManager(
    _$AppDatabase db,
    $PriceHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> hotelCode = const Value.absent(),
                Value<String> hotelName = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<String> checkin = const Value.absent(),
                Value<String> checkout = const Value.absent(),
                Value<DateTime> polledAt = const Value.absent(),
              }) => PriceHistoryTableCompanion(
                id: id,
                taskId: taskId,
                hotelCode: hotelCode,
                hotelName: hotelName,
                price: price,
                checkin: checkin,
                checkout: checkout,
                polledAt: polledAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String taskId,
                required String hotelCode,
                required String hotelName,
                required int price,
                required String checkin,
                required String checkout,
                required DateTime polledAt,
              }) => PriceHistoryTableCompanion.insert(
                id: id,
                taskId: taskId,
                hotelCode: hotelCode,
                hotelName: hotelName,
                price: price,
                checkin: checkin,
                checkout: checkout,
                polledAt: polledAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceHistoryTableTable,
      PriceHistoryTableData,
      $$PriceHistoryTableTableFilterComposer,
      $$PriceHistoryTableTableOrderingComposer,
      $$PriceHistoryTableTableAnnotationComposer,
      $$PriceHistoryTableTableCreateCompanionBuilder,
      $$PriceHistoryTableTableUpdateCompanionBuilder,
      (
        PriceHistoryTableData,
        BaseReferences<
          _$AppDatabase,
          $PriceHistoryTableTable,
          PriceHistoryTableData
        >,
      ),
      PriceHistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$MonitorTaskTableTableCreateCompanionBuilder =
    MonitorTaskTableCompanion Function({
      required String id,
      required String name,
      required String paramsJson,
      required DateTime createdAt,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$MonitorTaskTableTableUpdateCompanionBuilder =
    MonitorTaskTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> paramsJson,
      Value<DateTime> createdAt,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$MonitorTaskTableTableFilterComposer
    extends Composer<_$AppDatabase, $MonitorTaskTableTable> {
  $$MonitorTaskTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonitorTaskTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitorTaskTableTable> {
  $$MonitorTaskTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonitorTaskTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitorTaskTableTable> {
  $$MonitorTaskTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$MonitorTaskTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonitorTaskTableTable,
          MonitorTaskTableData,
          $$MonitorTaskTableTableFilterComposer,
          $$MonitorTaskTableTableOrderingComposer,
          $$MonitorTaskTableTableAnnotationComposer,
          $$MonitorTaskTableTableCreateCompanionBuilder,
          $$MonitorTaskTableTableUpdateCompanionBuilder,
          (
            MonitorTaskTableData,
            BaseReferences<
              _$AppDatabase,
              $MonitorTaskTableTable,
              MonitorTaskTableData
            >,
          ),
          MonitorTaskTableData,
          PrefetchHooks Function()
        > {
  $$MonitorTaskTableTableTableManager(
    _$AppDatabase db,
    $MonitorTaskTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitorTaskTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitorTaskTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitorTaskTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> paramsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitorTaskTableCompanion(
                id: id,
                name: name,
                paramsJson: paramsJson,
                createdAt: createdAt,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String paramsJson,
                required DateTime createdAt,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitorTaskTableCompanion.insert(
                id: id,
                name: name,
                paramsJson: paramsJson,
                createdAt: createdAt,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonitorTaskTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonitorTaskTableTable,
      MonitorTaskTableData,
      $$MonitorTaskTableTableFilterComposer,
      $$MonitorTaskTableTableOrderingComposer,
      $$MonitorTaskTableTableAnnotationComposer,
      $$MonitorTaskTableTableCreateCompanionBuilder,
      $$MonitorTaskTableTableUpdateCompanionBuilder,
      (
        MonitorTaskTableData,
        BaseReferences<
          _$AppDatabase,
          $MonitorTaskTableTable,
          MonitorTaskTableData
        >,
      ),
      MonitorTaskTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PriceHistoryTableTableTableManager get priceHistoryTable =>
      $$PriceHistoryTableTableTableManager(_db, _db.priceHistoryTable);
  $$MonitorTaskTableTableTableManager get monitorTaskTable =>
      $$MonitorTaskTableTableTableManager(_db, _db.monitorTaskTable);
}
