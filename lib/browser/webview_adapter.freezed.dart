// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webview_adapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WebviewLoadError {

 Uri get url; int? get code; String get message;
/// Create a copy of WebviewLoadError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebviewLoadErrorCopyWith<WebviewLoadError> get copyWith => _$WebviewLoadErrorCopyWithImpl<WebviewLoadError>(this as WebviewLoadError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebviewLoadError&&(identical(other.url, url) || other.url == url)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,url,code,message);

@override
String toString() {
  return 'WebviewLoadError(url: $url, code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $WebviewLoadErrorCopyWith<$Res>  {
  factory $WebviewLoadErrorCopyWith(WebviewLoadError value, $Res Function(WebviewLoadError) _then) = _$WebviewLoadErrorCopyWithImpl;
@useResult
$Res call({
 Uri url, int? code, String message
});




}
/// @nodoc
class _$WebviewLoadErrorCopyWithImpl<$Res>
    implements $WebviewLoadErrorCopyWith<$Res> {
  _$WebviewLoadErrorCopyWithImpl(this._self, this._then);

  final WebviewLoadError _self;
  final $Res Function(WebviewLoadError) _then;

/// Create a copy of WebviewLoadError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? code = freezed,Object? message = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WebviewLoadError].
extension WebviewLoadErrorPatterns on WebviewLoadError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebviewLoadError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebviewLoadError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebviewLoadError value)  $default,){
final _that = this;
switch (_that) {
case _WebviewLoadError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebviewLoadError value)?  $default,){
final _that = this;
switch (_that) {
case _WebviewLoadError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uri url,  int? code,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebviewLoadError() when $default != null:
return $default(_that.url,_that.code,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uri url,  int? code,  String message)  $default,) {final _that = this;
switch (_that) {
case _WebviewLoadError():
return $default(_that.url,_that.code,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uri url,  int? code,  String message)?  $default,) {final _that = this;
switch (_that) {
case _WebviewLoadError() when $default != null:
return $default(_that.url,_that.code,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _WebviewLoadError implements WebviewLoadError {
  const _WebviewLoadError({required this.url, this.code, required this.message});
  

@override final  Uri url;
@override final  int? code;
@override final  String message;

/// Create a copy of WebviewLoadError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebviewLoadErrorCopyWith<_WebviewLoadError> get copyWith => __$WebviewLoadErrorCopyWithImpl<_WebviewLoadError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebviewLoadError&&(identical(other.url, url) || other.url == url)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,url,code,message);

@override
String toString() {
  return 'WebviewLoadError(url: $url, code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class _$WebviewLoadErrorCopyWith<$Res> implements $WebviewLoadErrorCopyWith<$Res> {
  factory _$WebviewLoadErrorCopyWith(_WebviewLoadError value, $Res Function(_WebviewLoadError) _then) = __$WebviewLoadErrorCopyWithImpl;
@override @useResult
$Res call({
 Uri url, int? code, String message
});




}
/// @nodoc
class __$WebviewLoadErrorCopyWithImpl<$Res>
    implements _$WebviewLoadErrorCopyWith<$Res> {
  __$WebviewLoadErrorCopyWithImpl(this._self, this._then);

  final _WebviewLoadError _self;
  final $Res Function(_WebviewLoadError) _then;

/// Create a copy of WebviewLoadError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? code = freezed,Object? message = null,}) {
  return _then(_WebviewLoadError(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
