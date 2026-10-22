// Copyright (C) 2026  oito2
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

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/oito2_localizations.dart';

/// The units of [Oito2Format.bytes].
enum Oito2ByteUnits {
  /// Powers of 1000: B, kB, MB, GB, TB.
  si,

  /// Powers of 1024: B, KiB, MiB, GiB, TiB.
  iec,
}

/// Locale-aware formatting of byte sizes, compact numbers and relative
/// times, such as "1.5 MB", "1.23K" and "3 minutes ago".
///
/// Numbers follow the [locale] through `intl`; relative times use the
/// [strings] of [Oito2Localizations]. [Oito2Format.of] takes both from a
/// widget context. Plain numbers, dates and times are formatted with
/// `intl` directly.
@immutable
class Oito2Format {
  /// Creates a formatter for [locale], such as `en` or `pt_BR`, with the
  /// relative-time [strings]; locales `intl` doesn't know fall back to
  /// English number formats.
  Oito2Format({
    String locale = 'en',
    this.strings = const Oito2LocalizationsEn(),
  }) : locale =
           Intl.verifiedLocale(
             locale,
             NumberFormat.localeExists,
             onFailure: (_) => 'en',
           ) ??
           'en';

  /// A formatter for the locale and the [Oito2Localizations] of
  /// [context].
  factory Oito2Format.of(BuildContext context) => Oito2Format(
    locale: Localizations.maybeLocaleOf(context)?.toString() ?? 'en',
    strings: Oito2Localizations.of(context),
  );

  /// The `intl` locale of the number formats.
  final String locale;

  /// The relative-time strings.
  final Oito2Localizations strings;

  static const _siUnits = ['B', 'kB', 'MB', 'GB', 'TB', 'PB'];
  static const _iecUnits = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB'];

  /// Formats a byte count, such as `1536` as "1.5 kB" (or "1,5 kB" in
  /// Portuguese), with at most [fractionDigits] decimals; counts below one
  /// kilobyte keep no decimals.
  String bytes(
    int bytes, {
    Oito2ByteUnits units = Oito2ByteUnits.si,
    int fractionDigits = 1,
  }) {
    final base = units == Oito2ByteUnits.si ? 1000 : 1024;
    final names = units == Oito2ByteUnits.si ? _siUnits : _iecUnits;
    final sign = bytes < 0 ? '-' : '';
    var value = bytes.abs().toDouble();
    var unit = 0;
    while (value >= base && unit < names.length - 1) {
      value /= base;
      unit++;
    }
    // Moves to the next unit when rounding would show the base itself,
    // such as "1,000 kB".
    final factor = math.pow(10, unit == 0 ? 0 : fractionDigits);
    if (unit > 0 &&
        unit < names.length - 1 &&
        (value * factor).round() / factor >= base) {
      value /= base;
      unit++;
    }
    final format = NumberFormat.decimalPattern(locale)
      ..maximumFractionDigits = unit == 0 ? 0 : fractionDigits;
    return '$sign${format.format(value)} ${names[unit]}';
  }

  /// Formats [value] in compact form with three significant digits, such
  /// as `1234` as "1.23K" (or "1,23 mil" in Portuguese).
  String compactNumber(num value) =>
      NumberFormat.compact(locale: locale).format(value);

  /// Describes [time] relative to [now] (the current time by default),
  /// such as "3 minutes ago" or "in 2 days", picking the largest unit
  /// that fits; times within 45 seconds read as "now".
  String relativeTime(DateTime time, {DateTime? now}) {
    final difference = time.difference(now ?? DateTime.now());
    final future = !difference.isNegative;
    final seconds = difference.inSeconds.abs();
    if (seconds < 45) return strings.justNow;
    final (count, unit) = switch (seconds) {
      < 45 * 60 => (math.max(1, (seconds / 60).round()), Oito2TimeUnit.minute),
      < 22 * 3600 => ((seconds / 3600).round(), Oito2TimeUnit.hour),
      // Six and a half days round to a week, not to "7 days".
      < 13 * 43200 => ((seconds / 86400).round(), Oito2TimeUnit.day),
      < 30 * 86400 => ((seconds / (7 * 86400)).round(), Oito2TimeUnit.week),
      < 365 * 86400 => (
        math.max(1, (seconds / (30 * 86400)).round()),
        Oito2TimeUnit.month,
      ),
      _ => ((seconds / (365 * 86400)).round(), Oito2TimeUnit.year),
    };
    return future
        ? strings.timeFromNow(count, unit)
        : strings.timeAgo(count, unit);
  }
}
