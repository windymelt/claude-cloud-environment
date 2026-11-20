package bench

import io.circe.{Decoder, Encoder}
import io.circe.generic.semiauto.*

final case class Customer(id: Long, name: String, email: String, tier: String)
object Customer:
  given Decoder[Customer] = deriveDecoder
  given Encoder[Customer] = deriveEncoder

final case class Item(sku: String, title: String, unitPrice: BigDecimal, quantity: Int)
object Item:
  given Decoder[Item] = deriveDecoder
  given Encoder[Item] = deriveEncoder

final case class Order(id: Long, customer: Customer, items: List[Item], coupon: Option[String])
object Order:
  given Decoder[Order] = deriveDecoder
  given Encoder[Order] = deriveEncoder

final case class OrderSummary(orderId: Long, customerName: String, subtotal: BigDecimal, discount: BigDecimal, total: BigDecimal)
object OrderSummary:
  given Encoder[OrderSummary] = deriveEncoder
