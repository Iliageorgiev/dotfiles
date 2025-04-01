/*#include "colors-waybar.css"*/
#define C1 (@fg:#C6083A)
#define C2 (@bg:#9E666F)

/* Vertical scale, larger values will amplify output */
#define VSCALE 100
/* Rendering direction, either -1 (outwards) or 1 (inwards). */
#define DIRECTION 1
/* Color gradient scale, (optionally) used in `COLOR` macro */
#define GRADIENT 20
/* Color definition. By default this is a gradient formed by mixing two colors.
   `pos` represents the pixel position relative to the visualizer baseline. */
#define COLOR @fg:mix(C1, C2, clamp(d / GRADIENT, 0, 40))
/* 1 to draw outline, 0 to disable */
#define DRAW_OUTLINE 1
/* 1 to draw edge highlight, 0 to disable */
#define DRAW_HIGHLIGHT 1
/* Whether to anti-alias the border of the graph, creating a smoother curve.
   This may have a small impact on performance.
   Note: requires `xroot` or `none` opacity to be set */
#define ANTI_ALIAS 0
/* outline color */
#define OUTLINE @bg:#d6aebd
/* 1 to join the two channels together in the middle, 0 to clamp both down to zero */
#define JOIN_CHANNELS 1
/* 1 to invert (vertically), 0 otherwise */
#define INVERT 1
#define C_LINE 1
#define DIRECTION 0
