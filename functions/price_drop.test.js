const test = require('node:test');
const assert = require('node:assert/strict');
const { isRealPriceDrop } = require('./price_drop');

test('accepts only a lower active product price', () => {
  assert.equal(isRealPriceDrop({ price: 1500 }, { price: 1200, active: true }), true);
  assert.equal(isRealPriceDrop({ price: 1500 }, { price: 1500, active: true }), false);
  assert.equal(isRealPriceDrop({ price: 1500 }, { price: 1700, active: true }), false);
  assert.equal(isRealPriceDrop({ price: 1500 }, { price: 1200, active: false }), false);
  assert.equal(isRealPriceDrop({ price: 1500 }, { price: -1, active: true }), false);
});
