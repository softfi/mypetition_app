import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'custom_text.dart';

class SingleSelectionDropdown<T> extends StatefulWidget {
  final String? title;
  final T? selectedValue;
  final bool? mandatory;
  final BorderRadiusGeometry? borderRadiusGeometry;
  final List<T> items;
  final Function(T?) onSelectionChanged;
  final bool isActive;
  final bool dropdownIcon;
  final String? selectType;

  // Functions to get id and name from generic type
  final String Function(T) getId;
  final String Function(T) getName;

  /// ✅ Error handling
  final bool? isError;
  final String? errorText;

  const SingleSelectionDropdown({
    super.key,
    this.title,
    this.mandatory,
    this.borderRadiusGeometry,
    this.selectedValue,
    this.isActive = true,
    this.dropdownIcon = true,
    required this.items,
    required this.onSelectionChanged,
    required this.getId,
    required this.getName,
    this.selectType,
    this.isError,
    this.errorText,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  State<SingleSelectionDropdown<T>> createState() =>
      _SingleSelectionDropdownState<T>();
}

class _SingleSelectionDropdownState<T>
    extends State<SingleSelectionDropdown<T>> {
  T? _selectedItem;
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final OverlayPortalController _tooltipController = OverlayPortalController();
  final _link = LayerLink();

  List<T> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedValue;
    filteredItems = widget.items;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredItems = widget.items
            .where((item) =>
            widget.getName(item).toLowerCase().contains(query))
            .toList();
      });
    });

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        // When search field is clicked and keyboard opens, scroll into view
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              alignment: 0.1, // Scroll even higher to clear the keyboard
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SingleSelectionDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        _selectedItem = widget.selectedValue;
      });
    }
    if (widget.items != oldWidget.items) {
      setState(() {
        filteredItems = widget.items;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _selectItem(T item) {
    setState(() {
      _selectedItem = item;
      _isExpanded = false;
      _tooltipController.hide();
      _searchController.clear();
      _searchFocusNode.unfocus();
      filteredItems = widget.items;
    });
    widget.onSelectionChanged(item);
  }

  @override
  Widget build(BuildContext context) {
    final selectedText = _selectedItem != null
        ? widget.getName(_selectedItem as T)
        : 'Select ${widget.title ?? widget.selectType ?? ""}';

    final bool showError = widget.isError ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                AppText(
                  title: widget.title!,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                if (widget.mandatory ?? false)
                  const AppText(title: " *", color: Colors.red),
              ],
            ),
          ),

        // Dropdown container with Overlay
        TapRegion(
          groupId: 'dropdown_${widget.title}',
          onTapOutside: (event) {
            if (_isExpanded) {
              setState(() {
                _isExpanded = false;
                _tooltipController.hide();
              });
            }
          },
          child: OverlayPortal(
            controller: _tooltipController,
            overlayChildBuilder: (context) {
              return CompositedTransformFollower(
                link: _link,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 4),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: TapRegion(
                      groupId: 'dropdown_${widget.title}',
                      child: Container(
                        width: _link.leaderSize?.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                          borderRadius: widget.borderRadiusGeometry ??
                              BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.1 : 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Search Field
                            TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              autofocus: false,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              decoration: InputDecoration(
                                hintText:
                                    "Search ${widget.title ?? widget.selectType ?? ""}",
                                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // List of items
                            if (_searchController.text.isNotEmpty ||
                                filteredItems.isNotEmpty)
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight: filteredItems.length < 4
                                      ? 120
                                      : MediaQuery.of(context).size.height *
                                          0.25,
                                ),
                                child: filteredItems.isEmpty
                                    ? Center(
                                        child: AppText(
                                          title: 'No data found',
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                      )
                                    : Scrollbar(
                                        controller: _scrollController,
                                        thumbVisibility: true,
                                        trackVisibility: true,
                                        thickness: 6,
                                        radius: const Radius.circular(4),
                                        child: ListView.separated(
                                          controller: _scrollController,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemCount: filteredItems.length,
                                          itemBuilder: (context, index) {
                                            final item = filteredItems[index];
                                            final isSelected =
                                                _selectedItem != null &&
                                                    widget.getId(item) ==
                                                        widget.getId(
                                                            _selectedItem as T);
                                            return GestureDetector(
                                              onTap: () => _selectItem(item),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? (Theme.of(context).brightness == Brightness.light ? Colors.grey[200] : Colors.white10)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: AppText(
                                                  title: widget.getName(item),
                                                  color: isSelected
                                                      ? Theme.of(context).colorScheme.primary
                                                      : Theme.of(context).colorScheme.onSurface,
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 6),
                                        ),
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: CompositedTransformTarget(
              link: _link,
              child: GestureDetector(
                onTap: widget.isActive
                    ? () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                          _tooltipController.toggle();
                        });

                        if (_isExpanded) {
                          // Scroll into view if opened
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 300),
                                alignment: 0.2,
                                curve: Curves.easeInOut,
                              );
                            }
                          });
                        }
                      }
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: showError
                          ? Colors.red
                          : (_isExpanded
                              ? AppColors.primary
                              : Theme.of(context).dividerColor),
                      width: showError ? 1.5 : (_isExpanded ? 1.5 : 1),
                    ),
                    borderRadius: widget.borderRadiusGeometry ??
                        BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          title: selectedText,
                          color: (_selectedItem == null)
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (widget.isLoading)
                        const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.green,
                          ),
                        )
                      else if (widget.dropdownIcon)
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ✅ Error Text
        if (showError && widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 18),
            child: AppText(
              title: widget.errorText!,
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
