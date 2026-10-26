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

import 'pages/angle_slider_page.dart';
import 'pages/animated_icon_page.dart';
import 'pages/autocomplete_page.dart';
import 'pages/avatar_page.dart';
import 'pages/banner_page.dart';
import 'pages/border_container_page.dart';
import 'pages/calendar_page.dart';
import 'pages/carousel_page.dart';
import 'pages/check_button_page.dart';
import 'pages/checkbox_page.dart';
import 'pages/choice_chip_bar_page.dart';
import 'pages/code_block_page.dart';
import 'pages/collections_page.dart';
import 'pages/color_disk_page.dart';
import 'pages/color_picker_page.dart';
import 'pages/commands_page.dart';
import 'pages/context_menu_page.dart';
import 'pages/copy_button_page.dart';
import 'pages/date_time_entry_page.dart';
import 'pages/diagonal_clip_page.dart';
import 'pages/dialog_title_bar_page.dart';
import 'pages/docs_pages.dart';
import 'pages/download_trigger_page.dart';
import 'pages/draggable_page.dart';
import 'pages/editable_label_page.dart';
import 'pages/expandable_page.dart';
import 'pages/expansion_panel_page.dart';
import 'pages/file_upload_page.dart';
import 'pages/floating_panel_page.dart';
import 'pages/focus_border_page.dart';
import 'pages/format_page.dart';
import 'pages/foundation_page.dart';
import 'pages/freedesktop_icons_page.dart';
import 'pages/header_bar_page.dart';
import 'pages/highlighted_text_page.dart';
import 'pages/hover_card_page.dart';
import 'pages/icon_button_page.dart';
import 'pages/image_cropper_page.dart';
import 'pages/info_page.dart';
import 'pages/json_tree_view_page.dart';
import 'pages/list_box_page.dart';
import 'pages/list_tile_page.dart';
import 'pages/marquee_page.dart';
import 'pages/master_detail_page.dart';
import 'pages/navigation_menu_page.dart';
import 'pages/navigation_page.dart';
import 'pages/navigation_rail_page.dart';
import 'pages/number_entry_page.dart';
import 'pages/option_button_page.dart';
import 'pages/page_indicator_page.dart';
import 'pages/pagination_page.dart';
import 'pages/paned_view_page.dart';
import 'pages/password_field_page.dart';
import 'pages/pin_entry_page.dart';
import 'pages/placeholder_icon_page.dart';
import 'pages/popover_page.dart';
import 'pages/popup_menu_page.dart';
import 'pages/progress_page.dart';
import 'pages/qr_code_page.dart';
import 'pages/radio_button_page.dart';
import 'pages/radio_page.dart';
import 'pages/rating_page.dart';
import 'pages/scroll_area_page.dart';
import 'pages/search_field_page.dart';
import 'pages/section_page.dart';
import 'pages/segment_group_page.dart';
import 'pages/segmented_entry_page.dart';
import 'pages/selectable_container_page.dart';
import 'pages/sheet_page.dart';
import 'pages/signature_pad_page.dart';
import 'pages/slider_page.dart';
import 'pages/split_button_page.dart';
import 'pages/splitter_page.dart';
import 'pages/steps_page.dart';
import 'pages/swap_page.dart';
import 'pages/switch_button_page.dart';
import 'pages/switch_page.dart';
import 'pages/tab_bar_page.dart';
import 'pages/table_of_contents_page.dart';
import 'pages/tags_field_page.dart';
import 'pages/theme_page.dart';
import 'pages/tile_page.dart';
import 'pages/timer_page.dart';
import 'pages/title_bar_page.dart';
import 'pages/toast_page.dart';
import 'pages/toggle_button_page.dart';
import 'pages/toggle_group_page.dart';
import 'pages/toggle_list_tile_page.dart';
import 'pages/tour_page.dart';
import 'pages/tree_view_page.dart';
import 'pages/undershoot_page.dart';
import 'pages/vertical_tabs_page.dart';
import 'pages/watermark_page.dart';

