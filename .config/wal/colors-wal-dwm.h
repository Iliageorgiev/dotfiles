static const char norm_fg[] = "#dcdacf";
static const char norm_bg[] = "#0E1D20";
static const char norm_border[] = "#9a9890";

static const char sel_fg[] = "#dcdacf";
static const char sel_bg[] = "#668670";
static const char sel_border[] = "#dcdacf";

static const char urg_fg[] = "#dcdacf";
static const char urg_bg[] = "#8E745A";
static const char urg_border[] = "#8E745A";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
