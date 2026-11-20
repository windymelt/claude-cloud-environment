package bench

import cats.Monoid
import cats.syntax.all.*

object Pricing:
  final case class Totals(orders: Int, gross: BigDecimal, discount: BigDecimal):
    def net: BigDecimal = gross - discount

  given Monoid[Totals] with
    def empty: Totals = Totals(0, BigDecimal(0), BigDecimal(0))
    def combine(a: Totals, b: Totals): Totals =
      Totals(a.orders + b.orders, a.gross + b.gross, a.discount + b.discount)

  private val tierRate: Map[String, BigDecimal] = Map(
    "gold"   -> BigDecimal("0.10"),
    "silver" -> BigDecimal("0.05"),
    "bronze" -> BigDecimal("0.00")
  )

  private val couponRate: Map[String, BigDecimal] = Map(
    "WELCOME" -> BigDecimal("0.05"),
    "SUSHI"   -> BigDecimal("0.08"),
    "BEER"    -> BigDecimal("0.03")
  )

  def subtotal(o: Order): BigDecimal =
    o.items.foldMap(i => i.unitPrice * i.quantity)

  def discountRate(o: Order): BigDecimal =
    val t = tierRate.getOrElse(o.customer.tier, BigDecimal(0))
    val c = o.coupon.flatMap(couponRate.get).getOrElse(BigDecimal(0))
    (t + c).min(BigDecimal("0.20"))

  def summarize(o: Order): OrderSummary =
    val sub  = subtotal(o)
    val disc = (sub * discountRate(o)).setScale(2, BigDecimal.RoundingMode.HALF_UP)
    OrderSummary(o.id, o.customer.name, sub, disc, sub - disc)

  def totals(os: List[OrderSummary]): Totals =
    os.foldMap(s => Totals(1, s.subtotal, s.discount))
