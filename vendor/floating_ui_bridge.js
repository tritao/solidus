import { autoUpdate, computePosition, flip, offset, shift, size } from "@floating-ui/dom";

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
  const gutterPx = toNumber(opts.offset, 8);
  const shiftPx = toNumber(opts.shift, 0);
  const viewportPadding = toNumber(opts.viewportPadding, 8);
  const flipEnabled = toBool(opts.flip, true);
  const slide = toBool(opts.slide, true);
  const overlap = toBool(opts.overlap, false);
  const updateOnAnimationFrame = toBool(opts.updateOnAnimationFrame, false);
  const sameWidth = toBool(opts.sameWidth, false);
  const fitViewport = toBool(opts.fitViewport, false);
  const fallbackPlacements =
    Array.isArray(opts.fallbackPlacements) && opts.fallbackPlacements.length > 0
      ? opts.fallbackPlacements.filter((p) => typeof p === "string")
      : undefined;

  const middleware = [
    offset(({ placement }) => {
      const hasAlignment = !!String(placement).split("-")[1];
      return {
        mainAxis: gutterPx,
        // If there's no placement alignment (*-start or *-end), fall back to
        // crossAxis as it also works for center-aligned placements.
        crossAxis: !hasAlignment ? shiftPx : undefined,
        alignmentAxis: shiftPx,
      };
    }),
    ...(flipEnabled
      ? (() => {
          const flipOpts = {
            padding: viewportPadding,
            rootBoundary: "viewport",
            boundary: document.documentElement,
          };
          if (fallbackPlacements) flipOpts.fallbackPlacements = fallbackPlacements;
          return [flip(flipOpts)];
        })()
      : []),
    ...(slide || overlap
      ? [
          (() => {
            const shiftOpts = {
              padding: viewportPadding,
              rootBoundary: "viewport",
              boundary: document.documentElement,
            };
            if (!slide) shiftOpts.mainAxis = false;
            if (overlap) shiftOpts.crossAxis = true;
            return shift(shiftOpts);
          })(),
        ]
      : []),
    size({
      padding: viewportPadding,
      apply({ availableWidth, availableHeight, rects }) {
        const referenceWidth = Math.round(rects.reference.width);
        const aw = Math.floor(availableWidth);
        const ah = Math.floor(availableHeight);

        floating.style.setProperty("--solid-popper-anchor-width", `${referenceWidth}px`);
        floating.style.setProperty("--solid-popper-content-available-width", `${aw}px`);
        floating.style.setProperty("--solid-popper-content-available-height", `${ah}px`);

        if (sameWidth) {
          if (!floating.style.boxSizing) floating.style.boxSizing = "border-box";
          floating.style.width = `${referenceWidth}px`;
        }

        if (fitViewport) {
          if (!floating.style.boxSizing) floating.style.boxSizing = "border-box";
          floating.style.maxWidth = `${aw}px`;
          floating.style.maxHeight = `${ah}px`;
        }
      },
    }),
  ];

  const update = async () => {
    if (!anchor || !floating) return;
    const { x, y, placement: computedPlacement } = await computePosition(anchor, floating, {
      placement,
      strategy: "fixed",
      middleware,
    });
    floating.style.position = "fixed";
    floating.style.left = `${x}px`;
    floating.style.top = `${y}px`;
    try {
      floating.setAttribute("data-solid-placement", computedPlacement);
      floating.style.setProperty("--solid-popper-current-placement", computedPlacement);
    } catch {}
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
