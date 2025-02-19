import 'dart:isolate';

import 'package:custom_linter_example/custom_linter_example.dart';

void main(List<String> args, SendPort sendPort) => start(args, sendPort);
