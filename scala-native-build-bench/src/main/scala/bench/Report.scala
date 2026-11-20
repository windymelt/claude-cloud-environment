package bench

import cats.Show
import cats.syntax.all.*

object Report:
  given Show[OrderSummary] = Show.show { s =>
    f"#${s.orderId}%-4d ${s.customerName}%-12s subtotal=${s.subtotal}%10s discount=${s.discount}%8s total=${s.total}%10s"
  }

  given Show[Pricing.Totals] = Show.show { t =>
    s"orders=${t.orders} gross=${t.gross} discount=${t.discount} net=${t.net}"
  }

  def table(rows: List[OrderSummary]): String =
    rows.map(_.show).mkString("\n")

  def byTier(orders: List[Order]): Map[String, Int] =
    orders.groupMapReduce(_.customer.tier)(_ => 1)(_ + _)
