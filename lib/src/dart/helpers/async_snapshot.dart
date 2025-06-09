import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension AsyncSnapshotHelper<T> on AsyncSnapshot<T> {

  AsyncValue<T> asAsyncValue() {
    if (hasError) {
      return AsyncValue.error(error!, StackTrace.current);
    }

    if (hasData && data != null) {
      return AsyncValue.data(data as T);
    }

    return AsyncValue.loading();
  }

}



