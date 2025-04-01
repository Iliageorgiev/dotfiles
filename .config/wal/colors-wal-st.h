const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0E1D20", /* black   */
  [1] = "#8E745A", /* red     */
  [2] = "#668670", /* green   */
  [3] = "#9F956A", /* yellow  */
  [4] = "#2A7D82", /* blue    */
  [5] = "#59958E", /* magenta */
  [6] = "#9FAA9A", /* cyan    */
  [7] = "#dcdacf", /* white   */

  /* 8 bright colors */
  [8]  = "#9a9890",  /* black   */
  [9]  = "#8E745A",  /* red     */
  [10] = "#668670", /* green   */
  [11] = "#9F956A", /* yellow  */
  [12] = "#2A7D82", /* blue    */
  [13] = "#59958E", /* magenta */
  [14] = "#9FAA9A", /* cyan    */
  [15] = "#dcdacf", /* white   */

  /* special colors */
  [256] = "#0E1D20", /* background */
  [257] = "#dcdacf", /* foreground */
  [258] = "#dcdacf",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
