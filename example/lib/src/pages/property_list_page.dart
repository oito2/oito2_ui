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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2PropertyList]: file details, groups, widget values,
/// end-aligned labels and the stacked layout.
class PropertyListPage extends StatelessWidget {
  /// Creates the property list page.
  const PropertyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Property List',
      description:
          'Labels and values in two aligned columns, such as the details of '
          'a file or an account, with values that can be selected and '
          'copied.',
      source: 'lib/src/pages/property_list_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2PropertyList(
              properties: const [
                Oito2Property(label: 'Name', value: 'report.pdf'),
                Oito2Property(label: 'Size', value: '2.4 MB'),
                Oito2Property(
                  label: 'Location',
                  value: '/home/ana/Documents',
                  copyable: true,
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Each `Oito2Property` has a `label` and a text `value`; with '
          '`copyable`, a copy button shows while the pointer is over the row '
          'or the button has the focus, and always on touch devices. '
          '`Oito2Property.widget` shows any widget as the value, such as a '
          'status pill or a link, and copies `copyText` when given.',
        ),
        const DocText(
          'The label column is as wide as the widest label, up to 40% of the '
          'width. Text values can be selected with the pointer. Narrower '
          'than `stackedBelow` (360 pixels by default), each label sits '
          'above its value.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('File details in groups', level: 3),
        const DocText(
          '`Oito2PropertyList.grouped` takes `Oito2PropertyGroup`s, each '
          'with an optional heading. `labelAlign: TextAlign.end` aligns the '
          'labels against their values.',
        ),
        const ExamplePanel(
          region: 'groups',
          child: SizedBox(
            width: 460,
            // #region groups
            child: Oito2PropertyList.grouped(
              labelAlign: TextAlign.end,
              groups: [
                Oito2PropertyGroup(
                  heading: 'General',
                  properties: [
                    Oito2Property(label: 'Name', value: 'report.pdf'),
                    Oito2Property(label: 'Type', value: 'PDF document'),
                    Oito2Property(
                      label: 'Size',
                      value: '2.4 MB (2,412,544 bytes)',
                    ),
                    Oito2Property(
                      label: 'Location',
                      value: '/home/ana/Documents',
                      copyable: true,
                    ),
                  ],
                ),
                Oito2PropertyGroup(
                  heading: 'Sync',
                  properties: [
                    Oito2Property.widget(
                      label: 'Status',
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Oito2StatusPill(
                          label: 'Synced',
                          type: Oito2InfoType.success,
                        ),
                      ),
                    ),
                    Oito2Property(label: 'Modified', value: 'Nov 17, 10:42'),
                    Oito2Property(
                      label: 'Checksum',
                      value: 'sha256:9f86d081884c7d65',
                      copyable: true,
                    ),
                  ],
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Narrow', level: 3),
        const DocText('In a narrow pane, labels stack above their values.'),
        ExamplePanel(
          region: 'narrow',
          child: SizedBox(
            width: 220,
            // #region narrow
            child: Oito2PropertyList(
              properties: const [
                Oito2Property(label: 'Account', value: 'ana@example.com'),
                Oito2Property(
                  label: 'Folder',
                  value: '/home/ana/Cloud',
                  copyable: true,
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each property is one node read as "label: value", such as '
          '"Size: 2.4 MB"; a widget value keeps its own semantics after the '
          'label. Group headings are headers. The copy button stays in the '
          'focus order while hidden and shows when it takes the focus.',
        ),
        ...apiReferenceWidgets([
          'Oito2PropertyList',
          'Oito2PropertyGroup',
          'Oito2Property',
        ]),
      ],
    );
  }
}
