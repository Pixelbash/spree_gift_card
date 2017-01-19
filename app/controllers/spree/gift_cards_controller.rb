module Spree
  class GiftCardsController < Spree::StoreController

    before_action :load_master_variant, only: :new
    before_action :load_gift_card, only: :redeem

    def redeem
      if @gift_card.safely_redeem(spree_current_user)
        redirect_to redirect_after_redeem, flash: { success: Spree.t('gift_card_redeemed') }
      else
        redirect_to root_path, flash: { error: @gift_card.errors.full_messages.to_sentence }
      end
    end

    def index
      product_id = Spree::Product.active.where(is_gift_card: true).first.id
      redirect_to product_path product_id
    end

    def new
      find_gift_card_variants
      @gift_card = GiftCard.new
    end

    def create
      begin
        # Wrap the transaction script in a transaction so it is an atomic operation
        Spree::GiftCard.transaction do
          # Add to order
          order = current_order(create_order_if_necessary: true)

          quantity = 1
          variant  = Spree::Variant.find_by_id gift_card_params[:variant_id]
          options  = {
            price: variant.price,
            gift_card_attributes: gift_card_params.to_h
          }

          line_item  = order.contents.add(variant, 1, options)
          @gift_card = line_item.gift_card

          order.reload
        end
        redirect_to cart_path
      rescue ActiveRecord::RecordInvalid => e
        @gift_card    = GiftCard.new
        flash[:error] = e.record.errors.full_messages.join(", ")
        find_gift_card_variants
        render :new
      end
    end

    private

    def redirect_after_redeem
      root_path
    end

    def load_gift_card
      @gift_card = Spree::GiftCard.where(code: params[:id]).last
      unless @gift_card
        redirect_to root_path, flash: { error: Spree.t('gift_code_not_found') }
      end
    end

    def find_gift_card_variants
      gift_card_product_ids = Product.available.where(is_gift_card: true).pluck(:id)
      @gift_card_variants = Variant.joins(:prices).where(["amount > 0 AND product_id IN (?)", gift_card_product_ids]).order("amount")
    end

    def gift_card_params
      params.require(:gift_card).permit(:email, :name, :note, :variant_id)
    end

    def load_master_variant
      @master_variant = Spree::Product.find_by(slug: params[:product_id]).try(:master)
    end

  end
end
