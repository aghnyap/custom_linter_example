import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class MissingSemantic extends DartLintRule {
  MissingSemantic()
      : super(
          code: LintCode(
            name: 'missing_semantic',
            problemMessage: 'Semantic label is missing for this widget.',
            correctionMessage:
                'Wrap with a Semantics widget or add a semanticLabel.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final constructorName = node.constructorName.type.toString();

      // List of widgets that should have semantic labels
      final widgetsRequiringSemantics = {'Text', 'Image', 'Icon'};

      if (widgetsRequiringSemantics.contains(constructorName)) {
        final hasSemanticParent = node.parent is NamedExpression &&
            (node.parent as NamedExpression).name.label.name ==
                'semanticsLabel';

        if (!hasSemanticParent) {
          reporter.atNode(node, code);
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [_AddSemanticWrapperFix()];
}

class _AddSemanticWrapperFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with Semantics widget',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        final originalCode = node.toSource();
        final wrappedCode =
            'Semantics(label: "Describe this", child: $originalCode)';

        builder.addSimpleReplacement(
          SourceRange(node.offset, node.length),
          wrappedCode,
        );
      });
    });
  }
}
