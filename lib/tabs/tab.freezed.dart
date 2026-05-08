// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BrowserTab {

 String get id; Uri get url; String? get title; bool get isLoading;
/// Create a copy of BrowserTab
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrowserTabCopyWith<BrowserTab> get copyWith => _$BrowserTabCopyWithImpl<BrowserTab>(this as BrowserTab, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrowserTab&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,id,url,title,isLoading);

@override
String toString() {
  return 'BrowserTab(id: $id, url: $url, title: $title, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $BrowserTabCopyWith<$Res>  {
  factory $BrowserTabCopyWith(BrowserTab value, $Res Function(BrowserTab) _then) = _$BrowserTabCopyWithImpl;
@useResult
$Res call({
 String id, Uri url, String? title, bool isLoading
});




}
/// @nodoc
class _$BrowserTabCopyWithImpl<$Res>
    implements $BrowserTabCopyWith<$Res> {
  _$BrowserTabCopyWithImpl(this._self, this._then);

  final BrowserTab _self;
  final $Res Function(BrowserTab) _then;

/// Create a copy of BrowserTab
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? title = freezed,Object? isLoading = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BrowserTab].
extension BrowserTabPatterns on BrowserTab {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrowserTab value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrowserTab() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrowserTab value)  $default,){
final _that = this;
switch (_that) {
case _BrowserTab():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrowserTab value)?  $default,){
final _that = this;
switch (_that) {
case _BrowserTab() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Uri url,  String? title,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrowserTab() when $default != null:
return $default(_that.id,_that.url,_that.title,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Uri url,  String? title,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _BrowserTab():
return $default(_that.id,_that.url,_that.title,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Uri url,  String? title,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _BrowserTab() when $default != null:
return $default(_that.id,_that.url,_that.title,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _BrowserTab implements BrowserTab {
  const _BrowserTab({required this.id, required this.url, this.title, this.isLoading = false});
  

@override final  String id;
@override final  Uri url;
@override final  String? title;
@override@JsonKey() final  bool isLoading;

/// Create a copy of BrowserTab
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrowserTabCopyWith<_BrowserTab> get copyWith => __$BrowserTabCopyWithImpl<_BrowserTab>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrowserTab&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,id,url,title,isLoading);

@override
String toString() {
  return 'BrowserTab(id: $id, url: $url, title: $title, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$BrowserTabCopyWith<$Res> implements $BrowserTabCopyWith<$Res> {
  factory _$BrowserTabCopyWith(_BrowserTab value, $Res Function(_BrowserTab) _then) = __$BrowserTabCopyWithImpl;
@override @useResult
$Res call({
 String id, Uri url, String? title, bool isLoading
});




}
/// @nodoc
class __$BrowserTabCopyWithImpl<$Res>
    implements _$BrowserTabCopyWith<$Res> {
  __$BrowserTabCopyWithImpl(this._self, this._then);

  final _BrowserTab _self;
  final $Res Function(_BrowserTab) _then;

/// Create a copy of BrowserTab
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? title = freezed,Object? isLoading = null,}) {
  return _then(_BrowserTab(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
