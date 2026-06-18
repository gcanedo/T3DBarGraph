# Interaction

T3DBarGraph supports mouse and keyboard navigation.

## Mouse

- Left-drag to rotate the graph.
- Hold `Ctrl` and left-drag to pan the view.
- Use the mouse wheel to zoom toward the current cursor position.
- Click a bar to select it and show its floating 3D legend.
- Click empty space to clear the current selection.
- Right-click to open the component popup menu.

## Keyboard

- Arrow keys pan the view.
- `R` resets the view.
- `Home` resets the view.

## Selection

Bar selection works in both rendering paths:

- normal cube rendering;
- mesh rendering for larger datasets.

In mesh mode, the component uses screen-space picking so selection remains available even when many bars are rendered through grouped meshes.

## Practical Notes

For dense charts, navigation quality matters as much as raw rendering speed. If users need to inspect specific values, consider limiting the visible dataset or grouping data before rendering.
