package bench

import cats.syntax.all.*
import io.circe.parser.decode
import io.circe.syntax.*

object Main:
  val banner = "Scala Native build bench v1"

  val sample: String =
    """[
      |  {"id":1,"customer":{"id":10,"name":"Alice","email":"alice@example.com","tier":"gold"},
      |   "items":[{"sku":"S-1","title":"Otoro","unitPrice":12.5,"quantity":4},
      |            {"sku":"B-1","title":"Pale Ale","unitPrice":6.0,"quantity":2}],"coupon":"SUSHI"},
      |  {"id":2,"customer":{"id":11,"name":"Bob","email":"bob@example.com","tier":"silver"},
      |   "items":[{"sku":"C-1","title":"Lounge Chair","unitPrice":4200,"quantity":1}],"coupon":null},
      |  {"id":3,"customer":{"id":12,"name":"","email":"broken","tier":"bronze"},
      |   "items":[],"coupon":"BEER"}
      |]""".stripMargin

  def main(args: Array[String]): Unit =
    println(banner)
    decode[List[Order]](sample) match
      case Left(err) =>
        Console.err.println(s"parse error: ${err.getMessage}")
        sys.exit(1)
      case Right(orders) =>
        val (bad, good) = orders.partitionMap(o => Validation.order(o).toEither.leftMap(e => (o.id, e)))
        bad.foreach((id, e) => println(s"order $id rejected: ${Validation.render(e)}"))
        val summaries = good.map(Pricing.summarize)
        import Report.given
        println(Report.table(summaries))
        println(Pricing.totals(summaries).show)
        println(s"tiers: ${Report.byTier(orders)}")
        println(summaries.asJson.noSpaces)
