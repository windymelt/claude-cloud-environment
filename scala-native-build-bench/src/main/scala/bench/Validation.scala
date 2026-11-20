package bench

import cats.data.{NonEmptyChain, ValidatedNec}
import cats.syntax.all.*

enum ValidationError:
  case EmptyName(customerId: Long)
  case InvalidEmail(email: String)
  case NonPositiveQuantity(sku: String)
  case NegativePrice(sku: String)
  case EmptyOrder(orderId: Long)

  def message: String = this match
    case EmptyName(id)            => s"customer $id has empty name"
    case InvalidEmail(e)          => s"invalid email: $e"
    case NonPositiveQuantity(sku) => s"item $sku has non-positive quantity"
    case NegativePrice(sku)       => s"item $sku has negative price"
    case EmptyOrder(id)           => s"order $id has no items"

object Validation:
  type V[A] = ValidatedNec[ValidationError, A]

  def customer(c: Customer): V[Customer] =
    val name: V[String] = if c.name.trim.nonEmpty then c.name.validNec else ValidationError.EmptyName(c.id).invalidNec
    val email: V[String] = if c.email.contains("@") then c.email.validNec else ValidationError.InvalidEmail(c.email).invalidNec
    (name, email).mapN((n, e) => c.copy(name = n, email = e))

  def item(i: Item): V[Item] =
    val q: V[Int] = if i.quantity > 0 then i.quantity.validNec else ValidationError.NonPositiveQuantity(i.sku).invalidNec
    val p: V[BigDecimal] = if i.unitPrice >= 0 then i.unitPrice.validNec else ValidationError.NegativePrice(i.sku).invalidNec
    (q, p).mapN((qq, pp) => i.copy(quantity = qq, unitPrice = pp))

  def order(o: Order): V[Order] =
    val items: V[List[Item]] =
      if o.items.isEmpty then ValidationError.EmptyOrder(o.id).invalidNec
      else o.items.traverse(item)
    (customer(o.customer), items).mapN((c, is) => o.copy(customer = c, items = is))

  def render(errs: NonEmptyChain[ValidationError]): String =
    errs.map(_.message).toList.mkString("; ")
