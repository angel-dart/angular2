import 'package:angel_validate/angel_validate.dart' as angel;
import 'package:angular2/angular2.dart';

/// Creates a [ControlGroup] from an Angel [validator]. Useful for validating forms against universal validation rules.
///
/// Generated controls will correspond to the names of rulesets in the [validator]'s schema. Required fields are heeded, while forbidden fields are not.
///
/// If validation fails on a control, the errors will available as a `List<String>` called `all`.
///
/// [autoParse] is heeded just like in `package:angel_validate`. The fields listed will be automatically parsed to numbers (`int` or `num`), if possible.
ControlGroup convertToControlGroup(angel.Validator validator,
    [Iterable<String> autoParse = const []]) {
  autoParse ??= [];
  Map<String, Control> controls = {};
  Map<String, bool> optionals = {};

  validator
    ..rules.forEach((k, v) {
      optionals[k] = !validator.requiredFields.contains(k);
      controls[k] =
          new Control(validator.defaultValues[k], (AbstractControl control) {
        var val = control.value;

        if (autoParse.contains(k)) {
          try {
            var n = num.parse(val?.toString());
            val = n == n.toInt() ? n.toInt() : n;
          } catch (e) {
            val = null;
          }
        }

        if (validator.requiredFields.contains(k) &&
            (val == null || val == '')) {
          return {'required': true};
        }

        var errors = [],
            matchState = {};

        for (var rule in v) {
          if (!rule.matches(val, matchState)) {
            if (validator.customErrorMessages.containsKey(k)) {
              errors.add(validator.customError(k, val));
            } else
              errors.add('expected ${rule.describe(new angel.StringDescription())}');
          }
        }

        return errors.isNotEmpty ? {'all': errors} : null;
      });
    });

  return new ControlGroup(controls, optionals);
}
