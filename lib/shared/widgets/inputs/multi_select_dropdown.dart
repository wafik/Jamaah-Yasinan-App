import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  const MultiSelectDropdown({
    super.key,
    required this.selectedItems,
    required this.items,
    required this.hint,
    required this.displayText,
    required this.onChanged,
    this.validator,
    this.itemLabel,
  });

  final List<T> selectedItems;
  final List<T> items;
  final String hint;
  final String Function(T) displayText;
  final ValueChanged<List<T>> onChanged;
  final String? Function(List<T>)? validator;
  final String Function(T)? itemLabel;

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterItems,
                      decoration: InputDecoration(
                        hintText: 'Cari...',
                        isDense: true,
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppColors.radiusSm,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Flexible(
                    child: _filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Tidak ada data',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isSelected = widget.selectedItems.contains(
                                item,
                              );
                              final label = widget.itemLabel != null
                                  ? widget.itemLabel!(item)
                                  : widget.displayText(item);
                              return InkWell(
                                onTap: () => _toggleItem(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  color: isSelected
                                      ? AppColors.primaryBg
                                      : Colors.transparent,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        isSelected
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        size: 18,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.text,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _removeOverlay();
                            _searchController.clear();
                          },
                          child: const Text(
                            'Tutup',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            _removeOverlay();
                            _searchController.clear();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleItem(T item) {
    final newSelected = List<T>.from(widget.selectedItems);
    if (newSelected.contains(item)) {
      newSelected.remove(item);
    } else {
      newSelected.add(item);
    }
    widget.onChanged(newSelected);
    setState(() {});
    _overlayEntry?.markNeedsBuild();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final label = widget.itemLabel != null
              ? widget.itemLabel!(item)
              : widget.displayText(item);
          return label.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  String _getDisplayValue() {
    if (widget.selectedItems.isEmpty) {
      return widget.hint;
    }
    if (widget.selectedItems.length == 1) {
      return widget.itemLabel != null
          ? widget.itemLabel!(widget.selectedItems.first)
          : widget.displayText(widget.selectedItems.first);
    }
    return '${widget.selectedItems.length} anggota dipilih';
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_isOpen) {
            _removeOverlay();
          } else {
            _filteredItems = widget.items;
            _searchController.clear();
            _showOverlay();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getDisplayValue(),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.selectedItems.isEmpty
                        ? AppColors.textMuted
                        : AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
