import 'package:flutter/widgets.dart';

import 'package:mvvm_kit/src/live_data/live_data.dart';
import 'package:mvvm_kit/src/live_data/scope.dart';

class TextLiveData extends MutableLiveData<String> {
  final bool _disposeController;
  final TextEditingController controller;
  final GlobalKey<FormFieldState> globalKey = GlobalKey<FormFieldState>();

  @override
  String get value => controller.text;

  @override
  set value(String value) {
    controller.text = value;
  }

  TextLiveData({
    TextEditingController? controller,
    String? text,
    bool disposeController = true,
  }) : _disposeController = disposeController,
       controller = controller ?? TextEditingController(),
       super("") {
    this.controller.addListener(_onTextChanged);
    if (text?.isNotEmpty == true) {
      this.controller.text = text!;
    }
  }

  bool get isValid => globalKey.currentState?.validate() ?? true;

  void _onTextChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    if (_disposeController) {
      controller.dispose();
    }
    super.dispose();
  }
}

extension TextDataScope on DataScope {
  TextLiveData text({String? text}) {
    TextLiveData data = TextLiveData(text: text);
    return add(data);
  }
}