/// The group a showcase page is listed under.
enum ShowcaseGroup {
  /// Getting started, the changelog and the project.
  overview('Overview'),

  /// The patterns every component shares.
  guides('Guides'),

  /// One page per oito2_ui widget.
  components('Components'),

  /// The optional components of the oito2_ui_extras package.
  extras('Extras'),

  /// The file components of the oito2_ui_files package.
  files('Files'),

  /// Collections, formatting, keyboard commands and the freedesktop icon
  /// names.
  utilities('Utilities'),

  /// The Material theme sample, with the colors, fonts and tokens, and
  /// the platform foundation.
  theme('Theme');

  const ShowcaseGroup(this.label);

  /// The group heading.
  final String label;
}

/// A page of the showcase.
@immutable
class ShowcasePage {
  /// Creates a showcase page.
  const ShowcasePage({
    required this.title,
    required this.icon,
    required this.source,
    required this.builder,
    this.group = ShowcaseGroup.components,
    this.id,
  });

  /// The page title, usually the widget name.
  final String title;

  /// The icon in the page list.
  final IconData icon;

  /// The page's source file name under `lib/src/pages/`, which the
  /// showcase bundles as an asset to show its code.
  final String source;

  /// Builds the page body with the active scheme [colors].
  final Widget Function(BuildContext context, Oito2ColorTheme colors) builder;

  /// The group the page is listed under.
  final ShowcaseGroup group;

  /// The page identifier in links, for pages that share a [source] file.
  final String? id;

  /// The page identifier in links: [id], or else [source] without the
  /// `_page.dart` suffix, with dashes, such as `check-button`.
  String get slug =>
      id ??
      source.replaceFirst(RegExp(r'_page\.dart$'), '').replaceAll('_', '-');

  /// The asset path of [source].
  String get sourceAsset => 'lib/src/pages/$source';
}

/// Returns a page builder that always returns [page], for pages that don't
/// read the scheme colors.
Widget Function(BuildContext, Oito2ColorTheme) _page(Widget page) =>
    (_, _) => page;

/// The guides: title, Markdown file name, icon and lead paragraph.
const _guides = [
  (
    'Styling',
    'styling',
    LucideIcons.palette,
    'Themes, color schemes, tokens and component variants.',
  ),
  (
    'Composition',
    'composition',
    LucideIcons.blocks,
    'Slots, builders, collections and wrappers.',
  ),
  (
    'Component State',
    'component_state',
    LucideIcons.toggle_right,
    'Controlled values, controllers and reading their state.',
  ),
  (
    'Animations',
    'animations',
    LucideIcons.sparkles,
    'Reduced motion, swaps, animated icons and page transitions.',
  ),
  (
    'Forms',
    'forms',
    LucideIcons.text_cursor_input,
    'Entries, values, errors and validation.',
  ),
  (
    'Refs',
    'refs',
    LucideIcons.crosshair,
    'Focus nodes, keys and component state.',
  ),
];

