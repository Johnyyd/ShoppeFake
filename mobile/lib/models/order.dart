class CheckoutResult {
  final int orderId;
  final String productName;
  final double virtualPricePaid;
  final double newVirtualBalance;
  final int dopamineHitsAwarded;
  final int newDopamineLevel;
  final String animationTrigger;
  final String message;

  CheckoutResult({
    required this.orderId,
    required this.productName,
    required this.virtualPricePaid,
    required this.newVirtualBalance,
    required this.dopamineHitsAwarded,
    required this.newDopamineLevel,
    required this.animationTrigger,
    required this.message,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    return CheckoutResult(
      orderId: json['order_id'] ?? 0,
      productName: json['product_name'] ?? '',
      virtualPricePaid: (json['virtual_price_paid'] ?? 0.0).toDouble(),
      newVirtualBalance: (json['new_virtual_balance'] ?? 0.0).toDouble(),
      dopamineHitsAwarded: json['dopamine_hits_awarded'] ?? 0,
      newDopamineLevel: json['new_dopamine_level'] ?? 0,
      animationTrigger: json['animation_trigger'] ?? 'EXTREME_CONFETTI_BURST',
      message: json['message'] ?? 'Acquisition successful!',
    );
  }
}
