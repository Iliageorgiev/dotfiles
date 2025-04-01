
      try {
        (function r({ contextBridge: n, ipcRenderer: i }) {
    if (!i)
      return;
    i.on("__ELECTRON_LOG_IPC__", (a, o) => {
      window.postMessage({ cmd: "message", ...o });
    }), i.invoke("__ELECTRON_LOG__", { cmd: "getOptions" }).catch((a) => console.error(new Error(
      `electron-log isn't initialized in the main process. Please call log.initialize() before. ${a.message}`
    )));
    const s = {
      sendToMain(a) {
        try {
          i.send("__ELECTRON_LOG__", a);
        } catch (o) {
          console.error("electronLog.sendToMain ", o, "data:", a), i.send("__ELECTRON_LOG__", {
            cmd: "errorHandler",
            error: { message: o == null ? void 0 : o.message, stack: o == null ? void 0 : o.stack },
            errorName: "sendToMain"
          });
        }
      },
      log(...a) {
        s.sendToMain({ data: a, level: "info" });
      }
    };
    for (const a of ["error", "warn", "info", "verbose", "debug", "silly"])
      s[a] = (...o) => s.sendToMain({
        data: o,
        level: a
      });
    if (n && process.contextIsolated)
      try {
        n.exposeInMainWorld("__electronLog", s);
      } catch {
      }
    typeof window == "object" ? window.__electronLog = s : __electronLog = s;
  })(require('electron'));
      } catch(e) {
        console.error(e);
      }
    