import { signal, effect } from "@preact/signals-core";

const currentSlipIdx = signal(parseInt(location.hash.slice(1), 10) || 0);

effect(() => {
  history.replaceState(null, "", `#${ currentSlipIdx.value }`);
});

effect(() => {
    document.querySelectorAll(".slip").forEach(slip => {
        const attr = slip.getAttribute("data-slip");
        const slipIdx = attr !== null ? parseInt(attr, 10) : 0;

        if (slip instanceof HTMLElement) {
            if (slipIdx <= currentSlipIdx.value) {
                slip.style.opacity = "1";
            } else {
                slip.style.opacity = "0";
            }
        }
    });
})

const maxSlip = Array.from(document.querySelectorAll(".slip"))
  .map((slip) => {
    const attr = slip.getAttribute("data-slip");

    return attr !== null ? parseInt(attr, 10) : 0;
  })
  .reduce((a, b) => Math.max(a, b), 0);

function nextSlip() {
  if (currentSlipIdx.value < maxSlip) {
    currentSlipIdx.value += 1;
  }
}

function previousSlip() {
  if (currentSlipIdx.value > 0) {
    currentSlipIdx.value -= 1;
  }
}

document.addEventListener("keydown", (event) => {
  if (["ArrowRight", "ArrowDown", "PageDown", " ", "Enter"].includes(event.key)) {
    nextSlip();
  } else if (["ArrowLeft", "ArrowUp", "PageUp", "Backspace"].includes(event.key)) {
    previousSlip();
  }
});

// ── Get element rect in world-space ─────────────────────────────────────────
// We temporarily kill the transform so getBoundingClientRect() reflects
// the unscaled layout.
function worldRect(el) {
  const prev = world.style.transform;

  world.style.transition = 'none';
  world.style.transform  = 'matrix(1,0,0,1,0,0)';
  world.getBoundingClientRect(); // force reflow

  const er = el.getBoundingClientRect();
  const wr = world.getBoundingClientRect();

  world.style.transform = prev;
  // Flush the restore in the *same* sync block so it never paints the
  // identity transform to screen.
  world.getBoundingClientRect();
  world.style.transition = '';

  return {
    x: er.left - wr.left,
    y: er.top  - wr.top,
    w: er.width,
    h: er.height,
  };
}

effect(() => {
    const view = document.querySelector("#view");
    const world = document.querySelector("#world");
    const slips = document
        .querySelectorAll(`[data-slip="${ currentSlipIdx.value }"]`);
    const slip = slips[slips.length - 1];
    const up = slip.getAttribute("data-slip-up");
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const r = worldRect(slip);
    const vr = worldRect(view);
    const scale = vw / r.w;

    if (up !== null) {
        const upSlips = document.querySelectorAll(`[data-slip="${ up }"]`);
        const upSlip = upSlips[upSlips.length - 1];
        const upR = worldRect(upSlip);
        const dx = vw / 2 - (r.x + r.w / 2) * scale;
        const dy = - (upR.y) * scale;

        world.dataset.transformTranslateX = dx;
        world.dataset.transformTranslateY = dy;
        world.dataset.transformScale = scale;
        world.style.transform = `
            translate(${ dx }px, ${ dy }px)
            scale(${ scale })
        `;
    } else if (
        r.y < (- world.dataset.transformTranslateY) / world.dataset.transformScale
            || r.y + r.h > (- world.dataset.transformTranslateY + vh) / world.dataset.transformScale
    ) {
        const dx = vw / 2 - (r.x + r.w / 2) * scale;
        const dy = vh - (r.y + r.h) * scale;

        world.dataset.transformTranslateX = dx;
        world.dataset.transformTranslateY = dy;
        world.dataset.transformScale = scale;
        world.style.transform = `
            translate(${ dx }px, ${ dy }px)
            scale(${ scale })
        `;
    } else if (
        r.x < (- world.dataset.transformTranslateX) / world.dataset.transformScale
            || r.x + r.w > (- world.dataset.transformTranslateX + vw) / world.dataset.transformScale
    ) {
        const dx = vw / 2 - (r.x + r.w / 2) * scale;
        const dy = world.dataset.transformTranslateY;

        world.dataset.transformTranslateX = dx;
        world.dataset.transformTranslateY = dy;
        world.dataset.transformScale = scale;
        world.style.transform = `
            translate(${ dx }px, ${ dy }px)
            scale(${ scale })
        `;
    } else if (currentSlipIdx.value === 0) {
      world.dataset.transformTranslateX = 0;
      world.dataset.transformTranslateY = 0;
      world.dataset.transformScale = 1;
      world.style.transform = `
          translate3d(0px, 0px, 0px)
          scale(1)
      `;
    }
});
