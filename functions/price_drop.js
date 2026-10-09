function isRealPriceDrop(before, after) {
  return (
    typeof before?.price === 'number' &&
    Number.isFinite(before.price) &&
    typeof after?.price === 'number' &&
    Number.isFinite(after.price) &&
    after.price >= 0 &&
    after.price < before.price &&
    after.active !== false
  );
}

module.exports = { isRealPriceDrop };
