import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'omni_button_provider.g.dart';


@riverpod
class OmniState extends _$OmniState {
  
  @override
  int build() {
    return 0;
  }

  void show() {
    state = 1;
  }

  void hide() {
    state = 0;
  }

}
