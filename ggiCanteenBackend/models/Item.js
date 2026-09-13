const mongoose = require('mongoose');

const ItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  category: { type: String, required: true },
  imageUrl: { type: String, required: true },
  isAvailable: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

function getItemModel(category) {
  const clean = (category || '').toLowerCase().trim();
  switch (clean) {
    case 'nescafe':
      return mongoose.models.NescafeItem || mongoose.model('NescafeItem', ItemSchema);
    case 'lipton':
      return mongoose.models.LiptonItem || mongoose.model('LiptonItem', ItemSchema);
    case 'canteen':
      return mongoose.models.CanteenItem || mongoose.model('CanteenItem', ItemSchema);
    case 'fruit':
    case 'fruit corner':
      return mongoose.models.FruitCornerItem || mongoose.model('FruitCornerItem', ItemSchema);
    default:
      return mongoose.models.Item || mongoose.model('Item', ItemSchema);
  }
}

const NescafeItem = mongoose.models.NescafeItem || mongoose.model('NescafeItem', ItemSchema);
const LiptonItem = mongoose.models.LiptonItem || mongoose.model('LiptonItem', ItemSchema);
const CanteenItem = mongoose.models.CanteenItem || mongoose.model('CanteenItem', ItemSchema);
const FruitCornerItem = mongoose.models.FruitCornerItem || mongoose.model('FruitCornerItem', ItemSchema);
const GenericItem = mongoose.models.Item || mongoose.model('Item', ItemSchema);

module.exports = {
  ItemSchema,
  getItemModel,
  NescafeItem,
  LiptonItem,
  CanteenItem,
  FruitCornerItem,
  GenericItem,
};
