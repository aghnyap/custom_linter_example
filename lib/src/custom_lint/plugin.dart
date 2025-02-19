import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'rules/missing_semantic.dart';

PluginBase createPlugin() => _MissingSemanticPlugin();

class _MissingSemanticPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        MissingSemantic(),
      ];
}
