import morphdom from "morphdom";

export function morphPatch(fromNode, toNode) {
  return morphdom(fromNode, toNode, {
    getNodeKey(node) {
      if (!node) return null;
      if (node.id) return node.id;
      if (node.getAttribute) return node.getAttribute("data-key");
      return null;
    },
    onBeforeElUpdated(fromEl, toEl) {
      if (fromEl instanceof HTMLInputElement && toEl instanceof HTMLInputElement) {
        toEl.value = fromEl.value;
        toEl.checked = fromEl.checked;
      }
      if (
        fromEl instanceof HTMLTextAreaElement &&
        toEl instanceof HTMLTextAreaElement
      ) {
        toEl.value = fromEl.value;
      }
      return true;
    },
  });
}

