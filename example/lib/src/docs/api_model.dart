// Copyright (C) 2026  OITO2
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/// One public declaration of the oito2_ui packages, as the API reference
/// pages show it.
class ApiEntry {
  /// Creates an entry.
  const ApiEntry({
    required this.kind,
    required this.package,
    required this.doc,
    this.signature = '',
    this.constructors = const [],
    this.properties = const [],
    this.methods = const [],
    this.values = const [],
  });

  /// The kind of declaration, such as `class`, `enum` or `typedef`.
  final String kind;

  /// The package that exports it.
  final String package;

  /// Its doc comment, without the comment markers.
  final String doc;

  /// The type of a typedef, variable or getter, or the signature of a
  /// function; empty for classes and enums.
  final String signature;

  /// The public constructors.
  final List<ApiConstructor> constructors;

  /// The documented public fields and getters that no constructor
  /// parameter describes.
  final List<ApiMember> properties;

  /// The documented public methods.
  final List<ApiMember> methods;

  /// The values of an enum.
  final List<ApiMember> values;
}

/// A public constructor and its parameters.
class ApiConstructor {
  /// Creates a constructor description.
  const ApiConstructor({
    required this.name,
    required this.doc,
    required this.parameters,
    this.isConst = false,
    this.isFactory = false,
  });

  /// The constructor name, such as `Oito2Banner` or `Oito2Banner.tile`.
  final String name;

  /// Its doc comment.
  final String doc;

  /// Its parameters, without `key`.
  final List<ApiParameter> parameters;

  /// Whether it is a const constructor.
  final bool isConst;

  /// Whether it is a factory constructor.
  final bool isFactory;
}

/// A constructor parameter.
class ApiParameter {
  /// Creates a parameter description.
  const ApiParameter({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.isNamed,
    required this.defaultValue,
    required this.doc,
  });

  /// The parameter name.
  final String name;

  /// Its type.
  final String type;

  /// Whether it must be given.
  final bool isRequired;

  /// Whether it is a named parameter.
  final bool isNamed;

  /// The source of its default value; empty without one.
  final String defaultValue;

  /// Its doc comment, or the doc comment of the field it sets.
  final String doc;
}

/// A field, getter, method or enum value.
class ApiMember {
  /// Creates a member description.
  const ApiMember({
    required this.name,
    required this.signature,
    required this.doc,
  });

  /// The member name.
  final String name;

  /// Its type, or its signature for a method.
  final String signature;

  /// Its doc comment.
  final String doc;
}
