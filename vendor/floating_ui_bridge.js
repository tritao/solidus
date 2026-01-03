import { autoUpdate, computePosition, flip, offset, shift } from "@floating-ui/dom";

function toNumber(value, fallback) {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function toBool(value, fallback) {
  if (value === true || value === false) return value;
  return fallback;
}

globalThis.__solidFloatToAnchor = (anchor, floating, opts = {}) => {
  const placement = typeof opts.placement === "string" ? opts.placement : "bottom-start";
  const offsetPx = toNumber(opts.offset, 8);
  const viewportPadding = toNumber(opts.viewportPadding, 8);
  const flipEnabled = toBool(opts.flip, true);
  const updateOnAnimationFrame = toBool(opts.updateOnAnimationFrame, false);

  const middleware = [
    offset(offsetPx),
    ...(flipEnabled ? [flip({ padding: viewportPadding })] : []),
    shift({ padding: viewportPadding }),
  ];

  const update = async () => {
    if (!anchor || !floating) return;
    const { x, y } = await computePosition(anchor, floating, {
      placement,
      strategy: "fixed",
      middleware,
    });
    floating.style.position = "fixed";
    floating.style.left = `${x}px`;
    floating.style.top = `${y}px`;
  };

  const cleanup = autoUpdate(anchor, floating, update, {
    animationFrame: updateOnAnimationFrame,
  });

  // initial compute
  void update();

  return {
    dispose() {
      cleanup();
    },
  };
};

