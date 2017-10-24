//= require spree/backend


SpreeGiftCard = {
  hideSettings: function(paymentMethod) {
    if (SpreeGiftCard.paymentMethodID && paymentMethod.val() == SpreeGiftCard.paymentMethodID) {
      $('.payment-method-settings').children().hide();
      $('#payment_amount').prop('disabled', 'disabled');
      $('button[type="submit"]').prop('disabled', 'disabled');
      $('#paypal-warning').show();
    } else if (SpreeGiftCard.paymentMethodID) {
      $('.payment-method-settings').children().show();
      $('button[type=submit]').prop('disabled', '');
      $('#payment_amount').prop('disabled', '')
      $('#paypal-warning').hide();
    }
  }
}

$(document).ready(function() {
  checkedPaymentMethod = $('[data-hook="payment_method_field"] input[type="radio"]:checked');
  SpreeGiftCard.hideSettings(checkedPaymentMethod);
  paymentMethods = $('[data-hook="payment_method_field"] input[type="radio"]').click(function (e) {
    SpreeGiftCard.hideSettings($(e.target));
  });
})