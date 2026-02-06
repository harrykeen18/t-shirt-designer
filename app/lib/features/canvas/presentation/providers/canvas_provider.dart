import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/image_utils.dart';

/// Canvas drawing tool types
enum DrawingTool { brush, eraser }

/// State for the pixel canvas
class CanvasState {
  final List<List<Color>> pixels;
  final Color selectedColor;
  final DrawingTool tool;
  final List<List<List<Color>>> undoHistory;
  final List<List<List<Color>>> redoHistory;
  final int selectedTshirtColorIndex;
  // Using nullable + default for hot reload compatibility
  final int? _backgroundColorIndex;

  const CanvasState({
    required this.pixels,
    required this.selectedColor,
    required this.tool,
    required this.undoHistory,
    required this.redoHistory,
    required this.selectedTshirtColorIndex,
    int? selectedBackgroundColorIndex,
  }) : _backgroundColorIndex = selectedBackgroundColorIndex;

  factory CanvasState.initial() {
    return CanvasState(
      pixels: ImageUtils.createEmptyCanvas(),
      selectedColor: AppColors.paletteColors[0], // Black
      tool: DrawingTool.brush,
      undoHistory: const [],
      redoHistory: const [],
      selectedTshirtColorIndex: 0, // White t-shirt
      selectedBackgroundColorIndex: 2, // White background
    );
  }

  /// Get selected background color index (defaults to 0/white)
  int get selectedBackgroundColorIndex => _backgroundColorIndex ?? 0;

  /// Get the current background color
  Color get backgroundColor {
    final index = selectedBackgroundColorIndex;
    if (index >= 0 && index < AppColors.backgroundColors.length) {
      return AppColors.backgroundColors[index];
    }
    return AppColors.backgroundColors[0]; // Default to white
  }

  CanvasState copyWith({
    List<List<Color>>? pixels,
    Color? selectedColor,
    DrawingTool? tool,
    List<List<List<Color>>>? undoHistory,
    List<List<List<Color>>>? redoHistory,
    int? selectedTshirtColorIndex,
    int? selectedBackgroundColorIndex,
  }) {
    return CanvasState(
      pixels: pixels ?? this.pixels,
      selectedColor: selectedColor ?? this.selectedColor,
      tool: tool ?? this.tool,
      undoHistory: undoHistory ?? this.undoHistory,
      redoHistory: redoHistory ?? this.redoHistory,
      selectedTshirtColorIndex:
          selectedTshirtColorIndex ?? this.selectedTshirtColorIndex,
      selectedBackgroundColorIndex:
          selectedBackgroundColorIndex ?? this.selectedBackgroundColorIndex,
    );
  }

  /// Check if canvas has any drawn pixels
  bool get hasContent {
    for (final row in pixels) {
      for (final color in row) {
        if (color.alpha > 0) return true;
      }
    }
    return false;
  }

  bool get canUndo => undoHistory.isNotEmpty;
  bool get canRedo => redoHistory.isNotEmpty;
}

/// StateNotifier for canvas operations
class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(CanvasState.initial());

  static const int maxHistorySize = 50;

  /// Deep copy a 2D color list
  List<List<Color>> _copyPixels(List<List<Color>> source) {
    return source.map((row) => List<Color>.from(row)).toList();
  }

  /// Save current state to undo history
  void _saveToHistory() {
    final newHistory = [
      ...state.undoHistory,
      _copyPixels(state.pixels),
    ];
    // Limit history size
    if (newHistory.length > maxHistorySize) {
      newHistory.removeAt(0);
    }
    state = state.copyWith(
      undoHistory: newHistory,
      redoHistory: [], // Clear redo on new action
    );
  }

  /// Draw a pixel at the given grid position
  void drawPixel(int x, int y, {bool saveHistory = true}) {
    if (x < 0 ||
        x >= ImageUtils.gridSize ||
        y < 0 ||
        y >= ImageUtils.gridSize) {
      return;
    }

    final newColor =
        state.tool == DrawingTool.eraser
            ? Colors.transparent
            : state.selectedColor;

    // Don't do anything if pixel is already the same color
    if (state.pixels[y][x] == newColor) return;

    if (saveHistory) {
      _saveToHistory();
    }

    final newPixels = _copyPixels(state.pixels);
    newPixels[y][x] = newColor;
    state = state.copyWith(pixels: newPixels);
  }

  /// Draw pixels during a pan gesture (no history save per pixel)
  void drawPixelDuringPan(int x, int y) {
    if (x < 0 ||
        x >= ImageUtils.gridSize ||
        y < 0 ||
        y >= ImageUtils.gridSize) {
      return;
    }

    final newColor =
        state.tool == DrawingTool.eraser
            ? Colors.transparent
            : state.selectedColor;

    if (state.pixels[y][x] == newColor) return;

    final newPixels = _copyPixels(state.pixels);
    newPixels[y][x] = newColor;
    state = state.copyWith(pixels: newPixels);
  }

  /// Start a drawing stroke (save history once at the beginning)
  void startStroke() {
    _saveToHistory();
  }

  /// Select a color from the palette
  void selectColor(Color color) {
    state = state.copyWith(
      selectedColor: color,
      tool: DrawingTool.brush,
    );
  }

  /// Toggle between brush and eraser
  void setTool(DrawingTool tool) {
    state = state.copyWith(tool: tool);
  }

  /// Select t-shirt color
  void selectTshirtColor(int index) {
    state = state.copyWith(selectedTshirtColorIndex: index);
  }

  /// Select background color for the design
  void selectBackgroundColor(int index) {
    state = state.copyWith(selectedBackgroundColorIndex: index);
  }

  /// Undo last action
  void undo() {
    if (!state.canUndo) return;

    final newUndoHistory = List<List<List<Color>>>.from(state.undoHistory);
    final previousState = newUndoHistory.removeLast();

    final newRedoHistory = [
      ...state.redoHistory,
      _copyPixels(state.pixels),
    ];

    state = state.copyWith(
      pixels: previousState,
      undoHistory: newUndoHistory,
      redoHistory: newRedoHistory,
    );
  }

  /// Redo last undone action
  void redo() {
    if (!state.canRedo) return;

    final newRedoHistory = List<List<List<Color>>>.from(state.redoHistory);
    final nextState = newRedoHistory.removeLast();

    final newUndoHistory = [
      ...state.undoHistory,
      _copyPixels(state.pixels),
    ];

    state = state.copyWith(
      pixels: nextState,
      undoHistory: newUndoHistory,
      redoHistory: newRedoHistory,
    );
  }

  /// Clear the canvas
  void clear() {
    if (!state.hasContent) return;
    _saveToHistory();
    state = state.copyWith(pixels: ImageUtils.createEmptyCanvas());
  }
}

/// Provider for canvas state
final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>(
  (ref) => CanvasNotifier(),
);
