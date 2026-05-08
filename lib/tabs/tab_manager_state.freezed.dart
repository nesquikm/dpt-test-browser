// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tab_manager_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TabManagerState {

 List<BrowserTab> get tabs; String? get activeTabId;
/// Create a copy of TabManagerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TabManagerStateCopyWith<TabManagerState> get copyWith => _$TabManagerStateCopyWithImpl<TabManagerState>(this as TabManagerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TabManagerState&&const DeepCollectionEquality().equals(other.tabs, tabs)&&(identical(other.activeTabId, activeTabId) || other.activeTabId == activeTabId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tabs),activeTabId);

@override
String toString() {
  return 'TabManagerState(tabs: $tabs, activeTabId: $activeTabId)';
}


}

/// @nodoc
abstract mixin class $TabManagerStateCopyWith<$Res>  {
  factory $TabManagerStateCopyWith(TabManagerState value, $Res Function(TabManagerState) _then) = _$TabManagerStateCopyWithImpl;
@useResult
$Res call({
 List<BrowserTab> tabs, String? activeTabId
});




}
/// @nodoc
class _$TabManagerStateCopyWithImpl<$Res>
    implements $TabManagerStateCopyWith<$Res> {
  _$TabManagerStateCopyWithImpl(this._self, this._then);

  final TabManagerState _self;
  final $Res Function(TabManagerState) _then;

/// Create a copy of TabManagerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tabs = null,Object? activeTabId = freezed,}) {
  return _then(_self.copyWith(
tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<BrowserTab>,activeTabId: freezed == activeTabId ? _self.activeTabId : activeTabId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TabManagerState].
extension TabManagerStatePatterns on TabManagerState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TabManagerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TabManagerState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TabManagerState value)  $default,){
final _that = this;
switch (_that) {
case _TabManagerState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TabManagerState value)?  $default,){
final _that = this;
switch (_that) {
case _TabManagerState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BrowserTab> tabs,  String? activeTabId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TabManagerState() when $default != null:
return $default(_that.tabs,_that.activeTabId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BrowserTab> tabs,  String? activeTabId)  $default,) {final _that = this;
switch (_that) {
case _TabManagerState():
return $default(_that.tabs,_that.activeTabId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BrowserTab> tabs,  String? activeTabId)?  $default,) {final _that = this;
switch (_that) {
case _TabManagerState() when $default != null:
return $default(_that.tabs,_that.activeTabId);case _:
  return null;

}
}

}

/// @nodoc


class _TabManagerState implements TabManagerState {
  const _TabManagerState({required final  List<BrowserTab> tabs, this.activeTabId}): _tabs = tabs;
  

 final  List<BrowserTab> _tabs;
@override List<BrowserTab> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

@override final  String? activeTabId;

/// Create a copy of TabManagerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TabManagerStateCopyWith<_TabManagerState> get copyWith => __$TabManagerStateCopyWithImpl<_TabManagerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TabManagerState&&const DeepCollectionEquality().equals(other._tabs, _tabs)&&(identical(other.activeTabId, activeTabId) || other.activeTabId == activeTabId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tabs),activeTabId);

@override
String toString() {
  return 'TabManagerState(tabs: $tabs, activeTabId: $activeTabId)';
}


}

/// @nodoc
abstract mixin class _$TabManagerStateCopyWith<$Res> implements $TabManagerStateCopyWith<$Res> {
  factory _$TabManagerStateCopyWith(_TabManagerState value, $Res Function(_TabManagerState) _then) = __$TabManagerStateCopyWithImpl;
@override @useResult
$Res call({
 List<BrowserTab> tabs, String? activeTabId
});




}
/// @nodoc
class __$TabManagerStateCopyWithImpl<$Res>
    implements _$TabManagerStateCopyWith<$Res> {
  __$TabManagerStateCopyWithImpl(this._self, this._then);

  final _TabManagerState _self;
  final $Res Function(_TabManagerState) _then;

/// Create a copy of TabManagerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tabs = null,Object? activeTabId = freezed,}) {
  return _then(_TabManagerState(
tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<BrowserTab>,activeTabId: freezed == activeTabId ? _self.activeTabId : activeTabId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
