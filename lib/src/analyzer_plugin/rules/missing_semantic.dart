import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

Iterable<AnalysisErrorFixes> missingSemantic(
  String path,
  ResolvedUnitResult unit,
) sync* {
  final lib = unit.libraryElement;
  final topLevelClasses = lib.topLevelElements.whereType<ClassElement>();

  for (final c in topLevelClasses) {
    if (c.name.endsWith('Model')) {
      final location = Location(path, c.nameOffset, c.nameLength, 0, 0);
      yield AnalysisErrorFixes(
        AnalysisError(
          AnalysisErrorSeverity.INFO,
          AnalysisErrorType.LINT,
          location,
          'Add semantic label',
          'missing_semantic',
          correction: 'Add label',
          hasFix: false,
        ),
      );
    }
  }
}