/// Every showcase page: the components in alphabetical order, then the
/// extras, files, utilities and theme pages.
final List<ShowcasePage> showcasePages = [
  ShowcasePage(
    title: 'Getting Started',
    icon: LucideIcons.rocket,
    source: 'docs_pages.dart',
    id: 'getting-started',
    group: ShowcaseGroup.overview,
    builder: _page(
      const MarkdownDocPage(
        title: 'Getting Started',
        asset: 'assets/docs/getting_started.md',
      ),
    ),
  ),
  ShowcasePage(
    title: 'Changelog',
    icon: LucideIcons.file_clock,
    source: 'docs_pages.dart',
    id: 'changelog',
    group: ShowcaseGroup.overview,
    builder: _page(const ChangelogPage()),
  ),
  ShowcasePage(
    title: 'About',
    icon: LucideIcons.info,
    source: 'docs_pages.dart',
    id: 'about',
    group: ShowcaseGroup.overview,
    builder: _page(
      const MarkdownDocPage(title: 'About', asset: 'assets/docs/about.md'),
    ),
  ),
  for (final (title, file, icon, description) in _guides)
    ShowcasePage(
      title: title,
      icon: icon,
      source: 'docs_pages.dart',
      id: 'guides-${file.replaceAll('_', '-')}',
      group: ShowcaseGroup.guides,
      builder: _page(
        MarkdownDocPage(
          title: title,
          description: description,
          asset: 'assets/docs/guides/$file.md',
        ),
      ),
    ),
  ShowcasePage(
    title: 'Oito2AngleSlider',
    icon: LucideIcons.compass,
    source: 'angle_slider_page.dart',
    builder: _page(const AngleSliderPage()),
  ),
  ShowcasePage(
    title: 'Oito2AnimatedIcon',
    icon: LucideIcons.sparkles,
    source: 'animated_icon_page.dart',
    builder: _page(const AnimatedIconPage()),
  ),
  ShowcasePage(
    title: 'Oito2Autocomplete',
    icon: LucideIcons.text_search,
    source: 'autocomplete_page.dart',
    builder: _page(const AutocompletePage()),
  ),
  ShowcasePage(
    title: 'Oito2Avatar',
    icon: LucideIcons.circle_user_round,
    source: 'avatar_page.dart',
    builder: _page(const AvatarPage()),
  ),
  ShowcasePage(
    title: 'Oito2Banner',
    icon: LucideIcons.panel_top,
    source: 'banner_page.dart',
    builder: _page(const BannerPage()),
  ),
  ShowcasePage(
    title: 'Oito2BorderContainer',
    icon: LucideIcons.square_dashed,
    source: 'border_container_page.dart',
    builder: _page(const BorderContainerPage()),
  ),
  ShowcasePage(
    title: 'Oito2Calendar',
    icon: LucideIcons.calendar_days,
    source: 'calendar_page.dart',
    builder: _page(const CalendarPage()),
  ),
  ShowcasePage(
    title: 'Oito2Carousel',
    icon: LucideIcons.gallery_horizontal,
    source: 'carousel_page.dart',
    builder: _page(const CarouselPage()),
  ),
  ShowcasePage(
    title: 'Oito2CheckButton',
    icon: LucideIcons.square_check,
    source: 'check_button_page.dart',
    builder: _page(const CheckButtonPage()),
  ),
  ShowcasePage(
    title: 'Oito2Checkbox',
    icon: LucideIcons.square_check_big,
    source: 'checkbox_page.dart',
    builder: _page(const CheckboxPage()),
  ),
  ShowcasePage(
    title: 'Oito2CheckboxListTile',
    icon: LucideIcons.list_checks,
    source: 'toggle_list_tile_page.dart',
    builder: _page(const ToggleListTilePage()),
  ),
  ShowcasePage(
    title: 'Oito2ChoiceChipBar',
    icon: LucideIcons.list_filter,
    source: 'choice_chip_bar_page.dart',
    builder: _page(const ChoiceChipBarPage()),
  ),
  ShowcasePage(
    title: 'Oito2CodeBlock',
    icon: LucideIcons.code,
    source: 'code_block_page.dart',
    builder: _page(const CodeBlockPage()),
  ),
  ShowcasePage(
    title: 'Oito2ColorDisk',
    icon: LucideIcons.palette,
    source: 'color_disk_page.dart',
    builder: _page(const ColorDiskPage()),
  ),
  ShowcasePage(
    title: 'Oito2ColorPicker',
    icon: LucideIcons.pipette,
    source: 'color_picker_page.dart',
    builder: _page(const ColorPickerPage()),
  ),
  ShowcasePage(
    title: 'Oito2ContextMenuRegion',
    icon: LucideIcons.mouse_pointer_click,
    source: 'context_menu_page.dart',
    builder: _page(const ContextMenuPage()),
  ),
  ShowcasePage(
    title: 'Oito2CopyButton',
    icon: LucideIcons.copy,
    source: 'copy_button_page.dart',
    builder: _page(const CopyButtonPage()),
  ),
  ShowcasePage(
    title: 'Oito2DateTimeEntry',
    icon: LucideIcons.calendar_clock,
    source: 'date_time_entry_page.dart',
    builder: _page(const DateTimeEntryPage()),
  ),
  ShowcasePage(
    title: 'Oito2DiagonalClip',
    icon: LucideIcons.scissors,
    source: 'diagonal_clip_page.dart',
    builder: _page(const DiagonalClipPage()),
  ),
  ShowcasePage(
    title: 'Oito2DialogTitleBar',
    icon: LucideIcons.app_window,
    source: 'dialog_title_bar_page.dart',
    builder: _page(const DialogTitleBarPage()),
  ),
  ShowcasePage(
    title: 'Oito2Draggable',
    icon: LucideIcons.move,
    source: 'draggable_page.dart',
    builder: _page(const DraggablePage()),
  ),
  ShowcasePage(
    title: 'Oito2EditableLabel',
    icon: LucideIcons.pencil_line,
    source: 'editable_label_page.dart',
    builder: _page(const EditableLabelPage()),
  ),
  ShowcasePage(
    title: 'Oito2Expandable',
    icon: LucideIcons.chevrons_down_up,
    source: 'expandable_page.dart',
    builder: _page(const ExpandablePage()),
  ),
  ShowcasePage(
    title: 'Oito2ExpansionPanel',
    icon: LucideIcons.list_collapse,
    source: 'expansion_panel_page.dart',
    builder: _page(const ExpansionPanelPage()),
  ),
  ShowcasePage(
    title: 'Oito2FloatingPanel',
    icon: LucideIcons.app_window,
    source: 'floating_panel_page.dart',
    builder: _page(const FloatingPanelPage()),
  ),
  ShowcasePage(
    title: 'Oito2FocusBorder',
    icon: LucideIcons.focus,
    source: 'focus_border_page.dart',
    builder: _page(const FocusBorderPage()),
  ),
  ShowcasePage(
    title: 'Oito2HeaderBar',
    icon: LucideIcons.panel_top,
    source: 'header_bar_page.dart',
    builder: _page(const HeaderBarPage()),
  ),
  ShowcasePage(
    title: 'Oito2HighlightedText',
    icon: LucideIcons.highlighter,
    source: 'highlighted_text_page.dart',
    builder: _page(const HighlightedTextPage()),
  ),
  ShowcasePage(
    title: 'Oito2HoverCard',
    icon: LucideIcons.id_card,
    source: 'hover_card_page.dart',
    builder: _page(const HoverCardPage()),
  ),
  ShowcasePage(
    title: 'Oito2IconButton',
    icon: LucideIcons.square_mouse_pointer,
    source: 'icon_button_page.dart',
    builder: _page(const IconButtonPage()),
  ),
  ShowcasePage(
    title: 'Oito2InfoBox',
    icon: LucideIcons.info,
    source: 'info_page.dart',
    builder: _page(const InfoPage()),
  ),
  ShowcasePage(
    title: 'Oito2JsonTreeView',
    icon: LucideIcons.braces,
    source: 'json_tree_view_page.dart',
    builder: _page(const JsonTreeViewPage()),
  ),
  ShowcasePage(
    title: 'Oito2ListBox',
    icon: LucideIcons.list,
    source: 'list_box_page.dart',
    builder: _page(const ListBoxPage()),
  ),
  ShowcasePage(
    title: 'Oito2ListTile',
    icon: LucideIcons.rows_3,
    source: 'list_tile_page.dart',
    builder: _page(const ListTilePage()),
  ),
  ShowcasePage(
    title: 'Oito2Marquee',
    icon: LucideIcons.text_cursor_input,
    source: 'marquee_page.dart',
    builder: _page(const MarqueePage()),
  ),
  ShowcasePage(
    title: 'Oito2MasterDetailPage',
    icon: LucideIcons.columns_2,
    source: 'master_detail_page.dart',
    builder: _page(const MasterDetailPage()),
  ),
  ShowcasePage(
    title: 'Oito2NavigationPage',
    icon: LucideIcons.panel_left,
    source: 'navigation_page.dart',
    builder: _page(const NavigationPage()),
  ),
  ShowcasePage(
    title: 'Oito2NavigationRail',
    icon: LucideIcons.panel_left_open,
    source: 'navigation_rail_page.dart',
    builder: _page(const NavigationRailPage()),
  ),
  ShowcasePage(
    title: 'Oito2NumberEntry',
    icon: LucideIcons.hash,
    source: 'number_entry_page.dart',
    builder: _page(const NumberEntryPage()),
  ),
  ShowcasePage(
    title: 'Oito2OptionButton',
    icon: LucideIcons.circle_plus,
    source: 'option_button_page.dart',
    builder: _page(const OptionButtonPage()),
  ),
  ShowcasePage(
    title: 'Oito2PageIndicator',
    icon: LucideIcons.ellipsis,
    source: 'page_indicator_page.dart',
    builder: _page(const PageIndicatorPage()),
  ),
  ShowcasePage(
    title: 'Oito2Pagination',
    icon: LucideIcons.chevrons_left_right_ellipsis,
    source: 'pagination_page.dart',
    builder: _page(const PaginationPage()),
  ),
  ShowcasePage(
    title: 'Oito2PanedView',
    icon: LucideIcons.square_split_horizontal,
    source: 'paned_view_page.dart',
    builder: _page(const PanedViewPage()),
  ),
  ShowcasePage(
    title: 'Oito2PasswordField',
    icon: LucideIcons.key_round,
    source: 'password_field_page.dart',
    builder: _page(const PasswordFieldPage()),
  ),
  ShowcasePage(
    title: 'Oito2PinEntry',
    icon: LucideIcons.rectangle_ellipsis,
    source: 'pin_entry_page.dart',
    builder: _page(const PinEntryPage()),
  ),
  ShowcasePage(
    title: 'Oito2PlaceholderIcon',
    icon: LucideIcons.image,
    source: 'placeholder_icon_page.dart',
    builder: _page(const PlaceholderIconPage()),
  ),
  ShowcasePage(
    title: 'Oito2Popover',
    icon: LucideIcons.message_square,
    source: 'popover_page.dart',
    builder: _page(const PopoverPage()),
  ),
  ShowcasePage(
    title: 'Oito2PopupMenuButton',
    icon: LucideIcons.square_chevron_down,
    source: 'popup_menu_page.dart',
    builder: _page(const PopupMenuPage()),
  ),
  ShowcasePage(
    title: 'Oito2ProgressIndicator',
    icon: LucideIcons.loader_circle,
    source: 'progress_page.dart',
    builder: _page(const ProgressPage()),
  ),
  ShowcasePage(
    title: 'Oito2Radio',
    icon: LucideIcons.circle_dot_dashed,
    source: 'radio_page.dart',
    builder: _page(const RadioPage()),
  ),
  ShowcasePage(
    title: 'Oito2RadioButton',
    icon: LucideIcons.circle_dot,
    source: 'radio_button_page.dart',
    builder: _page(const RadioButtonPage()),
  ),
  ShowcasePage(
    title: 'Oito2Rating',
    icon: LucideIcons.star,
    source: 'rating_page.dart',
    builder: _page(const RatingPage()),
  ),
  ShowcasePage(
    title: 'Oito2ScrollArea',
    icon: LucideIcons.scroll_text,
    source: 'scroll_area_page.dart',
    builder: _page(const ScrollAreaPage()),
  ),
  ShowcasePage(
    title: 'Oito2ScrollViewUndershoot',
    icon: LucideIcons.rows_2,
    source: 'undershoot_page.dart',
    builder: _page(const UndershootPage()),
  ),
  ShowcasePage(
    title: 'Oito2SearchField',
    icon: LucideIcons.search,
    source: 'search_field_page.dart',
    builder: _page(const SearchFieldPage()),
  ),
  ShowcasePage(
    title: 'Oito2Section',
    icon: LucideIcons.heading,
    source: 'section_page.dart',
    builder: _page(const SectionPage()),
  ),
  ShowcasePage(
    title: 'Oito2SegmentGroup',
    icon: LucideIcons.rectangle_ellipsis,
    source: 'segment_group_page.dart',
    builder: _page(const SegmentGroupPage()),
  ),
  ShowcasePage(
    title: 'Oito2SegmentedEntry',
    icon: LucideIcons.text_cursor_input,
    source: 'segmented_entry_page.dart',
    builder: _page(const SegmentedEntryPage()),
  ),
  ShowcasePage(
    title: 'Oito2SelectableContainer',
    icon: LucideIcons.mouse_pointer_click,
    source: 'selectable_container_page.dart',
    builder: _page(const SelectableContainerPage()),
  ),
  ShowcasePage(
    title: 'Oito2Sheet',
    icon: LucideIcons.panel_right,
    source: 'sheet_page.dart',
    builder: _page(const SheetPage()),
  ),
  ShowcasePage(
    title: 'Oito2Slider',
    icon: LucideIcons.sliders_horizontal,
    source: 'slider_page.dart',
    builder: _page(const SliderPage()),
  ),
  ShowcasePage(
    title: 'Oito2SplitButton',
    icon: LucideIcons.split,
    source: 'split_button_page.dart',
    builder: _page(const SplitButtonPage()),
  ),
  ShowcasePage(
    title: 'Oito2Splitter',
    icon: LucideIcons.columns_3,
    source: 'splitter_page.dart',
    builder: _page(const SplitterPage()),
  ),
  ShowcasePage(
    title: 'Oito2Steps',
    icon: LucideIcons.list_ordered,
    source: 'steps_page.dart',
    builder: _page(const StepsPage()),
  ),
  ShowcasePage(
    title: 'Oito2Swap',
    icon: LucideIcons.repeat_2,
    source: 'swap_page.dart',
    builder: _page(const SwapPage()),
  ),
  ShowcasePage(
    title: 'Oito2Switch',
    icon: LucideIcons.toggle_left,
    source: 'switch_page.dart',
    builder: _page(const SwitchPage()),
  ),
  ShowcasePage(
    title: 'Oito2SwitchButton',
    icon: LucideIcons.toggle_right,
    source: 'switch_button_page.dart',
    builder: _page(const SwitchButtonPage()),
  ),
  ShowcasePage(
    title: 'Oito2TabBar',
    icon: LucideIcons.panels_top_left,
    source: 'tab_bar_page.dart',
    builder: _page(const TabBarPage()),
  ),
  ShowcasePage(
    title: 'Oito2TableOfContents',
    icon: LucideIcons.table_of_contents,
    source: 'table_of_contents_page.dart',
    builder: _page(const TableOfContentsPage()),
  ),
  ShowcasePage(
    title: 'Oito2TagsField',
    icon: LucideIcons.tags,
    source: 'tags_field_page.dart',
    builder: _page(const TagsFieldPage()),
  ),
  ShowcasePage(
    title: 'Oito2Tile',
    icon: LucideIcons.layout_list,
    source: 'tile_page.dart',
    builder: _page(const TilePage()),
  ),
  ShowcasePage(
    title: 'Oito2TimerText',
    icon: LucideIcons.timer,
    source: 'timer_page.dart',
    builder: _page(const TimerPage()),
  ),
  ShowcasePage(
    title: 'Oito2TitleBar',
    icon: LucideIcons.panels_top_left,
    source: 'title_bar_page.dart',
    builder: _page(const TitleBarPage()),
  ),
  ShowcasePage(
    title: 'Oito2Toaster',
    icon: LucideIcons.bell,
    source: 'toast_page.dart',
    builder: _page(const ToastPage()),
  ),
  ShowcasePage(
    title: 'Oito2ToggleButton',
    icon: LucideIcons.square_mouse_pointer,
    source: 'toggle_button_page.dart',
    builder: _page(const ToggleButtonPage()),
  ),
  ShowcasePage(
    title: 'Oito2ToggleGroup',
    icon: LucideIcons.toggle_left,
    source: 'toggle_group_page.dart',
    builder: _page(const ToggleGroupPage()),
  ),
  ShowcasePage(
    title: 'Oito2Tour',
    icon: LucideIcons.route,
    source: 'tour_page.dart',
    builder: _page(const TourPage()),
  ),
  ShowcasePage(
    title: 'Oito2TreeView',
    icon: LucideIcons.folder_tree,
    source: 'tree_view_page.dart',
    builder: _page(const TreeViewPage()),
  ),
  ShowcasePage(
    title: 'Oito2VerticalTabs',
    icon: LucideIcons.panel_left_dashed,
    source: 'vertical_tabs_page.dart',
    builder: _page(const VerticalTabsPage()),
  ),
  ShowcasePage(
    title: 'Oito2Watermark',
    icon: LucideIcons.stamp,
    source: 'watermark_page.dart',
    builder: _page(const WatermarkPage()),
  ),
  ShowcasePage(
    title: 'Oito2ImageCropper',
    icon: LucideIcons.crop,
    source: 'image_cropper_page.dart',
    group: ShowcaseGroup.extras,
    builder: _page(const ImageCropperPage()),
  ),
  ShowcasePage(
    title: 'Oito2NavigationMenu',
    icon: LucideIcons.panel_top,
    source: 'navigation_menu_page.dart',
    group: ShowcaseGroup.extras,
    builder: _page(const NavigationMenuPage()),
  ),
  ShowcasePage(
    title: 'Oito2QrCode',
    icon: LucideIcons.qr_code,
    source: 'qr_code_page.dart',
    group: ShowcaseGroup.extras,
    builder: _page(const QrCodePage()),
  ),
  ShowcasePage(
    title: 'Oito2SignaturePad',
    icon: LucideIcons.signature,
    source: 'signature_pad_page.dart',
    group: ShowcaseGroup.extras,
    builder: _page(const SignaturePadPage()),
  ),
  ShowcasePage(
    title: 'Oito2DownloadTrigger',
    icon: LucideIcons.download,
    source: 'download_trigger_page.dart',
    group: ShowcaseGroup.files,
    builder: _page(const DownloadTriggerPage()),
  ),
  ShowcasePage(
    title: 'Oito2FileUpload',
    icon: LucideIcons.upload,
    source: 'file_upload_page.dart',
    group: ShowcaseGroup.files,
    builder: _page(const FileUploadPage()),
  ),
  ShowcasePage(
    title: 'Collections',
    icon: LucideIcons.list_tree,
    source: 'collections_page.dart',
    group: ShowcaseGroup.utilities,
    builder: _page(const CollectionsPage()),
  ),
  ShowcasePage(
    title: 'Oito2Commands',
    icon: LucideIcons.command,
    source: 'commands_page.dart',
    group: ShowcaseGroup.utilities,
    builder: _page(const CommandsPage()),
  ),
  ShowcasePage(
    title: 'Oito2Format',
    icon: LucideIcons.binary,
    source: 'format_page.dart',
    group: ShowcaseGroup.utilities,
    builder: _page(const FormatPage()),
  ),
  ShowcasePage(
    title: 'Oito2FreedesktopIcons',
    icon: LucideIcons.shapes,
    source: 'freedesktop_icons_page.dart',
    group: ShowcaseGroup.utilities,
    builder: _page(const FreedesktopIconsPage()),
  ),
  ShowcasePage(
    title: 'Material theme',
    icon: LucideIcons.palette,
    source: 'theme_page.dart',
    group: ShowcaseGroup.theme,
    builder: (context, colors) => ThemePage(colors: colors),
  ),
  ShowcasePage(
    title: 'Foundation',
    icon: LucideIcons.monitor_smartphone,
    source: 'foundation_page.dart',
    group: ShowcaseGroup.theme,
    builder: _page(const FoundationPage()),
  ),
];
