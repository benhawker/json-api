class OrderCreator

  # Error raised when order is passed with no order_items
  class NoOrderItemsGiven < StandardError
    def initialize
      super("Please provide a minimum of one Order Item/Product with your order")
    end
  end

  # Error raised when a promo code is given and it is not recognised/active.
  class InvalidPromoCodeGiven < StandardError
    def initialize
      super("The Promo code provided is invalid.")
    end
  end

  attr_reader :user, :params

  def initialize(user, params)
    @user = user
    @params = params
  end

  def successful?
    order.errors.empty? && order.persisted?
  end

  # Creates an order.
  #
  # Returns an +Order+ object. If that is valid and persisted we can go
  # ahead an render a 2XX in the controller and show the created order.
  # Otherwise, the inquiry is not saved to the DB & relevant errors are
  # added to the instance.
  def publish!
    # Transaction ensures we do not create an order without order_items
    begin
      Order.transaction do
        order.save!
        create_order_items(order)
        calculate_total

        apply_promotion_to_order(params) if params[:promotion_code]
      end
        order
    rescue ActiveRecord::RecordInvalid => e
      order.tap { |o| o.errors.add(:base, "This Product does not exist.") }
    rescue ActiveRecord::RecordNotFound => e
      order.tap { |o| o.errors.add(:base, "This Product does not exist.") }
    rescue NoOrderItemsGiven => e
      order.tap { |o| o.errors.add(:base, e.message) }
    rescue InvalidPromoCodeGiven => e
      order.tap { |o| o.errors.add(:base, e.message) }
    rescue ActionController::ParameterMissing => e
      order.tap { |o| o.errors.add(:base, e.message) }
    end
  end

  private

  def order
    @created_order ||= user.orders.build
  end

  def valid_order_items?
    param(:order_items).present? && param(:order_items).size > 0 ? true : false
  end

  # For each declared order_item create and run validations.
  def create_order_items(order)
    raise NoOrderItemsGiven unless valid_order_items?

    Array(param(:order_items)).each do |order_item_params|
      order_item = build_order_item(order_item_params)
      order_item.save!
    end
  end

  def build_order_item(params)
    product = Product.find(params[:product_id])

    OrderItem.new(order_id: order.id,
                  product_id: params[:product_id],
                  quantity: params[:quantity],
                  # Copy product info at time of order across to each order_item
                  price: product.price)
  end

  def calculate_total
    order.order_items.each do |oi|
      order.total += (oi.price * oi.quantity)
    end
  end

  def apply_promotion_to_order(params)
    promotion = Promotion.where(code: params[:promotion_code]).last

    # Apply discount to total or raise an error if no valid promotion exists.
    if promotion
      order.total -= promotion.discount
      order.save!
    else
      raise InvalidPromoCodeGiven
    end
  end

  def param(key)
    params.fetch(key)
  end
end