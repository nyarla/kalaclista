(() => {
  const events =
    "wheel,touchstart,touchmove,keypress,keydown,pointermove".split(",");

  var loaded = false;
  const lazyloader = () => {
    if (loaded) {
      return;
    }

    loaded = true;

    let script = document.createElement("script");
    Object.assign(script, {
      src: "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-1273544194033160",
      crossorigin: "anonymouse",
    });

    for (let ev of events) {
      document.removeEventListener(ev, lazyloader);
    }

    document.body.appendChild(script);
  };

  for (let ev of events) {
    document.addEventListener(ev, lazyloader);
  }
})();
