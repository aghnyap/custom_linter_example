import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_linter_example/src/analyzer_plugin/rules/missing_semantic.dart';

class MissingSemanticPlugin extends ServerPlugin {
  MissingSemanticPlugin()
      : super(resourceProvider: PhysicalResourceProvider.INSTANCE);

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    final unit = await analysisContext.currentSession.getResolvedUnit(path);
    final errors = [
      if (unit is ResolvedUnitResult)
        ...missingSemantic(path, unit).map((e) => e.error)
    ];

    channel
        .sendNotification(AnalysisErrorsParams(path, errors).toNotification());
  }

  @override
  List<String> get fileGlobsToAnalyze => const <String>['*.dart'];

  @override
  String get name => 'Missing Semantic Plugin';

  @override
  String get version => '1.0.0';
}
