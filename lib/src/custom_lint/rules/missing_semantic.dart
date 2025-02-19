import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class MissingSemantic extends DartLintRule {
  MissingSemantic()
      : super(
          code: LintCode(
              name: 'missing_semantic',
              problemMessage: 'Semantic label is missing for widget',
              correctionMessage: 'Add missing semantic'),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;
      if (className.endsWith('Model') && className != 'Model') {
        reporter.atToken(node.name, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_MissingSemanticFix()];
}

class _MissingSemanticFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final validName = node.name.lexeme
          .substring(0, node.name.lexeme.length - 'Model'.length);

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Rename to $validName',
        priority: 0,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
            SourceRange(node.name.offset, node.name.length), validName);
      });
    });
  }
}
