resource "helm_release" "release" {
  for_each = var.helm_charts

  name       = each.key
  repository = each.value.repository
  chart      = each.value.chart
  version    = each.value.version

  values = [
    file("values/${each.key}_values.yml")
  ]
}
