// Baseline: Scala Native 0.4.17 / Scala 3.3.7 / debug mode (plugin default)
ThisBuild / scalaVersion := "3.3.7"

lazy val app = project
  .in(file("."))
  .enablePlugins(ScalaNativePlugin)
  .settings(
    name := "sn-build-bench",
    libraryDependencies ++= Seq(
      "org.typelevel" %%% "cats-core"    % "2.11.0",
      "io.circe"      %%% "circe-core"   % "0.14.8",
      "io.circe"      %%% "circe-generic" % "0.14.8",
      "io.circe"      %%% "circe-parser" % "0.14.8"
    )
  )
