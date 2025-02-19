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
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final constructorType = node.constructorName.type;
      final constructorName = constructorType.name2.lexeme;

      final widgetsRequiringSemantics = {'Text', 'Image', 'Icon'};

      if (!widgetsRequiringSemantics.contains(constructorName)) return;

      final hasSemanticLabel = node.argumentList.arguments.any((arg) {
        return arg is NamedExpression && arg.name.label.name == 'semanticLabel';
      });

      if (hasSemanticLabel) return;

      if (constructorName == 'Text') {
        final textArgument =
            node.argumentList.arguments.whereType<StringLiteral>().firstOrNull;
        final containsVariable =
            node.argumentList.arguments.any((arg) => arg is! StringLiteral);

        if (containsVariable && hasSemanticLabel) return;

        final textLength = textArgument?.stringValue?.length ?? 0;
        if (textLength > 15) {
          reporter.atNode(node, code);
        }
      } else {
        reporter.atNode(node, code);
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
        message: 'Add semanticLabel or wrap with Semantics widget',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        final originalCode = node.toSource();
        final constructorType = node.constructorName.type;

        final constructorName = constructorType.name2.lexeme;

        final widgetsSupportingSemanticLabel = {'Text', 'Image', 'Icon'};

        if (widgetsSupportingSemanticLabel.contains(constructorName)) {
          final alreadyHasLabel = node.argumentList.arguments.any((arg) {
            return arg is NamedExpression &&
                arg.name.label.name == 'semanticLabel';
          });

          if (!alreadyHasLabel) {
            final updatedCode = originalCode.replaceFirst(
                '(', '(semanticLabel: "Describe this", ');

            builder.addSimpleReplacement(
              SourceRange(node.offset, node.length),
              updatedCode,
            );
          }
          return;
        }

        final wrappedCode = originalCode.startsWith('Semantics(')
            ? originalCode
            : 'Semantics(label: "Describe this", child: $originalCode)';

        builder.addSimpleReplacement(
          SourceRange(node.offset, node.length),
          wrappedCode,
        );
      });
    });
  }
}
