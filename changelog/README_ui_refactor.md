# New Level Select Layout
<img src="./assets/ui_refactor/level_select_new.png" alt="level_select_new" style="max-width: 512px;">

new functionality:

 - save data is updated when a player beats a level
 - level select UI:
    - level completion percentage displayed on top right panel
    - level ID displayed on bottom left panel
    - individual level completion displayed on bottom panel
    - completed levels styled in a darker tone

UI layout updates:

  - pause menu
    - extended horizontally to fit in the middle three columns of the UI grid
    - given row gutters to match level select screen button UI
  - fuel label
    - increased background transparency to 50%
    - the right edge of the fuel label is aligned to the edge of the first
      column of the UI grid
    - the fuel label is slightly lower than other UI elements on the grid
      so it doesn't clash with the border of the level
  - level select screen
    - level buttons are now actual buttons, like the pause menu.

Resource Management:

  - renamed assets to describe their intended use in greater detail

| asset                      | RGB           | RGB (normalized) | Opacity | hex code  |
|----------------------------|---------------|------------------|---------|-----------|
| `sbf_focus.tres`           | 204, 0, 0     | 0.8, 0.0, 0.0    | 100%    | `#cc0000` |
| `sbf_light.tres`           | 191, 191, 191 | 0.75, 0.75, 0.75 | 100%    | `#bfbfbf` |
| `sbf_mid.tres`             | 153, 153, 153 | 0.6, 0.6, 0.6    | 100%    | `#999999` |
| `sbf_mid_transparent.tres` | 153, 153, 153 | 0.6, 0.6, 0.6    | 50%     | `#999999` |
| `sbf_dark.tres`            | 115, 115, 115 | 0.45, 0.45, 0.45 | 100%    | `#737373` |

- `sbf_dark.tres` is about the darkest panel color you can comfortably read black text on.
- `sbf_mid.tres` is the default ui background color
- `sbf_dark.tres` and `sbf_light.tres` can be used for light and dark visual emphasis while keeping black text readable.

# UI Grid

<img src="./assets/ui_refactor/base_grid.png" alt="base grid" style="max-width: 512px;">

all UI elements are designed to fit to a base grid

the base grid aligns nicely with the 24 x 24 tileset used in game

base grid stats:

---

|                | col width | col gutter (blue) | row height | row gutter (red) |
|----------------|-----------|-------------------|------------|------------------|
| **pixels**     | 264       | 12                | 60         | 12               |
| **24px tiles** | 11        | 0.5               | 2.5        | 0.5              |

---

- 7 columns + 6 column gutters fit on a 1920x1080 screen
  - 1920px = (7 * 264px) + (6 * 12px)
  - 1920px = (7 * 276px) - 12px
- 15 rows + 15 row gutters fit on a 1920x1080 screen
  - 1080px = (15 * 60px) + (15 * 12px)
  - 1080px = (15 * 72px)

---


## Images

### UI Grid overlaid on Level Select Screen

<img src="./assets/ui_refactor/level_select.png" alt="level_select" style="max-width: 512px;">

### UI Grid overlaid over all UI elements

<img src="./assets/ui_refactor/ui_test.png" alt="ui_test" style="max-width: 512px;">

### UI Grid overlaid over paused full-screen level

<img src="./assets/ui_refactor/jake_2.png" alt="jake_2" style="max-width: 512px;">
