import 'dart:isolate';

import 'package:analyzer_plugin/starter.dart';

import 'missing_semantic_plugin.dart';

void start(Iterable<String> _, SendPort sendPort) =>
    ServerPluginStarter(MissingSemanticPlugin()).start(sendPort);
