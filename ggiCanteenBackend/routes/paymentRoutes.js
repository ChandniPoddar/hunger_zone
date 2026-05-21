const express = require("express");
const router = express.Router();
const { createPhonePeOrder, phonepeCallback } = require("../controllers/paymentController");

router.post("/phonepe/create-order", createPhonePeOrder);
router.post("/callback", phonepeCallback);

module.exports = router;
